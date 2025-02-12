
extends GutTest

const AccessExecutor: GDScript = preload("res://addons/locker/storage_manager/access_executor.gd")
const AccessStrategy: GDScript = preload("res://addons/locker/access_strategy/access_strategy.gd")
var DoubledAccessStrategy: GDScript

var executor: LokAccessExecutor

var watcher: Variant

func slow_saver(
	_file_path: String,
	_file_format: String,
	_data: Dictionary,
	_replace: bool = false,
	_suppress_errors: bool = false
) -> Dictionary:
	for i: int in 5_000_000:
		i += 1
	
	return { "status": Error.OK, "data": "saved" }

func slow_loader(
	_file_path: String,
	_file_format: String,
	_included_partitions: Array[String] = [],
	_suppress_errors: bool = false
) -> Dictionary:
	for i: int in 5_000_000:
		i += 1
	
	return { "status": Error.OK, "data": "loaded" }

func slow_remover(
	_file_path: String,
	_file_format: String,
	_partition_ids: Array[String] = [],
	_accessor_ids: Array[String] = [],
	_version_numbers: Array[String] = [],
	_suppress_errors: bool = false
) -> Dictionary:
	for i: int in 5_000_000:
		i += 1
	
	return { "status": Error.OK, "data": "removed" }

func before_all() -> void:
	DoubledAccessStrategy = double(AccessStrategy)

func before_each() -> void:
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
	
	stub(executor.access_strategy.save_data).to_call(slow_saver)
	
	var result: Dictionary = await executor.request_saving(
		"", "", {}
	)
	
	assert_eq(result, expected_result, "Execution didn't return saved data")

func test_operations_can_be_queued() -> void:
	var expected_result: Dictionary = { "status": Error.OK, "data": "loaded" }
	
	stub(executor.access_strategy.save_data).to_call(slow_saver)
	stub(executor.access_strategy.load_data).to_call(slow_loader)
	
	executor.request_saving("", "", {})
	var result: Dictionary = await executor.request_loading("", "")
	
	assert_eq(result, expected_result, "Execution didn't return loaded data")

#endregion

#region Signal operation_started

func test_operation_started_signal_is_emitted_with_one_operation() -> void:
	watch_signals(executor)
	
	stub(executor.access_strategy.save_data).to_call(slow_saver)
	
	await executor.request_saving("", "", {})
	
	assert_signal_emitted_with_parameters(executor, "operation_started", [ &"save" ])

func test_operation_started_signal_is_emitted_with_queued_operations() -> void:
	watch_signals(executor)
	
	stub(executor.access_strategy.save_data).to_call(slow_saver)
	stub(executor.access_strategy.load_data).to_call(slow_loader)
	
	executor.request_saving("", "", {})
	await executor.request_loading("", "", [])
	
	assert_signal_emitted_with_parameters(executor, "operation_started", [ &"load" ])

#endregion

#region Signal saving_started

func test_saving_started_signal_is_emitted_with_one_operation() -> void:
	watch_signals(executor)
	
	stub(executor.access_strategy.save_data).to_call(slow_saver)
	
	await executor.request_saving("", "", {})
	
	assert_signal_emitted(executor, "saving_started", "Saving started wasn't emitted")

func test_saving_started_signal_is_emitted_with_queued_operations() -> void:
	watch_signals(executor)
	
	stub(executor.access_strategy.save_data).to_call(slow_saver)
	stub(executor.access_strategy.load_data).to_call(slow_loader)
	
	executor.request_loading("", "", [])
	await executor.request_saving("", "", {})
	
	assert_signal_emitted(executor, "saving_started", "Saving started wasn't emitted")

#endregion

#region Signal loading_started

func test_loading_started_signal_is_emitted_with_one_operation() -> void:
	watch_signals(executor)
	
	stub(executor.access_strategy.load_data).to_call(slow_loader)
	
	await executor.request_loading("", "")
	
	assert_signal_emitted(executor, "loading_started", "Loading started wasn't emitted")

