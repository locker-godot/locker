
extends GutTest

class StorageAccessorVersionTest extends LokStorageAccessorVersion:
	
	var data_consumed: Dictionary = {}
	
	func retrieve_data(dependencies: Dictionary) -> Dictionary:
		return dependencies
	
	func consume_data(data: Dictionary, dependencies: Dictionary) -> void:
		data_consumed = data.merged(dependencies)
	

var accessor: LokStorageAccessor

func before_each() -> void:
	accessor = autofree(LokStorageAccessor.new())

func after_all() -> void:
	queue_free()

#region General behavior

func test_adds_itself_to_global_manager_on_enter_tree() -> void:
	var other_accessor: LokStorageAccessor = autofree(LokStorageAccessor.new())
	
	var DoubledStorageManager: GDScript = partial_double(
		LokGlobalStorageManager.get_script()
	)
	
	other_accessor.storage_manager = autofree(DoubledStorageManager.new())
	
	add_child(other_accessor)
	
	assert_true(
		other_accessor.storage_manager.accessors.has(other_accessor),
		"Manager didn't have accessor added"
	)

func test_removes_itself_from_global_manager_on_exit_tree() -> void:
	var other_accessor := LokStorageAccessor.new()
	
	var DoubledStorageManager: GDScript = partial_double(
		LokGlobalStorageManager.get_script()
	)
	
	var storage_manager: LokGlobalStorageManager = DoubledStorageManager.new()
	
	other_accessor.storage_manager = storage_manager
	
	add_child(other_accessor)
	other_accessor.queue_free()
	
	await wait_frames(1, "Waiting accessor to be freed")
	
	assert_eq(
		storage_manager.accessors,
		[],
		"Manager didn't have accessor removed"
	)

#endregion

#region Property versions

func test_versions_starts_empty() -> void:
	assert_eq(accessor.versions, [], "Version didn't start as expected")

func test_versions_setter_updates_version() -> void:
	var version: LokStorageAccessorVersion = LokStorageAccessorVersion.create(
		"1.0.0"
	)
	
	accessor.versions = [ version ]
	
	assert_eq(
		accessor.version,
		version,
		"Versions didn't update version"
	)

#endregion

#region Property version_number

func test_version_number_starts_as_1_0_0() -> void:
	assert_eq(
		accessor.version_number,
		"1.0.0",
		"Version number didn't start as expected"
	)

func test_version_number_setter_updates_version() -> void:
	accessor.version_number = ""
	
	var version: LokStorageAccessorVersion = LokStorageAccessorVersion.create(
		"1.0.0"
	)
	
	accessor.versions = [ version ]
	
	accessor.version_number = "1.0.0"
	
	assert_eq(
		accessor.version,
		version,
		"Version_number didn't update version"
	)

func test_version_number_setter_updates_version_only_on_change() -> void:
	var version: LokStorageAccessorVersion = LokStorageAccessorVersion.create(
		"1.0.0"
	)
	
	accessor.versions.append(version)
	
	accessor.version_number = "1.0.0"
	
	assert_null(
		accessor.version,
		"Version didn't stay unupdated"
	)

#endregion

#region Property dependency_paths

func test_dependency_paths_starts_empty() -> void:
	assert_eq(
		accessor.dependency_paths,
		{},
		"Dependency_paths didn't start as expected"
	)

#endregion

#region Property version

func test_version_starts_null() -> void:
	assert_null(
		accessor.version,
		"Version didn't start as expected"
	)

func test_version_setter_disconnects_previous_version() -> void:
	var version1 := LokStorageAccessorVersion.create(
		"1.0.0"
	)
	var version2 := LokStorageAccessorVersion.create(
		"2.0.0"
	)
	
	accessor.version = version1
	accessor.version = version2
	
	assert_not_connected(
		version1, accessor, "id_changed", "_on_version_id_changed"
	)

func test_version_setter_connects_next_version() -> void:
	var version := LokStorageAccessorVersion.create(
		"1.0.0"
	)
	
	accessor.version = version
	
	assert_connected(
		version, accessor, "id_changed", "_on_version_id_changed"
	)

func test_version_id_changes_propagate() -> void:
	var version := LokStorageAccessorVersion.create(
		"1.0.0"
	)
	
	watch_signals(accessor)
	
	accessor.version = version
	
	version.id = "2"
	
	assert_signal_emitted_with_parameters(
		accessor, "id_changed", [ "1", "2" ]
	)

