
extends GutTest

class StorageAccessorTest extends LokStorageAccessor:
	
	var id: String = ""
	
	var data: Dictionary = {}
	
	func consume_data(_data: Dictionary) -> void:
		data = _data
	

var GlobalStorageManager: GDScript = preload("res://addons/locker/storage_manager/global_storage_manager.gd")
var DoubledGlobalStorageManager: GDScript
var StorageAccessor: GDScript = preload("res://addons/locker/storage_accessor/storage_accessor.gd")
var AccessStrategy: GDScript = preload("res://addons/locker/access_strategy/access_strategy.gd")

var manager: LokStorageManager

func before_all() -> void:
	register_inner_classes(get_script())
	
	DoubledGlobalStorageManager = partial_double(GlobalStorageManager)

func before_each() -> void:
	manager = add_child_autofree(DoubledGlobalStorageManager.new())
	stub(manager.get_debug_mode).to_return(false)

func after_all() -> void:
	queue_free()

#region Property access_strategy

func test_access_strategy_starts_as_not_null() -> void:
	assert_not_null(
		manager.access_strategy,
		"Access strategy start as null"
	)

#endregion

#region Method add_accessor

func test_add_accessor_registers_in_the_list() -> void:
	var accessor: LokStorageAccessor = autofree(LokStorageAccessor.new())
	
	manager.add_accessor(accessor)
	
	assert_eq(
		manager.accessors.back(),
		accessor,
		"Accessor wasn't added"
	)

func test_add_accessor_connects_signal() -> void:
	var accessor: LokStorageAccessor = autofree(LokStorageAccessor.new())
	
	manager.add_accessor(accessor)
	
	assert_connected(
		accessor,
		manager,
		"id_changed",
		"_on_accessor_id_changed"
	)

#endregion

#region Method remove_accessor

func test_remove_accessor_removes_from_the_list() -> void:
	var accessor: LokStorageAccessor = autofree(LokStorageAccessor.new())
	
	manager.add_accessor(accessor)
	manager.remove_accessor(accessor)
	
	assert_true(
		manager.accessors.is_empty(),
		"Accessor wasn't removed"
	)

func test_remove_accessor_disconnects_signal() -> void:
	var accessor: LokStorageAccessor = autofree(LokStorageAccessor.new())
	
	manager.add_accessor(accessor)
	manager.remove_accessor(accessor)
	
	assert_not_connected(
		accessor,
		manager,
		"id_changed",
		"_on_accessor_id_changed"
	)

func test_remove_returns_true_on_success() -> void:
	var accessor: LokStorageAccessor = autofree(LokStorageAccessor.new())
	
	manager.add_accessor(accessor)
	
	assert_true(
		manager.remove_accessor(accessor),
		"Returned false with an expected success"
	)

func test_remove_returns_false_on_failure() -> void:
	var accessor: LokStorageAccessor = autofree(LokStorageAccessor.new())
	
	assert_false(
		manager.remove_accessor(accessor),
		"Returned true with an expected failure"
	)

#endregion

#region Method get_accessors_grouped_by_id

func test_get_accessors_grouped_by_id_works_properly() -> void:
	var DoubledStorageAccessor: GDScript = double(StorageAccessor)
	
	var accessor1: LokStorageAccessor = autofree(DoubledStorageAccessor.new())
	stub(accessor1.get_id).to_return("id1")
	var accessor2: LokStorageAccessor = autofree(DoubledStorageAccessor.new())
	stub(accessor2.get_id).to_return("id1")
	var accessor3: LokStorageAccessor = autofree(DoubledStorageAccessor.new())
	stub(accessor3.get_id).to_return("id2")
	
	manager.add_accessor(accessor1)
	manager.add_accessor(accessor2)
	manager.add_accessor(accessor3)
	
	var expected: Dictionary = {
		"id1": [ accessor1, accessor2 ],
		"id2": [ accessor3 ]
	}
	
	assert_eq(
		manager.get_accessors_grouped_by_id(""),
		expected,
		"Agroupation didn't work properly"
	)

#endregion

#region Method get_repeated_accessors_grouped_by_id

