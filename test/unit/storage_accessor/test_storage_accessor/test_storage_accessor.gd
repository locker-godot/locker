
extends GutTest

var StorageAccessor: GDScript = preload("res://addons/locker/scripts/storage_accessor/storage_accessor.gd")
var StorageManager: GDScript = preload("res://addons/locker/scripts/storage_manager/storage_manager.gd")
var StorageAccessorVersion: GDScript = preload("res://addons/locker/scripts/storage_accessor/storage_accessor_version.gd")
var DoubledStorageManager: GDScript
var DoubledStorageAccessorVersion: GDScript

var accessor: LokStorageAccessor

func before_all() -> void:
	DoubledStorageManager = partial_double(StorageManager)
	DoubledStorageAccessorVersion = partial_double(StorageAccessorVersion)

func before_each() -> void:
	accessor = add_child_autofree(StorageAccessor.new())
	accessor._storage_manager = add_child_autofree(DoubledStorageManager.new())

func after_all() -> void:
	queue_free()

#region General behavior

func test_storage_manager_starts_as_the_autoload() -> void:
	var new_accessor: LokStorageAccessor = add_child_autofree(
		LokStorageAccessor.new()
	)
	
	assert_eq(
		new_accessor._storage_manager,
		LokGlobalStorageManager,
		"Value didn't match expected"
	)

func test_storage_accessor_autoappends_to_global_manager() -> void:
	var new_accessor: LokStorageAccessor = add_child_autofree(
		LokStorageAccessor.new()
	)
	
	assert_true(
		LokGlobalStorageManager.accessors.has(new_accessor),
		"Accessor not found in Global Manager"
	)

func test_storage_accessor_autoremoves_from_global_manager() -> void:
	var new_accessor: LokStorageAccessor = LokStorageAccessor.new()
	
	add_child(new_accessor)
	
	new_accessor.free()
	
	assert_false(
		LokGlobalStorageManager.accessors.has(new_accessor),
		"Accessor found in Global Manager"
	)

#endregion

#region Signals

func test_saving_started_is_emitted() -> void:
	watch_signals(accessor)
	
	accessor.save_data()
	
	assert_signal_emitted(accessor, "saving_started", "Signal not emitted")

func test_loading_started_is_emitted() -> void:
	watch_signals(accessor)
	
	accessor.load_data()
	
	assert_signal_emitted(accessor, "loading_started", "Signal not emitted")

func test_removing_started_is_emitted() -> void:
	watch_signals(accessor)
	
	accessor.remove_data()
	
	assert_signal_emitted(accessor, "removing_started", "Signal not emitted")

func test_saving_finished_is_emitted() -> void:
	watch_signals(accessor)
	
	accessor.save_data()
	
	assert_signal_emitted(accessor, "saving_finished", "Signal not emitted")

func test_loading_finished_is_emitted() -> void:
	watch_signals(accessor)
	
	accessor.load_data()
	
	assert_signal_emitted(accessor, "loading_finished", "Signal not emitted")

func test_removing_finished_is_emitted() -> void:
	watch_signals(accessor)
	
	accessor.remove_data()
	
	assert_signal_emitted(accessor, "removing_finished", "Signal not emitted")

#endregion

#region Properties

func test_version_number_updates_version() -> void:
	var version := LokStorageAccessorVersion.create("2.0.0")
	
	accessor.versions.append(version)
	
	accessor.version_number = "2.0.0"
	
	assert_eq(accessor._version, version, "Version didn't match expected")

func test_version_number_converts_to_latest() -> void:
	var version := LokStorageAccessorVersion.create("2.0.0")
	
	accessor.versions.append(version)
	
	accessor.version_number = ""
	
	assert_eq(accessor.version_number, "2.0.0", "Version number didn't update")

func test_versions_updates_version() -> void:
	var version := LokStorageAccessorVersion.create("1.0.0")
	
	accessor.versions = [ version ]
	
	assert_eq(accessor._version, version, "Version didn't match expected")

#endregion

#region General methods

