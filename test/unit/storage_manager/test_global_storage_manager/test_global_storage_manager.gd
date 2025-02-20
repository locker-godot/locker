
extends GutTest

var GlobalStorageManager: GDScript = preload("res://addons/locker/scripts/storage_manager/global_storage_manager.gd")
var StorageAccessor: GDScript = preload("res://addons/locker/scripts/storage_accessor/storage_accessor.gd")
var AccessExecutor: GDScript = preload("res://addons/locker/scripts/storage_manager/access_executor.gd")
var DoubledStorageAccessor: GDScript
var DoubledAccessExecutor: GDScript

var manager := LokGlobalStorageManager

func before_all() -> void:
	DoubledStorageAccessor = partial_double(StorageAccessor)
	DoubledAccessExecutor = double(AccessExecutor)

func before_each() -> void:
	manager = add_child_autofree(GlobalStorageManager.new())
	
	stub(DoubledAccessExecutor, "request_loading").to_return({})
	stub(DoubledAccessExecutor, "request_get_file_ids").to_return({})

func after_all() -> void:
	queue_free()

#region General behavior

func test_initializes_with_project_settings() -> void:
	var expected_saves_directory: String = LockerPlugin.get_setting_saves_directory()
	var expected_save_files_prefix: String = LockerPlugin.get_setting_save_files_prefix()
	var expected_save_files_format: String = LockerPlugin.get_setting_save_files_format()
	var expected_save_versions: bool = LockerPlugin.get_setting_save_versions()
	var expected_access_strategy: String = LockerPlugin.get_setting_access_strategy()
	var expected_encrypted_strategy_password: String = LockerPlugin.get_setting_encrypted_strategy_password()
	
	var saves_directory: String = manager.get_saves_directory()
	var save_files_prefix: String = manager.get_save_files_prefix()
	var save_files_format: String = manager.get_save_files_format()
	var save_versions: bool = manager.get_save_versions()
	var access_strategy: LokAccessStrategy = manager.get_access_strategy()
	var encrypted_strategy_password: String = ""
	
	if access_strategy.get(&"password") != null:
		encrypted_strategy_password = access_strategy.get(&"password")
	
	assert_eq(saves_directory, expected_saves_directory, "Unexpected value")
	assert_eq(save_files_prefix, expected_save_files_prefix, "Unexpected value")
	assert_eq(save_files_format, expected_save_files_format, "Unexpected value")
	assert_eq(save_versions, expected_save_versions, "Unexpected value")
	assert_eq(LockerPlugin.strategy_to_string(access_strategy), expected_access_strategy, "Unexpected value")
	
	if expected_access_strategy == "Encrypted":
		assert_eq(encrypted_strategy_password, expected_encrypted_strategy_password, "Unexpected value")

#endregion

#region Method get_file_path

func test_get_file_path_returns_default_path() -> void:
	manager.saves_directory = "res://tests/saves/"
	manager.save_files_prefix = "file"
	
	var expected: String = "res://tests/saves/file"
	
	assert_eq(manager.get_file_path(""), expected, "Unexpected result")

func test_get_file_path_returns_path_based_on_id() -> void:
	manager.saves_directory = "res://tests/saves/"
	manager.save_files_prefix = "file"
	
	var expected: String = "res://tests/saves/file_1"
	
	assert_eq(manager.get_file_path("1"), expected, "Unexpected result")

#endregion

#region Method collect_data

func test_collect_data_returns_empty_dict() -> void:
	var expected: Dictionary = {}
	
	assert_eq(manager.collect_data(null, ""), expected, "Unexpected result")

func test_collect_data_returns_sets_version_passed() -> void:
	var expected: String = "2.0.0"
	
	var accessor: LokStorageAccessor = DoubledStorageAccessor.new()
	
	manager.collect_data(accessor, "2.0.0")
	
	assert_eq(accessor.version_number, expected, "Unexpected result")

func test_collect_data_obtains_data_without_version() -> void:
	manager.set_save_versions(false)
	
	var expected: Dictionary = { "retrieved": true }
	
	var accessor: LokStorageAccessor = DoubledStorageAccessor.new()
	stub(accessor.retrieve_data).to_return(expected.duplicate())
	
	var result: Dictionary = manager.collect_data(accessor, "1.0.0")
	
	assert_eq(result, expected, "Unexpected result")

func test_collect_data_obtains_data_with_version() -> void:
	manager.set_save_versions(true)
	
	var expected: Dictionary = { "retrieved": true }
	
	var accessor: LokStorageAccessor = DoubledStorageAccessor.new()
	stub(accessor.retrieve_data).to_return(expected.duplicate())
	
	expected["version"] = "1.0.0"
	
	var result: Dictionary = manager.collect_data(accessor, "1.0.0")
	
	assert_eq(result, expected, "Unexpected result")

#endregion

#region Method gather_data

func test_gather_data_ignores_unidentified_accessors() -> void:
	var accessor: LokStorageAccessor = DoubledStorageAccessor.new()
	stub(accessor.retrieve_data).to_return({ "accessor": true })
	
	var result: Dictionary = manager.gather_data()
	
	assert_eq(result, {}, "Data obtained")