func test_get_repeated_accessors_grouped_by_id_works_properly() -> void:
	var DoubledStorageAccessor: GDScript = double(StorageAccessor)
	
	var accessor1: LokStorageAccessor = autofree(DoubledStorageAccessor.new())
	stub(accessor1.get_id).to_return("id1")
	var accessor2: LokStorageAccessor = autofree(DoubledStorageAccessor.new())
	stub(accessor2.get_id).to_return("id1")
	var accessor3: LokStorageAccessor = autofree(DoubledStorageAccessor.new())
	stub(accessor3.get_id).to_return("id2")
	
	manager.add_accessor(accessor1)
	manager.add_accessor(accessor2)
	manager.add_accessor(accessor3)
	
	var expected: Dictionary = {
		"id1": [ accessor1, accessor2 ]
	}
	
	assert_eq(
		manager.get_repeated_accessors_grouped_by_id(""),
		expected,
		"Agroupation didn't work properly"
	)

#endregion

#region Method gather_data

func test_gather_data_gathers_only_from_selected_version() -> void:
	var DoubledStorageAccessor: GDScript = partial_double(StorageAccessor)
	
	var accessor3_get_id = func(this: LokStorageAccessor) -> String:
		if this.version_number == "1.0.0":
			return ""
		
		return "id3"
	
	var accessor1: LokStorageAccessor = autofree(DoubledStorageAccessor.new())
	stub(accessor1.get_id).to_return("id1")
	stub(accessor1.get_version_number).to_return("1.0.0")
	stub(accessor1.retrieve_data).to_return({ "name1": "accessor1" })
	var accessor2: LokStorageAccessor = autofree(DoubledStorageAccessor.new())
	stub(accessor2.get_id).to_return("id2")
	stub(accessor2.get_version_number).to_return("1.0.0")
	stub(accessor2.retrieve_data).to_return({ "name2": "accessor2" })
	var accessor3: LokStorageAccessor = autofree(DoubledStorageAccessor.new())
	stub(accessor3.get_id).to_call(accessor3_get_id.bind(accessor3))
	stub(accessor3.retrieve_data).to_return({ "name3": "accessor3" })
	
	manager.add_accessor(accessor1)
	manager.add_accessor(accessor2)
	manager.add_accessor(accessor3)
	
	var expected: Dictionary = {
		"id1": { "version": "1.0.0", "name1": "accessor1" },
		"id2": { "version": "1.0.0", "name2": "accessor2" }
	}
	
	assert_eq(
		manager.gather_data([] as Array[String], "1.0.0"),
		expected,
		"Gathering didn't work as expected"
	)

func test_gather_data_gathers_only_from_passed_accessors() -> void:
	var DoubledStorageAccessor: GDScript = partial_double(StorageAccessor)
	
	var accessor1: LokStorageAccessor = autofree(DoubledStorageAccessor.new())
	stub(accessor1.get_id).to_return("id1")
	stub(accessor1.get_version_number).to_return("1.0.0")
	stub(accessor1.retrieve_data).to_return({ "name1": "accessor1" })
	var accessor2: LokStorageAccessor = autofree(DoubledStorageAccessor.new())
	stub(accessor2.get_id).to_return("id2")
	stub(accessor2.get_version_number).to_return("1.0.0")
	stub(accessor2.retrieve_data).to_return({ "name2": "accessor2" })
	var accessor3: LokStorageAccessor = autofree(DoubledStorageAccessor.new())
	stub(accessor3.get_id).to_return("id3")
	stub(accessor3.get_version_number).to_return("1.0.0")
	stub(accessor3.retrieve_data).to_return({ "name3": "accessor3" })
	
	manager.add_accessor(accessor1)
	manager.add_accessor(accessor2)
	manager.add_accessor(accessor3)
	
	var expected: Dictionary = {
		"id1": { "version": "1.0.0", "name1": "accessor1" },
		"id2": { "version": "1.0.0", "name2": "accessor2" }
	}
	
	assert_eq(
		manager.gather_data([ "id1", "id2" ] as Array[String], "1.0.0"),
		expected,
		"Gathering didn't work as expected"
	)

#endregion

#region Method distribute_data