func test_get_dependencies_parses_node_paths() -> void:
	var dep: Node = add_child_autofree(Node.new())
	var dep_path: NodePath = dep.get_path()
	
	accessor.dependency_paths[&"dep"] = dep_path
	
	var expected: Dictionary = { &"dep": dep }
	var deps: Dictionary = accessor._get_dependencies()
	
	assert_eq(deps, expected, "Dependencies weren't parsed")

func test_find_version_returns_right_version() -> void:
	var version := LokStorageAccessorVersion.create("2.0.0")
	
	accessor.versions.append(version)
	
	assert_eq(accessor._find_version("2.0.0"), version, "Version not found")

func test_find_version_returns_null() -> void:
	assert_eq(accessor._find_version("2.0.0"), null, "Version found")

func test_find_latest_version_returns_right_version() -> void:
	var version1 := LokStorageAccessorVersion.create("1.0.0")
	var version2 := LokStorageAccessorVersion.create("2.0.0")
	
	accessor.versions = [ version1, version2 ]
	
	assert_eq(accessor._find_latest_version(), version2, "Version not found")

func test_find_latest_version_returns_null() -> void:
	assert_eq(accessor._find_latest_version(), null, "Version found")

func test_select_version_returns_true() -> void:
	var version := LokStorageAccessorVersion.create("1.0.0")
	
	accessor.versions.append(version)
	
	assert_true(accessor.select_version("1.0.0"), "Version not found")

func test_select_version_returns_false() -> void:
	assert_false(accessor.select_version("1.0.0"), "Version found")

#endregion

#region Method save_data

func test_save_data_defaults_file_to_class_property() -> void:
	accessor.file = "accessor_file"
	
	accessor.save_data()
	
	assert_called(
		accessor._storage_manager, "save_data",
		[ "accessor_file", "", [ accessor ], false ]
	)

func test_save_data_prioritizes_passed_file() -> void:
	accessor.file = "other_file"
	
	accessor.save_data("accessor_file")
	
	assert_called(
		accessor._storage_manager, "save_data",
		[ "accessor_file", "", [ accessor ], false ]
	)

func test_save_data_cancels_without_storage_manager() -> void:
	accessor._storage_manager = null
	
	assert_eq(await accessor.save_data(), {}, "Save data didn't cancel")

func test_save_data_cancels_if_not_active() -> void:
	accessor.active = false
	
	assert_eq(await accessor.save_data(), {}, "Save data didn't cancel")

#endregion

#region Method load_data

func test_load_data_defaults_file_to_class_property() -> void:
	accessor.file = "accessor_file"
	
	accessor.load_data()
	
	assert_called(
		accessor._storage_manager, "load_data",
		[ "accessor_file", [ accessor ], [ accessor.partition ], [] ]
	)

func test_load_data_prioritizes_passed_file() -> void:
	accessor.file = "other_file"
	
	accessor.load_data("accessor_file")
	
	assert_called(
		accessor._storage_manager, "load_data",
		[ "accessor_file", [ accessor ], [ accessor.partition ], [] ]
	)

func test_load_data_cancels_without_storage_manager() -> void:
	accessor._storage_manager = null
	
	assert_eq(await accessor.load_data(), {}, "Load data didn't cancel")

func test_load_data_cancels_if_not_active() -> void:
	accessor.active = false
	
	assert_eq(await accessor.load_data(), {}, "Load data didn't cancel")

#endregion

#region Method remove_data

func test_remove_data_defaults_file_to_class_property() -> void:
	accessor.file = "accessor_file"
	
	accessor.remove_data()
	
	assert_called(
		accessor._storage_manager, "remove_data",
		[ "accessor_file", [ accessor ], [ accessor.partition ], [] ]
	)

func test_remove_data_prioritizes_passed_file() -> void:
	accessor.file = "other_file"
	
	accessor.remove_data("accessor_file")
	
	assert_called(
		accessor._storage_manager, "remove_data",
		[ "accessor_file", [ accessor ], [ accessor.partition ], [] ]
	)