func test_gather_data_includes_identified_accessors() -> void:
	manager.set_save_versions(false)
	
	var accessor_data: Dictionary = { "accessor": true }
	
	var accessor: LokStorageAccessor = DoubledStorageAccessor.new()
	accessor.id = "accessor"
	stub(accessor.retrieve_data).to_return(accessor_data.duplicate())
	
	manager.add_accessor(accessor)
	
	var expected: Dictionary = {
		accessor.partition: {
			accessor.id: accessor_data
		}
	}
	
	var result: Dictionary = manager.gather_data([], "1.0.0")
	
	assert_eq(result, expected, "Data obtained")

func test_gather_data_includes_versions() -> void:
	manager.set_save_versions(true)
	
	var accessor_data: Dictionary = { "accessor": true }
	
	var accessor: LokStorageAccessor = DoubledStorageAccessor.new()
	accessor.id = "accessor"
	stub(accessor.retrieve_data).to_return(accessor_data.duplicate())
	
	manager.add_accessor(accessor)
	
	var expected: Dictionary = {
		accessor.partition: {
			accessor.id: accessor_data.merged({ "version": "1.0.0" })
		}
	}
	
	var result: Dictionary = manager.gather_data([], "1.0.0")
	
	assert_eq(result, expected, "Data obtained")

func test_gather_data_gets_from_multiple_accessors() -> void:
	manager.set_save_versions(false)
	
	var accessor1_data: Dictionary = { "accessor1": true }
	var accessor2_data: Dictionary = { "accessor2": true }
	
	var accessor1: LokStorageAccessor = DoubledStorageAccessor.new()
	accessor1.id = "accessor1"
	accessor1.partition = "partition"
	stub(accessor1.retrieve_data).to_return(accessor1_data.duplicate())
	var accessor2: LokStorageAccessor = DoubledStorageAccessor.new()
	accessor2.id = "accessor2"
	accessor2.partition = "partition"
	stub(accessor2.retrieve_data).to_return(accessor2_data.duplicate())
	
	manager.add_accessor(accessor1)
	manager.add_accessor(accessor2)
	
	var expected: Dictionary = {
		"partition": {
			accessor1.id: accessor1_data,
			accessor2.id: accessor2_data
		}
	}
	
	var result: Dictionary = manager.gather_data([], "1.0.0")
	
	assert_eq(result, expected, "Data obtained")

func test_gather_data_filters_accessors() -> void:
	manager.set_save_versions(false)
	
	var accessor1_data: Dictionary = { "accessor1": true }
	var accessor2_data: Dictionary = { "accessor2": true }
	
	var accessor1: LokStorageAccessor = DoubledStorageAccessor.new()
	accessor1.id = "accessor1"
	accessor1.partition = "partition"
	stub(accessor1.retrieve_data).to_return(accessor1_data.duplicate())
	var accessor2: LokStorageAccessor = DoubledStorageAccessor.new()
	accessor2.id = "accessor2"
	accessor2.partition = "partition"
	stub(accessor2.retrieve_data).to_return(accessor2_data.duplicate())
	
	manager.add_accessor(accessor1)
	manager.add_accessor(accessor2)
	
	var expected: Dictionary = {
		"partition": {
			accessor1.id: accessor1_data
		}
	}
	
	var result: Dictionary = manager.gather_data([ accessor1 ], "1.0.0")
	
	assert_eq(result, expected, "Data obtained")

func test_gather_data_separates_partitions() -> void:
	manager.set_save_versions(false)
	
	var accessor1_data: Dictionary = { "accessor1": true }
	var accessor2_data: Dictionary = { "accessor2": true }
	
	var accessor1: LokStorageAccessor = DoubledStorageAccessor.new()
	accessor1.id = "accessor1"
	accessor1.partition = "partition1"
	stub(accessor1.retrieve_data).to_return(accessor1_data.duplicate())
	var accessor2: LokStorageAccessor = DoubledStorageAccessor.new()
	accessor2.id = "accessor2"
	accessor2.partition = "partition2"
	stub(accessor2.retrieve_data).to_return(accessor2_data.duplicate())
	
	manager.add_accessor(accessor1)
	manager.add_accessor(accessor2)
	
	var expected: Dictionary = {
		accessor1.partition: {
			accessor1.id: accessor1_data
		},
		accessor2.partition: {
			accessor2.id: accessor2_data
		}
	}
	
	var result: Dictionary = manager.gather_data([], "1.0.0")
	
	assert_eq(result, expected, "Data obtained")

func test_gather_data_ignores_accessors_without_data() -> void:
	var accessor: LokStorageAccessor = DoubledStorageAccessor.new()
	stub(accessor.retrieve_data).to_return({})
	
	var result: Dictionary = manager.gather_data()
	
	assert_eq(result, {}, "Data obtained")

#endregion

#region Method distribute_result

func test_distribute_result_passes_to_accessors() -> void:
	var accessor: LokStorageAccessor = DoubledStorageAccessor.new()
	
	manager.add_accessor(accessor)
	
	manager.distribute_result({})
	
	assert_called(accessor, "consume_data")

