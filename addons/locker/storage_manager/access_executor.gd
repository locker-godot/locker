
class_name LokAccessExecutor
extends Resource

enum Operation {
	NONE,
	SAVE,
	LOAD,
	REMOVE
}

signal operation_finished(result: Dictionary, operation: Operation)
signal saving_finished(result: Dictionary)
signal loading_finished(result: Dictionary)
signal reading_finished(result: Dictionary)
signal removing_finished(result: Dictionary)

var mutex: Mutex = Mutex.new()
var semaphore: Semaphore = Semaphore.new()
var thread: Thread = Thread.new()
var exit_executor: bool = false

var current_operation: Operation = Operation.NONE

func _init() -> void:
	thread.start(execute)

func push_error_executor_busy(tried_operation: Operation) -> void:
	push_error("Can't start %s, executor is busy with %s" % [
		tried_operation
	])

func start_execution() -> void:
	pass

func execute() -> void:
	while true:
		semaphore.wait()
		
		mutex.lock()
		var should_stop: bool = exit_executor
		mutex.unlock()
		
		if should_stop:
			break
		
		var operation_callable: Callable = get_operation_callable(current_operation)
		
		operation_callable.call()
		
		mutex.lock()
		current_operation = Operation.NONE
		mutex.unlock()

func finish_execution() -> void:
	mutex.lock()
	exit_executor = true
	mutex.unlock()
	
	semaphore.post()
	
	thread.wait_to_finish()

func get_operation_callable(operation: Operation) -> Callable:
	match operation:
		Operation.SAVE: return save_data
		Operation.LOAD: return load_data
		Operation.REMOVE: return remove_data
		_: return Callable()

func get_operation_string(operation: Operation) -> String:
	match operation:
		Operation.SAVE: return "SAVE"
		Operation.LOAD: return "LOAD"
		Operation.REMOVE: return "REMOVE"
		_: return "INVALID"

func is_busy() -> bool:
	return current_operation != Operation.NONE

func start_saving() -> void:
	operate(Operation.SAVE)
	
func start_loading() -> void:
	operate(Operation.LOAD)
	
func start_removing() -> void:
	operate(Operation.REMOVE)

func operate(operation: Operation) -> bool:
	if is_busy():
		push_error_executor_busy(operation)
		return false
	
	mutex.lock()
	current_operation = operation
	mutex.unlock()
	
	semaphore.post()
	
	return true

# Blocking operation
func save_data() -> Dictionary:
	return {}

# Blocking operation
func load_data() -> Dictionary:
	return {}

# Blocking operation
func read_data() -> Dictionary:
	return {}

# Blocking operation
func remove_data() -> Dictionary:
	return {}