func test_loading_started_signal_is_emitted_with_queued_operations() -> void:
	watch_signals(executor)
	
	stub(executor.access_strategy.save_data).to_call(slow_saver)
	stub(executor.access_strategy.load_data).to_call(slow_loader)
	
	executor.request_saving("", "", {})
	await executor.request_loading("", "", [])
	
	assert_signal_emitted(executor, "loading_started", "Loading started wasn't emitted")

#endregion

#region Signal reading_started

func test_reading_started_signal_is_emitted_with_one_operation() -> void:
	watch_signals(executor)
	
	stub(executor.access_strategy.load_data).to_call(slow_loader)
	
	await executor.request_reading("", "")
	
	assert_signal_emitted(executor, "reading_started", "Reading started wasn't emitted")

func test_reading_started_signal_is_emitted_with_queued_operations() -> void:
	watch_signals(executor)
	
	stub(executor.access_strategy.save_data).to_call(slow_saver)
	stub(executor.access_strategy.load_data).to_call(slow_loader)
	
	executor.request_saving("", "", {})
	await executor.request_reading("", "")
	
	assert_signal_emitted(executor, "reading_started", "Reading started wasn't emitted")

#endregion

#region Signal removing_started

func test_removing_started_signal_is_emitted_with_one_operation() -> void:
	watch_signals(executor)
	
	stub(executor.access_strategy.remove_data).to_call(slow_remover)
	
	await executor.request_removing("", "")
	
	assert_signal_emitted(executor, "removing_started", "Removing started wasn't emitted")

func test_removing_started_signal_is_emitted_with_queued_operations() -> void:
	watch_signals(executor)
	
	stub(executor.access_strategy.save_data).to_call(slow_saver)
	stub(executor.access_strategy.remove_data).to_call(slow_remover)
	
	executor.request_saving("", "", {})
	await executor.request_removing("", "")
	
	assert_signal_emitted(executor, "removing_started", "Removing started wasn't emitted")

#endregion

#region Signal operation_finished

func test_operation_finished_signal_is_emitted_with_one_operation() -> void:
	watch_signals(executor)
	
	stub(executor.access_strategy.save_data).to_call(slow_saver)
	
	await executor.operate(&"save", [ "", "", {} ])
	
	assert_signal_emitted_with_parameters(executor, "operation_finished", [ { "status": Error.OK, "data": "saved" }, &"save" ])

func test_operation_finished_signal_is_emitted_with_queued_operations() -> void:
	watch_signals(executor)
	
	stub(executor.access_strategy.save_data).to_call(slow_saver)
	stub(executor.access_strategy.load_data).to_call(slow_loader)
	
	executor.request_saving("", "", {})
	await executor.request_loading("", "", [])
	
	assert_signal_emitted_with_parameters(executor, "operation_finished", [ { "status": Error.OK, "data": "loaded" }, &"load" ])

#endregion

#region Signal saving_finished

func test_saving_finished_signal_is_emitted_with_one_operation() -> void:
	watch_signals(executor)
	
	stub(executor.access_strategy.save_data).to_call(slow_saver)
	
	await executor.request_saving("", "", {})
	
	assert_signal_emitted_with_parameters(executor, "saving_finished", [ { "status": Error.OK, "data": "saved" } ])

func test_saving_finished_signal_is_emitted_with_queued_operations() -> void:
	watch_signals(executor)
	
	stub(executor.access_strategy.save_data).to_call(slow_saver)
	stub(executor.access_strategy.load_data).to_call(slow_loader)
	
	executor.request_loading("", "", [])
	await executor.request_saving("", "", {})
	
	assert_signal_emitted_with_parameters(executor, "saving_finished", [ { "status": Error.OK, "data": "saved" } ])

#endregion

#region Signal loading_finished