#endregion

#region Method get_id

func test_get_id_returns_empty_string_without_version() -> void:
	assert_eq(
		accessor.get_id(),
		"",
		"Get_id didn't return expected value"
	)

func test_get_id_returns_version_id() -> void:
	accessor.version = LokStorageAccessorVersion.create(
		"1.0.0"
	)
	
	assert_eq(
		accessor.get_id(),
		"1",
		"Get_id didn't return expected value"
	)

#endregion

#region Method find_version

func test_find_version_returns_matching_version() -> void:
	var version := LokStorageAccessorVersion.create("1.0.0")
	
	accessor.versions = [ version ]
	
	assert_eq(
		accessor.find_version("1.0.0"),
		version,
		"Find_version didn't return expected value"
	)

func test_find_version_uses_version_number_by_default() -> void:
	var version := LokStorageAccessorVersion.create("1.0.0")
	
	accessor.versions = [ version ]
	accessor.version_number = "1.0.0"
	
	assert_eq(
		accessor.find_version("1.0.0"),
		version,
		"Find_version didn't return expected value"
	)

func test_find_version_returns_null_if_not_found() -> void:
	assert_null(
		accessor.find_version("1.0.0"),
		"Find_version didn't return expected value"
	)

#endregion

#region Method select_version

func test_select_version_returns_true_on_success() -> void:
	var version := LokStorageAccessorVersion.create("1.0.0")
	
	accessor.versions = [ version ]
	
	assert_true(
		accessor.select_version("1.0.0"),
		"Select_version didn't return expected value"
	)

func test_select_version_returns_false_if_not_found() -> void:
	assert_false(
		accessor.select_version("1.0.0"),
		"Select_version didn't return expected value"
	)

#endregion

#region Method get_dependencies

func test_get_dependencies_returns_nodes_instead_of_paths() -> void:
	var DoubledManager: GDScript = double(LokGlobalStorageManager.get_script())
	
	accessor.storage_manager = DoubledManager.new()
	add_child(accessor)
	
	accessor.dependency_paths = {
		"test": self.get_path()
	}
	
	assert_eq(
		accessor.get_dependencies(),
		{ "test": self },
		"Get_dependencies didn't return expected value"
	)

#endregion

#region Method save_data

func test_save_data_delegates_to_global_manager() -> void:
	var DoubledManager = double(LokGlobalStorageManager.get_script())
	
	accessor.storage_manager = DoubledManager.new()
	
	accessor.save_data(
		"1", "1.0.0"
	)
	
	assert_called(
		accessor.storage_manager,
		"save_data",
		[ "1", "1.0.0", [ accessor.get_id() ], false ]
	)

#endregion

#region Method load_data

func test_load_data_delegates_to_global_manager() -> void:
	var DoubledManager = double(LokGlobalStorageManager.get_script())
	
	accessor.storage_manager = DoubledManager.new()
	
	accessor.load_data("1")
	
	assert_called(
		accessor.storage_manager,
		"load_data",
		[ "1", [ accessor.get_id() ], [], [] ]
	)

#endregion

#region Method retrieve_data

func test_retrieve_data_returns_empty_dictionary_without_version() -> void:
	assert_eq(
		accessor.retrieve_data(),
		{},
		"Retrieve_data didn't return expected value"
	)

func test_retrieve_data_delegates_to_version() -> void:
	var version := StorageAccessorVersionTest.new()
	var DoubledManager: GDScript = double(LokGlobalStorageManager.get_script())
	
	accessor.storage_manager = DoubledManager.new()
	accessor.version = version
	add_child(accessor)
	accessor.dependency_paths = { "accessor": accessor.get_path() }
	
	assert_eq(
		accessor.retrieve_data(),
		{ "accessor": accessor },
		"Retrieve_data didn't return expected value"
	)

#endregion

#region Method consume_data

func test_consume_data_delegates_to_version() -> void:
	var version := StorageAccessorVersionTest.new()
	var DoubledManager: GDScript = double(LokGlobalStorageManager.get_script())
	
	accessor.storage_manager = DoubledManager.new()
	accessor.version = version
	add_child(accessor)
	accessor.dependency_paths = { "accessor": accessor.get_path() }
	
	accessor.consume_data({ "data": "something" })
	
	assert_eq(
		accessor.version.data_consumed,
		{ "accessor": accessor, "data": "something" },
		"Consume_data didn't return expected value"
	)

#endregion