func test_remove_data_cancels_without_storage_manager() -> void:
	accessor._storage_manager = null
	
	assert_eq(await accessor.remove_data(), {}, "Remove data didn't cancel")

func test_remove_data_cancels_if_not_active() -> void:
	accessor.active = false
	
	assert_eq(await accessor.remove_data(), {}, "Remove data didn't cancel")

#endregion

#region Method retrieve_data

func test_retrieve_data_cancels_without_version() -> void:
	assert_eq(await accessor.retrieve_data(), {}, "Retrieval didn't cancel")

func test_retrieve_data_cancels_if_inactive() -> void:
	var version := LokStorageAccessorVersion.create("1.0.0")
	
	accessor.versions = [ version ]
	accessor.active = false
	
	assert_eq(await accessor.retrieve_data(), {}, "Retrieval didn't cancel")

func test_retrieve_data_consults_version() -> void:
	var version: LokStorageAccessorVersion = DoubledStorageAccessorVersion.new()
	
	var expected: Dictionary = { "success": true }
	
	stub(version._retrieve_data).to_return(expected)
	
	accessor.versions = [ version ]
	
	assert_eq(await accessor.retrieve_data(), expected, "Return wasn't expected")

func test_retrieve_data_passes_dependencies_to_version() -> void:
	var version: LokStorageAccessorVersion = DoubledStorageAccessorVersion.new()
	
	var dep: Node = add_child_autofree(Node.new())
	var dep_path: NodePath = dep.get_path()
	
	var expected: Dictionary = { "success": true }
	
	stub(version._retrieve_data).to_return(expected).when_passed({ &"dep": dep })
	
	accessor.versions = [ version ]
	accessor.dependency_paths = { &"dep": dep_path }
	
	assert_eq(await accessor.retrieve_data(), expected, "Dependencies weren't passed")

func test_retrieve_data_awaits_async_versions() -> void:
	var version: LokStorageAccessorVersion = DoubledStorageAccessorVersion.new()
	
	var expected: Dictionary = { "success": true }
	
	stub(version._retrieve_data).to_call(
		func(_deps: Dictionary) -> Dictionary:
			await get_tree().create_timer(0.01).timeout
			
			return expected
	)
	
	accessor.versions = [ version ]
	
	assert_eq(
		await accessor.retrieve_data(),
		expected,
		"Data retrieval wasn't awaited"
	)

#endregion

#region Method consume_data

func test_consume_data_cancels_if_inactive() -> void:
	var version: LokStorageAccessorVersion = DoubledStorageAccessorVersion.new()
	
	accessor.versions = [ version ]
	accessor.active = false
	
	accessor.consume_data({})
	
	assert_not_called(version, "_consume_data")

func test_consume_data_consults_version() -> void:
	var version: LokStorageAccessorVersion = DoubledStorageAccessorVersion.new()
	
	accessor.versions = [ version ]
	
	accessor.consume_data({})
	
	assert_called(version, "_consume_data")

func test_consume_data_passes_args_to_version() -> void:
	var version: LokStorageAccessorVersion = DoubledStorageAccessorVersion.new()
	
	var dep: Node = add_child_autofree(Node.new())
	var dep_path: NodePath = dep.get_path()
	
	accessor.versions = [ version ]
	accessor.dependency_paths = { &"dep": dep_path }
	
	var data: Dictionary = { "data": true }
	var deps: Dictionary = { &"dep": dep }
	
	accessor.consume_data(data)
	
	assert_called(version, "_consume_data", [ data, deps ])

func test_consume_data_awaits_async_versions() -> void:
	var version: LokStorageAccessorVersion = DoubledStorageAccessorVersion.new()
	
	var result: Dictionary = {}
	var expected: Dictionary = { "awaited": true }
	
	stub(version._consume_data).to_call(
		func(_res: Dictionary, _deps: Dictionary) -> void:
			await get_tree().create_timer(0.01).timeout
			
			result["awaited"] = true
	)
	
	accessor.versions = [ version ]
	
	await accessor.consume_data({})
	
	assert_eq(
		result,
		expected,
		"Data consumption wasn't awaited"
	)

#endregion
