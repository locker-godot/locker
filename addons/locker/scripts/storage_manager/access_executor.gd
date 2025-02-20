@icon("res://addons/locker/icons/access_executor.svg")
## The [LokAccessExecutor] class separates accesses to another [Thread].
## 
## The [LokAccessExecutor] class is responsible for managing and separating
## the execution of access methods to another [Thread], so that those operations
## don't block the main flow of the program. [br]
## [br]
## [b]Version[/b]: 1.0.0 [br]
## [b]Author[/b]: Daniel Sousa ([url]github.com/nadjiel[/url])
class_name LokAccessExecutor
extends RefCounted

#region Signals

## The [signal operation_started] signal is emitted when an operation
## starts. [br]
## The operation that started is passed along in the [param operation]
## parameter.
signal operation_started(operation: StringName)

## The [signal operation_finished] signal is emitted when an operation
## finishes. [br]
## The result of the operation and the operation itself are passed along in the
## [param result] and [param operation] parameters.
signal operation_finished(result: Dictionary, operation: StringName)

#endregion

#region Properties

## The [member mutex] property stores a [Mutex] that helps controlling
## access to this [LokAccessExecutor]'s properties by multiple [Thread]s.
var mutex: Mutex = Mutex.new():
	set = set_mutex,
	get = get_mutex

## The [member semaphore] property stores a [Semaphore] that controls the flow
## of the [member thread] of this [LokAccessExecutor].
var semaphore: Semaphore = Semaphore.new():
	set = set_semaphore,
	get = get_semaphore

## The [member thread] property stores a [Thread] that executes all the
## heavy operation codes that this [LokAccessExecutor] must execute.
var thread: Thread = Thread.new():
	set = set_thread,
	get = get_thread

## The [member exit_executor] property stores a [code]bool[/code] indicating
## if the execution of the [member thread] should stop.
var exit_executor: bool = false:
	set = set_exit_executor,
	get = should_exit_executor

## The [member queued_operations] property stores an [Array] of
## [LokAccessOperation]s that are queued to be executed when this
## [LokAccessExecutor] becomes free to execute them.
var queued_operations: Array[LokAccessOperation] = []:
	set = set_queued_operations,
	get = get_queued_operations

## The [member current_operation] property stores the current
## [LokAccessOperation] that is being executed by this [LokAccessExecutor].
var current_operation: LokAccessOperation = null:
	set = set_current_operation,
	get = get_current_operation

## The [member access_strategy] property stores the [LokAccessStrategy] that
## this [LokAccessExecutor] uses to manipulate data.
var access_strategy: LokAccessStrategy = null:
	set = set_access_strategy,
	get = get_access_strategy

#endregion

#region Setters & getters

func set_mutex(new_mutex: Mutex) -> void:
	mutex = new_mutex

func get_mutex() -> Mutex:
	return mutex

func set_semaphore(new_semaphore: Semaphore) -> void:
	semaphore = new_semaphore

func get_semaphore() -> Semaphore:
	return semaphore

func set_thread(new_thread: Thread) -> void:
	thread = new_thread

func get_thread() -> Thread:
	return thread

func set_exit_executor(new_exit_executor: bool) -> void:
	exit_executor = new_exit_executor

func should_exit_executor() -> bool:
	return exit_executor

func set_queued_operations(new_operations: Array[LokAccessOperation]) -> void:
	queued_operations = new_operations

func get_queued_operations() -> Array[LokAccessOperation]:
	return queued_operations

func set_current_operation(new_operation: LokAccessOperation) -> void:
	current_operation = new_operation

func get_current_operation() -> LokAccessOperation:
	return current_operation

func set_access_strategy(new_strategy: LokAccessStrategy) -> void:
	access_strategy = new_strategy

func get_access_strategy() -> LokAccessStrategy:
	return access_strategy

#endregion

#region Debug Methods

## The [method push_error_no_access_strategy] method pushes an error
## warning that no [LokAccessStrategy]s are set in this [LokAccessExecutor].
func push_error_no_access_strategy() -> void:
	push_error(
		"%s: No Access Strategy found" % error_string(Error.ERR_UNCONFIGURED)
	)

#endregion

#region Methods

# Sets the strategy and starts the execution
func _init(strategy: LokAccessStrategy = null) -> void:
	access_strategy = strategy
	start_execution()

