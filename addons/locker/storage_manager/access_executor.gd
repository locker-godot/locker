
class_name LokAccessExecutor
extends RefCounted

#region Signals

signal operation_started(operation: StringName)

signal saving_started()

signal loading_started()

signal reading_started()

signal removing_started()

signal operation_finished(result: Dictionary, operation: StringName)

signal saving_finished(result: Dictionary)

signal loading_finished(result: Dictionary)

signal reading_finished(result: Dictionary)

signal removing_finished(result: Dictionary)

#endregion

#region Properties

var operations: Dictionary = {
	&"save": {
		&"callable": save_data,
		&"start_signal": saving_started,
		&"finish_signal": saving_finished
	},
	&"load": {
		&"callable": load_data,
		&"start_signal": loading_started,
		&"finish_signal": loading_finished,
	},
	&"read": {
		&"callable": read_data,
		&"start_signal": reading_started,
		&"finish_signal": reading_finished,
	},
	&"remove": {
		&"callable": remove_data,
		&"start_signal": removing_started,
		&"finish_signal": removing_finished,
	}
}

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

var queued_operations: Array[Dictionary] = []:
	set = set_queued_operations,
	get = get_queued_operations

var current_operation: Dictionary = {}:
	set = set_current_operation,
	get = get_current_operation

var last_result: Dictionary = {}:
	set = set_last_result,
	get = get_last_result

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

func set_queued_operations(new_operations: Array[Dictionary]) -> void:
	queued_operations = new_operations

func get_queued_operations() -> Array[Dictionary]:
	return queued_operations

func set_current_operation(new_operation: Dictionary) -> void:
	current_operation = new_operation

func get_current_operation() -> Dictionary:
	return current_operation

func set_last_result(new_result: Dictionary) -> void:
	last_result = new_result

func get_last_result() -> Dictionary:
	return last_result

func set_access_strategy(new_strategy: LokAccessStrategy) -> void:
	access_strategy = new_strategy

func get_access_strategy() -> LokAccessStrategy:
	return access_strategy

#endregion

#region Debug Methods

func push_error_no_access_strategy() -> void:
	push_error(
		"No Access Strategy found: %s", error_string(Error.ERR_UNCONFIGURED)
	)

#endregion

#region Methods

func _init(strategy: LokAccessStrategy) -> void:
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
		
		# Emit the operation start signals
		start_operation(get_operation_name(current_operation))
		
		# Execute the operation itself
		get_operation_callable(current_operation).call()
		
		mutex.lock()
		current_operation = {}
		mutex.unlock()

func finish_execution() -> void:
	mutex.lock()
	exit_executor = true
	mutex.unlock()
	
	semaphore.post()
	
	await thread.wait_to_finish()

func queue_operation(operation: Dictionary) -> void:
	queued_operations.push_front(operation)

func dequeue_operation() -> Dictionary:
	if queued_operations.is_empty():
		return {}
	
	return queued_operations.pop_back()

func get_next_operation() -> Dictionary:
	if queued_operations.is_empty():
		return {}
	
	return queued_operations.back()

func create_operation(
	operation_name: StringName,
	callable_args: Array
) -> Dictionary:
	var base_operation: Dictionary = get_operation_by_name(operation_name)
	
	var new_operation: Dictionary = base_operation.duplicate()
	new_operation[&"name"] = operation_name
	new_operation[&"callable"] = get_operation_callable(
		base_operation
	).bindv(callable_args)
	
	return new_operation

func get_operation_by_name(operation_name: StringName) -> Dictionary:
	return operations.get(operation_name, {})

func get_operation_name(operation: Dictionary) -> StringName:
	return operation.get(&"name", &"")

func get_operation_callable(operation: Dictionary) -> Callable:
	return operation.get(&"callable", Callable())

func get_operation_start_signal(operation: Dictionary) -> Signal:
	return operation.get(&"start_signal", Signal())

func get_operation_finish_signal(operation: Dictionary) -> Signal:
	return operation.get(&"finish_signal", Signal())

func create_result(
	data: Dictionary = {},
	status: Error = Error.OK
) -> Dictionary:
	return {
		"status": status,
		"data": data
	}

func has_queued_operations() -> bool:
	return not queued_operations.is_empty()

func has_current_operation() -> bool:
	return not current_operation.is_empty()

func is_busy() -> bool:
	return has_queued_operations() or has_current_operation()

