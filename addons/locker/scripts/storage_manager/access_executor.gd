@icon("res://addons/locker/icons/access_executor.svg")
class_name LokAccessExecutor
extends RefCounted

#region Signals

signal operation_started(operation: StringName)

signal operation_finished(result: Dictionary, operation: StringName)

#endregion

#region Properties

var mutex: Mutex = Mutex.new():
	set = set_mutex,
	get = get_mutex

var semaphore: Semaphore = Semaphore.new():
	set = set_semaphore,
	get = get_semaphore

var thread: Thread = Thread.new():
	set = set_thread,
	get = get_thread

var exit_executor: bool = false:
	set = set_exit_executor,
	get = should_exit_executor

var queued_operations: Array[LokAccessOperation] = []:
	set = set_queued_operations,
	get = get_queued_operations

var current_operation: LokAccessOperation = null:
	set = set_current_operation,
	get = get_current_operation

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

func push_error_no_access_strategy() -> void:
	push_error(
		"%s: No Access Strategy found" % error_string(Error.ERR_UNCONFIGURED)
	)

#endregion

#region Methods

func _init(strategy: LokAccessStrategy = LokJSONAccessStrategy.new()) -> void:
	access_strategy = strategy
	start_execution()

func start_execution() -> void:
	thread.start(execute)

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

func finish_execution() -> void:
	mutex.lock()
	exit_executor = true
	mutex.unlock()
	
	semaphore.post()
	
	await thread.wait_to_finish()

func queue_operation(operation: LokAccessOperation) -> void:
	queued_operations.push_front(operation)

func dequeue_operation() -> LokAccessOperation:
	if queued_operations.is_empty():
		return null
	
	return queued_operations.pop_back()

func has_queued_operations() -> bool:
	return not queued_operations.is_empty()

func has_current_operation() -> bool:
	return current_operation != null

func is_busy() -> bool:
	return has_queued_operations() or has_current_operation()

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

func request_reading(
	file_path: String,
	file_format: String,
	partition_ids: Array[String] = [],
	accessor_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	return await operate(
		read_data.bind(
			file_path,
			file_format,
			partition_ids,
			accessor_ids,
			version_numbers
		)
	)
	
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

func operate(operation_callable: Callable) -> Dictionary:
	var new_operation := LokAccessOperation.new(operation_callable)
	new_operation.started.connect(_on_operation_started, CONNECT_ONE_SHOT)
	new_operation.finished.connect(_on_operation_finished, CONNECT_ONE_SHOT)
	
	mutex.lock()
	queue_operation(new_operation)
	mutex.unlock()
	
	semaphore.post()
	
	var finished_args: Array = await new_operation.finished
	
	var result: Dictionary = {}
	
	if finished_args.size() > 0:
		result = finished_args[0]
	
	return result

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
		file_path, file_format, data, replace, false
	)
	
	return result

# Blocking operation
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
		version_numbers,
		false
	)
	
	return result

# Blocking operation
func read_data(
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
		version_numbers,
		false
	)
	
	return result

# Blocking operation
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
		version_numbers,
		false
	)
	
	return result

func _on_operation_started(operation: LokAccessOperation) -> void:
	operation_started.emit(operation)

func _on_operation_finished(result: Dictionary, operation: LokAccessOperation) -> void:
	operation_finished.emit(result, operation)

#endregion