## The [method start_execution] method starts the execution of this
## [LokAccessExecutor]'s [member thread] with the [method execute] method.
func start_execution() -> void:
	thread.start(execute)

## The [method execute] method is responsible for executing the
## [LokAccessOperation]s ordered to this [LokAccessExecutor] and always keep
## waiting for more, unless the [member exit_executor] is set to
## [code]false[/code].
func execute() -> void:
	while true:
		semaphore.wait()
		
		mutex.lock()
		current_operation = dequeue_operation()
		var should_stop: bool = exit_executor
		mutex.unlock()
		
		if should_stop:
			break
		
		if current_operation == null:
			continue
		
		current_operation.operate()
		
		mutex.lock()
		current_operation = null
		mutex.unlock()

## The [method finish_execution] method finishes the execution of this
## [LokAccessExecutor]'s [member thread] by setting the [member exit_executor]
## property to [code]false[/code] and awaiting the [member thread] finish.
func finish_execution() -> void:
	mutex.lock()
	exit_executor = true
	mutex.unlock()
	
	semaphore.post()
	
	await thread.wait_to_finish()

## The [method queue_operation] method takes a new [LokAccessOperation] and
## appends it to the [member queued_operations] property, so that this
## [param operation] can be executed the sooner possible.
func queue_operation(operation: LokAccessOperation) -> void:
	queued_operations.push_front(operation)

## The [method dequeue_operation] method removes a [LokAccessOperation] from
## the [member queued_operations] property and returns it, so that it
## can be used for execution.
func dequeue_operation() -> LokAccessOperation:
	if queued_operations.is_empty():
		return null
	
	return queued_operations.pop_back()

## The [method has_queued_operations] method returns a [code]bool[/code]
## indicating if the [member queued_operations] has any operations queued.
func has_queued_operations() -> bool:
	return not queued_operations.is_empty()

## The [method has_current_operation] method returns a [code]bool[/code]
## indicating if the [member current_operation] has an operation.
func has_current_operation() -> bool:
	return current_operation != null

## The [method has_current_operation] method returns a [code]bool[/code]
## indicating if this [LokAccessExecutor] is currently busy with
## a [member current_operation] or will be busy with one of the
## [member queued_operations].
func is_busy() -> bool:
	return has_queued_operations() or has_current_operation()

## The [method request_get_file_ids] method queues an operation of
## getting the saved files' ids to be executed
## by this [LokAccessExecutor] the sooner the possible. [br]
## The parameters of this method and its return are the same of the
## [method LokAccessStrategy.get_file_ids], with the exception that
## this method is asynchronous.
func request_get_file_ids(files_path: String) -> Dictionary:
	return await operate(
		get_file_ids.bind(files_path)
	)

## The [method request_saving] method queues a saving operation to be executed
## by this [LokAccessExecutor] the sooner the possible. [br]
## The parameters of this method and its return are the same of the
## [method LokAccessStrategy.save_data], with the exception that this method is
## asynchronous.
func request_saving(
	file_path: String,
	file_format: String,
	data: Dictionary,
	replace: bool = false
) -> Dictionary:
	return await operate(
		save_data.bind(
			file_path,
			file_format,
			data,
			replace
		)
	)