func test_distribute_data_distributes_only_to_accessors_in_version_specified() -> void:
	var DoubledStorageAccessor = partial_double(StorageAccessorTest)
	
	var accessor3_get_id = func(this: LokStorageAccessor) -> String:
		if this.version_number == "1.0.0":
			return ""
		
		return "id3"
	
	var accessor1: StorageAccessorTest = autofree(DoubledStorageAccessor.new())
	stub(accessor1.get_id).to_return("id1")
	var accessor2: StorageAccessorTest = autofree(DoubledStorageAccessor.new())
	stub(accessor2.get_id).to_return("id2")
	var accessor3: StorageAccessorTest = autofree(DoubledStorageAccessor.new())
	accessor3.set_version_number("2.0.0")
	stub(accessor3.get_id).to_call(accessor3_get_id.bind(accessor3))
	
	manager.add_accessor(accessor1)
	manager.add_accessor(accessor2)
	manager.add_accessor(accessor3)
	
	manager.distribute_data({
		"id1": { "version": "1.0.0", "name1": "accessor1" },
		"id2": { "version": "1.0.0", "name2": "accessor2" },
		"id3": { "version": "1.0.0", "name3": "accessor3" }
	}, [] as Array[String])
	
	assert_eq(
		accessor1.data,
		{ "version": "1.0.0", "name1": "accessor1" },
		"Accessor 1 didn't receive data"
	)
	assert_eq(
		accessor2.data,
		{ "version": "1.0.0", "name2": "accessor2" },
		"Accessor 2 didn't receive data"
	)
	assert_eq(
		accessor3.data,
		{},
		"Accessor 3 received data"
	)

func test_distribute_data_distributes_only_to_accessors_specified() -> void:
	var DoubledStorageAccessor = partial_double(StorageAccessorTest)
	
	var accessor1: StorageAccessorTest = autofree(DoubledStorageAccessor.new())
	stub(accessor1.get_id).to_return("id1")
	var accessor2: StorageAccessorTest = autofree(DoubledStorageAccessor.new())
	stub(accessor2.get_id).to_return("id2")
	var accessor3: StorageAccessorTest = autofree(DoubledStorageAccessor.new())
	stub(accessor3.get_id).to_return("id3")
	
	manager.add_accessor(accessor1)
	manager.add_accessor(accessor2)
	manager.add_accessor(accessor3)
	
	manager.distribute_data({
		"id1": { "version": "1.0.0", "name1": "accessor1" },
		"id2": { "version": "1.0.0", "name2": "accessor2" },
		"id3": { "version": "1.0.0", "name3": "accessor3" }
	}, [ "id1", "id2" ] as Array[String])
	
	assert_eq(
		accessor1.data,
		{ "version": "1.0.0", "name1": "accessor1" },
		"Accessor 1 didn't receive data"
	)
	assert_eq(
		accessor2.data,
		{ "version": "1.0.0", "name2": "accessor2" },
		"Accessor 2 didn't receive data"
	)
	assert_eq(
		accessor3.data,
		{},
		"Accessor 3 received data"
	)

#endregion

#region Method save_data

func test_save_data_gathers_data() -> void:
	var DoubledAccessStrategy: GDScript = double(AccessStrategy)
	
	var strategy: LokAccessStrategy = DoubledAccessStrategy.new()
	stub(manager.get_access_strategy).to_return(strategy)
	
	manager.save_data(1, "1.0.0", [], false)
	
	assert_called(manager, "gather_data")

func test_save_data_delegates_to_strategy() -> void:
	var DoubledAccessStrategy: GDScript = partial_double(AccessStrategy)
	
	var strategy: LokAccessStrategy = DoubledAccessStrategy.new()
	stub(strategy.save_data).to_do_nothing()
	
	stub(manager.get_access_strategy).to_return(strategy)
	
	manager.save_data(1, "1.0.0", [], false)
	
	assert_called(strategy, "save_data")

#endregion

#region Method load_data

func test_load_data_distributes_data() -> void:
	var DoubledAccessStrategy: GDScript = double(AccessStrategy)
	
	var strategy: LokAccessStrategy = DoubledAccessStrategy.new()
	stub(strategy.load_data).to_return({})
	
	stub(manager.get_access_strategy).to_return(strategy)
	
	manager.load_data(1, [], [], [])
	
	assert_called(manager, "distribute_data")

func test_load_data_delegates_to_strategy() -> void:
	var DoubledAccessStrategy: GDScript = double(AccessStrategy)
	
	var strategy: LokAccessStrategy = DoubledAccessStrategy.new()
	stub(strategy.load_data).to_return({})
	
	stub(manager.get_access_strategy).to_return(strategy)
	
	manager.load_data(1, [], [], [])
	
	assert_called(strategy, "load_data")
