
extends GutTest

const AccessExecutor: GDScript = preload("res://addons/locker/scripts/storage_manager/access_executor.gd")
const AccessStrategy: GDScript = preload("res://addons/locker/scripts/access_strategy/access_strategy.gd")
var DoubledAccessStrategy: GDScript

var executor: LokAccessExecutor

var watcher: Variant

func slow_operation() -> void:
	for i: int in 5_000_000:
		i += 1

func slow_file_ids_getter(_files_path: String) -> Dictionary:
	slow_operation()
	
	return { "status": Error.OK, "data": [] }

func slow_saver(
	_file_path: String,
	_file_format: String,
	_data: Dictionary,
	_replace: bool = false,
	_suppress_errors: bool = false
) -> Dictionary:
	slow_operation()
	
	return { "status": Error.OK, "data": "saved" }

func slow_loader(
	_file_path: String,
	_file_format: String,
	_partition_ids: Array[String] = [],
	_accessor_ids: Array[String] = [],
	_version_numbers: Array[String] = [],
	_suppress_errors: bool = false
) -> Dictionary:
	slow_operation()
	
	return { "status": Error.OK, "data": "loaded" }

func slow_remover(
	_file_path: String,
	_file_format: String,
	_partition_ids: Array[String] = [],
	_accessor_ids: Array[String] = [],
	_version_numbers: Array[String] = [],
	_suppress_errors: bool = false
) -> Dictionary:
	slow_operation()
	
	return { "status": Error.OK, "data": "removed" }

func before_all() -> void:
	DoubledAccessStrategy = double(AccessStrategy)

func before_each() -> void:
	stub(DoubledAccessStrategy, "get_file_ids").to_call(slow_file_ids_getter)
	stub(DoubledAccessStrategy, "save_data").to_call(slow_saver)
	stub(DoubledAccessStrategy, "load_data").to_call(slow_loader)
	stub(DoubledAccessStrategy, "remove_data").to_call(slow_remover)
	
	executor = AccessExecutor.new(DoubledAccessStrategy.new())

func after_each() -> void:
	if executor.thread.is_alive():
		executor.finish_execution()

func after_all() -> void:
	queue_free()

#region General behavior

func test_starts_thread_on_creation() -> void:
	assert_true(executor.thread.is_alive(), "Executor didn't start thread")

func test_keeps_executing_after_one_second() -> void:
	await wait_seconds(1.0, "Waiting thread execution")
	
	assert_true(executor.thread.is_alive(), "Executor stopped thread")

func test_operations_can_be_awaited() -> void:
	var expected_result: Dictionary = { "status": Error.OK, "data": "saved" }
	
	var result: Dictionary = await executor.request_saving(
		"", "", {}
	)
	
	assert_eq(result, expected_result, "Execution didn't return saved data")

func test_operations_can_be_queued() -> void:
	var expected_result: Dictionary = { "status": Error.OK, "data": "loaded" }
	
	executor.request_saving("", "", {})
	var result: Dictionary = await executor.request_loading("", "", [], [], [])
	
	assert_eq(result, expected_result, "Execution didn't return loaded data")

#endregion

#region Signal operation_started

func test_operation_started_signal_is_emitted_with_one_operation() -> void:
	watch_signals(executor)
	
	await executor.request_saving("", "", {})
	
	assert_signal_emit_count(
		executor, "operation_started", 1, "Signal emitted irregularly"
	)

func test_operation_started_signal_is_emitted_with_queued_operations() -> void:
	watch_signals(executor)
	
	executor.request_saving("", "", {})
	await executor.request_loading("", "", [])
	
	assert_signal_emit_count(
		executor, "operation_started", 2, "Signal emitted irregularly"
	)

#endregion

#region Signal operation_finished

func test_operation_finished_signal_is_emitted_with_one_operation() -> void:
	watch_signals(executor)
	
	await executor.request_saving("", "", {})
	
	assert_signal_emit_count(
		executor, "operation_finished", 1, "Signal emitted irregularly"
	)

func test_operation_finished_signal_is_emitted_with_queued_operations() -> void:
	watch_signals(executor)
	
	executor.request_saving("", "", {})
	await executor.request_loading("", "", [])
	
	assert_signal_emit_count(
		executor, "operation_finished", 2, "Signal emitted irregularly"
	)

#endregion

#region Method finish_execution

func test_finish_execution_stops_thread() -> void:
	await executor.finish_execution()
	
	assert_false(executor.thread.is_alive())

#endregion

#region Method is_busy

func test_executor_knows_its_busy() -> void:
	executor.request_saving("", "", {})
	
	assert_true(executor.is_busy(), "Executor doesn't know it's busy")

#endregion

#region Method request_get_files_id

func test_request_get_files_id_passes_arguments_to_access_strategy() -> void:
	executor.request_get_file_ids("res://test/saves")
	
	await wait_for_signal(executor.operation_started, 0.5, "Waiting saving start")
	
	assert_called(
		executor.access_strategy,
		"get_file_ids",
		[ "res://test/saves" ]
	)

#endregion

#region Method request_saving

func test_request_saving_passes_arguments_to_access_strategy() -> void:
	executor.request_saving("file1", "sav", { "accessor1": "data" })
	
	await wait_for_signal(executor.operation_started, 0.5, "Waiting saving start")
	
	assert_called(
		executor.access_strategy,
		"save_data",
		[ "file1", "sav", { "accessor1": "data" }, false ]
	)

#endregion

#region Method request_loading

func test_request_loading_passes_arguments_to_access_strategy() -> void:
	executor.request_loading("file1", "sav")
	
	await wait_for_signal(executor.operation_started, 0.5, "Waiting loading start")
	
	assert_called(
		executor.access_strategy,
		"load_data",
		[ "file1", "sav", [], [], [] ]
	)

#endregion

#region Method request_removing

func test_request_removing_passes_arguments_to_access_strategy() -> void:
	executor.request_removing("file1", "sav")
	
	await wait_for_signal(executor.operation_started, 0.5, "Waiting removing start")
	
	assert_called(
		executor.access_strategy,
		"remove_data",
		[ "file1", "sav", [], [], [] ]
	)

#endregion
