
class_name LokAccessExecutor
extends Resource

signal operation_finished(result: Dictionary, operation: StringName)

signal saving_finished(result: Dictionary)

signal loading_finished(result: Dictionary)

signal reading_finished(result: Dictionary)

signal removing_finished(result: Dictionary)

var operations: Dictionary = {
	&"save": {
		&"callable": save_data,
		&"signal": saving_finished
	},
	&"load": {
		&"callable": load_data,
		&"signal": loading_finished
	},
	&"read": {
		&"callable": read_data,
		&"signal": reading_finished
	},
	&"remove": {
		&"callable": remove_data,
		&"signal": removing_finished
	}
}

var mutex: Mutex = Mutex.new()

var semaphore: Semaphore = Semaphore.new()

var thread: Thread = Thread.new()

var exit_executor: bool = false

var current_operation: String = &""

var access_strategy: LokAccessStrategy = null

func _init() -> void:
	start_execution()

func push_error_executor_busy(tried_operation: StringName) -> void:
	push_error(
		"Can't start '%s' operation, executor is busy with '%s' operation" % [
			tried_operation,
			current_operation
		]
	)

func start_execution() -> void:
	thread.start(execute)

func execute() -> void:
	while true:
		semaphore.wait()
		
		mutex.lock()
		var should_stop: bool = exit_executor
		mutex.unlock()
		
		if should_stop:
			break
		
		var operation_callable: Callable = get_operation_callable(
			current_operation
		)
		
		operation_callable.call()
		
		mutex.lock()
		current_operation = &""
		mutex.unlock()

func finish_execution() -> void:
	mutex.lock()
	exit_executor = true
	mutex.unlock()
	
	semaphore.post()
	
	thread.wait_to_finish()

func get_operation_data(operation: String) -> Dictionary:
	return operations.get(operation, {})

func set_operation_callable(operation: String, callable: Callable) -> void:
	get_operation_data(operation)["callable"] = callable

func get_operation_callable(operation: String) -> Callable:
	var operation_data: Dictionary = get_operation_data(operation)
	
	return operation_data.get("callable", Callable())

func get_operation_signal(operation: String) -> Signal:
	var operation_data: Dictionary = get_operation_data(operation)
	
	return operation_data.get("signal", Signal())

func create_result(
	data: Dictionary = {},
	status: Error = Error.OK
) -> Dictionary:
	return {
		"status": status,
		"data": data
	}

func reset_current_operation() -> void:
	current_operation = &""

func is_busy() -> bool:
	return current_operation != &""

func is_saving() -> bool:
	return current_operation == &"save"

func is_loading() -> bool:
	return current_operation == &"load"

func is_reading() -> bool:
	return current_operation == &"read"

func is_removing() -> bool:
	return current_operation == &"remove"

func start_saving(
	file_path: String,
	file_format: String,
	data: Dictionary,
	replace: bool = false
) -> void:
	operate(&"save", [ file_path, file_format, data, replace ])

func start_loading() -> void:
	#operate(Operation.LOAD)
	pass

func start_reading() -> void:
	#operate(Operation.READ)
	pass
	
func start_removing() -> void:
	#operate(Operation.REMOVE)
	pass

func finish_operation(result: Dictionary, operation_name: StringName) -> void:
	operation_finished.emit(result, operation_name)
	get_operation_signal(operation_name).emit(result)

func operate(operation: StringName, args: Array) -> bool:
	if is_busy():
		push_error_executor_busy(operation)
		return false
	
	set_operation_callable(
		operation, get_operation_callable(operation).bindv(args)
	)
	
	mutex.lock()
	current_operation = operation
	mutex.unlock()
	
	semaphore.post()
	
	return true

func save_data(
	file_path: String,
	file_format: String,
	data: Dictionary,
	replace: bool = false
) -> Dictionary:
	var result: Dictionary = create_result()
	
	if access_strategy == null:
		result["status"] = Error.ERR_UNCONFIGURED
		
		finish_operation(result, &"save")
		return result
	
	print("%s: Started saving file %s;" % [
		Time.get_ticks_msec(),
		file_path
	])
	
	result["data"] = access_strategy.save_data(
		file_path, file_format, data, replace
	)
	
	finish_operation(result, &"save")
	
	print("%s: Finished saving file %s;" % [
		Time.get_ticks_msec(),
		file_path
	])
	
	return result

# Blocking operation
#func save_data() -> Dictionary:
	#for i: int in 25_000_000:
		#i += 1
	#
	#var result: Dictionary = { "saved": true }
	#
	#operation_finished.emit(result, Operation.SAVE)
	#saving_finished.emit(result)
	#
	#return result

# Blocking operation
func load_data() -> Dictionary:
	for i: int in 10_000_000:
		i += 1
	
	return { "loaded": true }

# Blocking operation
func read_data() -> Dictionary:
	for i: int in 10_000_000:
		i += 1
	
	return { "readed": true }

# Blocking operation
func remove_data() -> Dictionary:
	for i: int in 10_000_000:
		i += 1
	
	return { "removed": true }