func test_loading_finished_signal_is_emitted_with_one_operation() -> void:
	watch_signals(executor)
	
	stub(executor.access_strategy.load_data).to_call(slow_loader)
	
	await executor.request_loading("", "")
	
	assert_signal_emitted_with_parameters(executor, "loading_finished", [ { "status": Error.OK, "data": "loaded" } ])

func test_loading_finished_signal_is_emitted_with_queued_operations() -> void:
	watch_signals(executor)
	
	stub(executor.access_strategy.save_data).to_call(slow_saver)
	stub(executor.access_strategy.load_data).to_call(slow_loader)
	
	executor.request_saving("", "", {})
	await executor.request_loading("", "", [])
	
	assert_signal_emitted_with_parameters(executor, "loading_finished", [ { "status": Error.OK, "data": "loaded" } ])

#endregion

#region Signal reading_finished

func test_reading_finished_signal_is_emitted_with_one_operation() -> void:
	watch_signals(executor)
	
	stub(executor.access_strategy.load_data).to_call(slow_loader)
	
	await executor.request_reading("", "")
	
	assert_signal_emitted_with_parameters(executor, "reading_finished", [ { "status": Error.OK, "data": "loaded" } ])

func test_reading_finished_signal_is_emitted_with_queued_operations() -> void:
	watch_signals(executor)
	
	stub(executor.access_strategy.save_data).to_call(slow_saver)
	stub(executor.access_strategy.load_data).to_call(slow_loader)
	
	executor.request_saving("", "", {})
	await executor.request_reading("", "")
	
	assert_signal_emitted_with_parameters(executor, "reading_finished", [ { "status": Error.OK, "data": "loaded" } ])

#endregion

#region Signal removing_finished

func test_removing_finished_signal_is_emitted_with_one_operation() -> void:
	watch_signals(executor)
	
	stub(executor.access_strategy.remove_data).to_call(slow_remover)
	
	await executor.request_removing("", "")
	
	assert_signal_emitted_with_parameters(executor, "removing_finished", [ { "status": Error.OK, "data": "removed" } ])

func test_removing_finished_signal_is_emitted_with_queued_operations() -> void:
	watch_signals(executor)
	
	stub(executor.access_strategy.save_data).to_call(slow_saver)
	stub(executor.access_strategy.remove_data).to_call(slow_remover)
	
	executor.request_saving("", "", {})
	await executor.request_removing("", "")
	
	assert_signal_emitted_with_parameters(executor, "removing_finished", [ { "status": Error.OK, "data": "removed" } ])

#endregion

#region Method finish_execution

func test_finish_execution_stops_thread() -> void:
	await executor.finish_execution()
	
	assert_false(executor.thread.is_alive())

#endregion

#region Method create_operation

func test_create_operation_duplicates_by_value() -> void:
	var original_operation: Dictionary = executor.get_operation_by_name(&"save")
	var new_operation: Dictionary = executor.create_operation(&"save", [])
	
	assert_not_same(original_operation, new_operation, "Operation had reference copied")

func test_create_operation_duplicates_entries() -> void:
	var original_operation: Dictionary = executor.get_operation_by_name(&"save")
	var new_operation: Dictionary = executor.create_operation(&"save", [])
	
	assert_eq(original_operation.get(&"start_signal"), new_operation.get(&"start_signal"), "Operation wasn't duplicated properly")
	assert_eq(original_operation.get(&"finish_signal"), new_operation.get(&"finish_signal"), "Operation wasn't duplicated properly")

func test_create_operation_binds_args() -> void:
	var original_operation: Dictionary = executor.get_operation_by_name(&"save")
	var new_operation: Dictionary = executor.create_operation(&"save", [ "a", "b", "c" ])
	
	assert_eq(
		original_operation.get(&"callable").get_method(),
		new_operation.get(&"callable").get_method(),
		"Callable isn't same"
	)
	assert_eq(
		new_operation.get(&"callable").get_bound_arguments(),
		[ "a", "b", "c" ],
		"Operation hadn't args bound"
	)