func is_saving() -> bool:
	mutex.lock()
	var current_operation_name: StringName = get_operation_name(current_operation)
	mutex.unlock()
	
	return current_operation_name == &"save_data"

func is_loading() -> bool:
	mutex.lock()
	var current_operation_name: StringName = get_operation_name(current_operation)
	mutex.unlock()
	
	return current_operation_name == &"load_data"

func is_reading() -> bool:
	mutex.lock()
	var current_operation_name: StringName = get_operation_name(current_operation)
	mutex.unlock()
	
	return current_operation_name == &"read_data"

func is_removing() -> bool:
	mutex.lock()
	var current_operation_name: StringName = get_operation_name(current_operation)
	mutex.unlock()
	
	return current_operation_name == &"remove_data"

func request_saving(
	file_path: String,
	file_format: String,
	data: Dictionary,
	replace: bool = false
) -> Dictionary:
	return await operate(
		&"save",
		[ file_path, file_format, data, replace ]
	)

func request_loading(
	file_path: String,
	file_format: String,
	partition_ids: Array[String] = [],
	accessor_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	return await operate(
		&"load",
		[ file_path, file_format, partition_ids ]
	)

func request_reading(
	file_path: String,
	file_format: String,
	partition_ids: Array[String] = [],
	accessor_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	return await operate(
		&"read",
		[]
	)
	
func request_removing(
	file_path: String,
	file_format: String,
	partition_ids: Array[String] = [],
	accessor_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	return await operate(
		&"remove",
		[]
	)

func start_operation(operation_name: StringName) -> void:
	var operation: Dictionary = get_operation_by_name(operation_name)
	
	operation_started.emit(operation_name)
	get_operation_start_signal(operation).emit()

func finish_operation(result: Dictionary, operation_name: StringName) -> Dictionary:
	mutex.lock()
	last_result = result
	mutex.unlock()
	
	var operation: Dictionary = get_operation_by_name(operation_name)
	
	operation_finished.emit(result, operation_name)
	get_operation_finish_signal(operation).emit(result)
	
	return result

func operate(operation_name: StringName, args: Array) -> Dictionary:
	var new_operation: Dictionary = create_operation(operation_name, args)
	
	mutex.lock()
	queue_operation(new_operation)
	mutex.unlock()
	
	semaphore.post()
	
	while true:
		await operation_finished
		
		if queued_operations.is_empty():
			break
	
	mutex.lock()
	var result: Dictionary = last_result
	mutex.unlock()
	
	return result

func save_data(
	file_path: String,
	file_format: String,
	data: Dictionary,
	replace: bool = false
) -> Dictionary:
	var result: Dictionary = create_result()
	
	if access_strategy == null:
		push_error_no_access_strategy()
		result["status"] = Error.ERR_UNCONFIGURED
		
		return finish_operation(result, &"save")
	
	result = access_strategy.save_data(
		file_path, file_format, data, replace, false
	)
	
	return finish_operation(result, &"save")

# Blocking operation
func load_data(
	file_path: String,
	file_format: String,
	partition_ids: Array[String] = [],
	accessor_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	var result: Dictionary = create_result()
	
	if access_strategy == null:
		push_error_no_access_strategy()
		result["status"] = Error.ERR_UNCONFIGURED
		
		return finish_operation(result, &"load")
	
	result = access_strategy.load_data(
		file_path, file_format, partition_ids, false
	)
	
	return finish_operation(result, &"load")

# Blocking operation
func read_data(
	file_path: String,
	file_format: String,
	partition_ids: Array[String] = [],
	accessor_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	var result: Dictionary = create_result()
	
	if access_strategy == null:
		push_error_no_access_strategy()
		result["status"] = Error.ERR_UNCONFIGURED
		
		return finish_operation(result, &"read")
	
	result = access_strategy.load_data(
		file_path, file_format, partition_ids, false
	)
	
	return finish_operation(result, &"read")

# Blocking operation
func remove_data(
	file_path: String,
	file_format: String,
	partition_ids: Array[String] = [],
	accessor_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	var result: Dictionary = create_result()
	
	if access_strategy == null:
		push_error_no_access_strategy()
		result["status"] = Error.ERR_UNCONFIGURED
		
		return finish_operation(result, &"remove")
	
	result = access_strategy.remove_data(
		file_path,
		file_format,
		partition_ids,
		accessor_ids,
		version_numbers,
		false
	)
	
	return finish_operation(result, &"remove")

#endregion