## The [method request_loading] method queues a loading operation to be executed
## by this [LokAccessExecutor] the sooner the possible. [br]
## The parameters of this method and its return are the same of the
## [method LokAccessStrategy.load_data], with the exception that this method is
## asynchronous.
func request_loading(
	file_path: String,
	file_format: String,
	partition_ids: Array[String] = [],
	accessor_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	return await operate(
		load_data.bind(
			file_path,
			file_format,
			partition_ids,
			accessor_ids,
			version_numbers
		)
	)

## The [method request_removing] method queues a reading operation to be
## executed by this [LokAccessExecutor] the sooner the possible. [br]
## The parameters of this method and its return are the same of the
## [method LokAccessStrategy.remove_data], with the exception that this method
## is asynchronous.
func request_removing(
	file_path: String,
	file_format: String,
	partition_ids: Array[String] = [],
	accessor_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	return await operate(
		remove_data.bind(
			file_path,
			file_format,
			partition_ids,
			accessor_ids,
			version_numbers
		)
	)

## The [method create_operation] method creates a new [LokAccessOperation] and
## returns it, making sure to connect its signals to the
## [signal operation_started] and [signal operation_finished] signals.
func create_operation(callable: Callable) -> LokAccessOperation:
	var operation := LokAccessOperation.new(callable)
	operation.started.connect(
		_on_operation_started.bind(operation), CONNECT_ONE_SHOT
	)
	operation.finished.connect(
		_on_operation_finished.bind(operation), CONNECT_ONE_SHOT
	)
	
	return operation

## The [method operate] method receives an [param operation_callable] and
## creates a new [LokAccessOperation], which is appended to the
## [member queued_operations], so that the [member thread] can execute
## it in the [method execute] method. [br]
## This method then, returns the result of the operation when it is ready by
## awaiting the [signal LokAccessOperation.finished] signal.
func operate(operation_callable: Callable) -> Dictionary:
	var new_operation: LokAccessOperation = create_operation(operation_callable)
	
	mutex.lock()
	queue_operation(new_operation)
	mutex.unlock()
	
	semaphore.post()
	
	var result: Dictionary = await new_operation.finished
	
	return result

## The [method get_file_ids] method is responsible for using the
## [member access_strategy] to get the file ids of the saved files. [br]
## This method is wrapped by the [method request_get_file_ids] method, so that
## it can be executed asynchronously. [br]
## If you want more information about its parameters and return,
## see the [method LokAccessStrategy.get_file_ids]
## method, which has the same signature.
func get_file_ids(files_path: String) -> Dictionary:
	var result: Dictionary = LokAccessStrategy.create_result()
	result["data"] = []
	
	if access_strategy == null:
		push_error_no_access_strategy()
		result["status"] = Error.ERR_UNCONFIGURED
		
		return result
	
	result = access_strategy.get_file_ids(files_path)
	
	return result

## The [method save_data] method is responsible for using the
## [member access_strategy] to save data. [br]
## This method is wrapped by the [method request_saving] method, so that
## it can be executed asynchronously. [br]
## If you want more information about its parameters and return,
## see the [method LokAccessStrategy.save_data]
## method, which has the same signature.
func save_data(
	file_path: String,
	file_format: String,
	data: Dictionary,
	replace: bool = false
) -> Dictionary:
	var result: Dictionary = LokAccessStrategy.create_result()
	
	if access_strategy == null:
		push_error_no_access_strategy()
		result["status"] = Error.ERR_UNCONFIGURED
		
		return result
	
	result = access_strategy.save_data(
		file_path, file_format, data, replace
	)
	
	return result

## The [method load_data] method is responsible for using the
## [member access_strategy] to load data. [br]
## This method is wrapped by the [method request_loading] method, so that
## it can be executed asynchronously. [br]
## If you want more information about its parameters and return,
## see the [method LokAccessStrategy.load_data]
## method, which has the same signature.
func load_data(
	file_path: String,
	file_format: String,
	partition_ids: Array[String] = [],
	accessor_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	var result: Dictionary = LokAccessStrategy.create_result()
	
	if access_strategy == null:
		push_error_no_access_strategy()
		result["status"] = Error.ERR_UNCONFIGURED
		
		return result
	
	result = access_strategy.load_data(
		file_path,
		file_format,
		partition_ids,
		accessor_ids,
		version_numbers
	)
	
	return result

## The [method remove_data] method is responsible for using the
## [member access_strategy] to remove data. [br]
## This method is wrapped by the [method request_removing] method, so that
## it can be executed asynchronously. [br]
## If you want more information about its parameters and return,
## see the [method LokAccessStrategy.remove_data]
## method, which has the same signature.
func remove_data(
	file_path: String,
	file_format: String,
	partition_ids: Array[String] = [],
	accessor_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	var result: Dictionary = LokAccessStrategy.create_result()
	
	if access_strategy == null:
		push_error_no_access_strategy()
		result["status"] = Error.ERR_UNCONFIGURED
		
		return result
	
	result = access_strategy.remove_data(
		file_path,
		file_format,
		partition_ids,
		accessor_ids,
		version_numbers
	)
	
	return result

# Propagates the emission of an operation started signal
func _on_operation_started(operation: LokAccessOperation) -> void:
	operation_started.emit(operation)

# Propagates the emission of an operation finished signal
func _on_operation_finished(result: Dictionary, operation: LokAccessOperation) -> void:
	operation_finished.emit(result, operation)

#endregion