func test_create_operation_adds_name() -> void:
	var new_operation: Dictionary = executor.create_operation(&"save", [])
	
	assert_eq(
		new_operation.get(&"name"),
		&"save",
		"Operation hadn't right name"
	)

#endregion

#region Method is_busy

func test_executor_knows_its_busy() -> void:
	stub(executor.access_strategy.save_data).to_call(slow_saver)
	
	executor.request_saving("", "", {})
	
	assert_true(executor.is_busy(), "Executor doesn't know it's busy")

#endregion

#region Method is_saving

func test_executor_knows_its_saving() -> void:
	stub(executor.access_strategy.save_data).to_call(slow_saver)
	
	executor.saving_started.connect(
		func(): watcher = executor.is_saving(),
		CONNECT_ONE_SHOT
	)
	await executor.request_saving("", "", {})
	
	assert_true(watcher, "Executor doesn't know it's saving")

#endregion

#region Method is_loading

func test_executor_knows_its_loading() -> void:
	stub(executor.access_strategy.load_data).to_call(slow_loader)
	
	executor.loading_started.connect(
		func(): watcher = executor.is_loading(),
		CONNECT_ONE_SHOT
	)
	await executor.request_loading("", "")
	
	assert_true(watcher, "Executor doesn't know it's loading")

#endregion

#region Method is_reading

func test_executor_knows_its_reading() -> void:
	stub(executor.access_strategy.load_data).to_call(slow_loader)
	
	executor.reading_started.connect(
		func(): watcher = executor.is_reading(),
		CONNECT_ONE_SHOT
	)
	await executor.request_reading("", "")
	
	assert_true(watcher, "Executor doesn't know it's reading")

#endregion

#region Method is_removing

func test_executor_knows_its_removing() -> void:
	stub(executor.access_strategy.remove_data).to_call(slow_remover)
	
	executor.removing_started.connect(
		func(): watcher = executor.is_removing(),
		CONNECT_ONE_SHOT
	)
	await executor.request_removing("", "")
	
	assert_true(watcher, "Executor doesn't know it's removing")

#endregion

#region Method request_saving

func test_request_saving_passes_arguments_to_access_strategy() -> void:
	stub(executor.access_strategy.save_data).to_call(slow_saver)
	
	executor.request_saving("file1", "sav", { "accessor1": "data" })
	
	await wait_for_signal(executor.saving_started, 0.5, "Waiting saving start")
	
	assert_called(
		executor.access_strategy,
		"save_data",
		[ "file1", "sav", { "accessor1": "data" }, false, false ]
	)

#endregion

#region Method request_loading

func test_request_loading_passes_arguments_to_access_strategy() -> void:
	stub(executor.access_strategy.load_data).to_call(slow_loader)
	
	executor.request_loading("file1", "sav")
	
	await wait_for_signal(executor.loading_started, 0.5, "Waiting loading start")
	
	assert_called(
		executor.access_strategy,
		"load_data",
		[ "file1", "sav", [], false ]
	)

#endregion

#region Method request_reading

func test_request_reading_passes_arguments_to_access_strategy() -> void:
	stub(executor.access_strategy.load_data).to_call(slow_loader)
	
	executor.request_reading("file1", "sav")
	
	await wait_for_signal(executor.reading_started, 0.5, "Waiting reading start")
	
	assert_called(
		executor.access_strategy,
		"load_data",
		[ "file1", "sav", [], false ]
	)

#endregion

#region Method request_removing

func test_request_removing_passes_arguments_to_access_strategy() -> void:
	stub(executor.access_strategy.remove_data).to_call(slow_remover)
	
	executor.request_removing("file1", "sav")
	
	await wait_for_signal(executor.removing_started, 0.5, "Waiting removing start")
	
	assert_called(
		executor.access_strategy,
		"remove_data",
		[ "file1", "sav", [], [], [], false ]
	)

#endregion