func test_distribute_result_filters_accessors() -> void:
	var accessor1: LokStorageAccessor = DoubledStorageAccessor.new()
	var accessor2: LokStorageAccessor = DoubledStorageAccessor.new()
	
	manager.add_accessor(accessor1)
	manager.add_accessor(accessor2)
	
	manager.distribute_result({}, [ accessor1 ])
	
	assert_not_called(accessor2, "consume_data")

func test_distribute_result_sets_version_number() -> void:
	var accessor: LokStorageAccessor = DoubledStorageAccessor.new()
	accessor.id = "accessor"
	
	manager.add_accessor(accessor)
	
	manager.distribute_result({
		"status": Error.OK,
		"data": {
			"accessor": {
				"version": "2.0.0"
			}
		}
	})
	
	assert_eq(accessor.version_number, "2.0.0", "Version didn't match")

func test_distribute_result_sends_according_to_ids() -> void:
	var accessor1: LokStorageAccessor = DoubledStorageAccessor.new()
	accessor1.id = "accessor1"
	var accessor2: LokStorageAccessor = DoubledStorageAccessor.new()
	accessor2.id = "accessor2"
	
	manager.add_accessor(accessor1)
	manager.add_accessor(accessor2)
	
	var accessor1_data: Dictionary = { "accessor1": true }
	var accessor2_data: Dictionary = { "accessor2": true }
	
	manager.distribute_result({
		"status": Error.OK,
		"data": {
			"accessor1": accessor1_data.duplicate(),
			"accessor2": accessor2_data.duplicate(),
		}
	})
	
	accessor1_data = { "status": Error.OK, "data": accessor1_data }
	accessor2_data = { "status": Error.OK, "data": accessor2_data }
	
	assert_called(accessor1, "consume_data", [ accessor1_data ])
	assert_called(accessor2, "consume_data", [ accessor2_data ])

#endregion

#region Method get_saved_files_ids

func test_get_saved_files_ids_passes_to_executor() -> void:
	manager.access_executor = DoubledAccessExecutor.new()
	
	manager.get_saved_files_ids()
	
	assert_called(manager.access_executor, "request_get_file_ids")

#endregion

#region Method save_data

func test_save_data_passes_to_executor() -> void:
	manager.access_executor = DoubledAccessExecutor.new()
	
	manager.save_data()
	
	assert_called(manager.access_executor, "request_saving")

func test_save_data_emits_saving_started() -> void:
	watch_signals(manager)
	
	manager.access_executor = DoubledAccessExecutor.new()
	
	manager.save_data()
	
	assert_signal_emitted(manager, "saving_started", "Signal not emitted")

func test_save_data_emits_saving_finished() -> void:
	watch_signals(manager)
	
	manager.access_executor = DoubledAccessExecutor.new()
	
	manager.save_data()
	
	assert_signal_emitted(manager, "saving_finished", "Signal not emitted")

#endregion

#region Method load_data

func test_load_data_passes_to_executor() -> void:
	manager.access_executor = DoubledAccessExecutor.new()
	
	manager.load_data()
	
	assert_called(manager.access_executor, "request_loading")

func test_save_data_emits_loading_started() -> void:
	watch_signals(manager)
	
	manager.access_executor = DoubledAccessExecutor.new()
	
	manager.load_data()
	
	assert_signal_emitted(manager, "loading_started", "Signal not emitted")

func test_save_data_emits_loading_finished() -> void:
	watch_signals(manager)
	
	manager.access_executor = DoubledAccessExecutor.new()
	
	manager.load_data()
	
	assert_signal_emitted(manager, "loading_finished", "Signal not emitted")

#endregion

#region Method read_data

func test_read_data_passes_to_executor() -> void:
	manager.access_executor = DoubledAccessExecutor.new()
	
	manager.read_data()
	
	assert_called(manager.access_executor, "request_loading")

func test_read_data_emits_reading_started() -> void:
	watch_signals(manager)
	
	manager.access_executor = DoubledAccessExecutor.new()
	
	manager.read_data()
	
	assert_signal_emitted(manager, "reading_started", "Signal not emitted")

func test_read_data_emits_reading_finished() -> void:
	watch_signals(manager)
	
	manager.access_executor = DoubledAccessExecutor.new()
	
	manager.read_data()
	
	assert_signal_emitted(manager, "reading_finished", "Signal not emitted")

#endregion

#region Method remove_data

func test_remove_data_passes_to_executor() -> void:
	manager.access_executor = DoubledAccessExecutor.new()
	
	manager.remove_data()
	
	assert_called(manager.access_executor, "request_removing")

func test_save_data_emits_removing_started() -> void:
	watch_signals(manager)
	
	manager.access_executor = DoubledAccessExecutor.new()
	
	manager.remove_data()
	
	assert_signal_emitted(manager, "removing_started", "Signal not emitted")

func test_save_data_emits_removing_finished() -> void:
	watch_signals(manager)
	
	manager.access_executor = DoubledAccessExecutor.new()
	
	manager.remove_data()
	
	assert_signal_emitted(manager, "removing_finished", "Signal not emitted")

#endregion
