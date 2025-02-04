
extends GutTest

var GlobalStorageManager: GDScript = preload("res://addons/locker/storage_manager/global_storage_manager.gd")
var StorageAccessor: GDScript = preload("res://addons/locker/storage_accessor/storage_accessor.gd")

var manager: LokStorageManager

func before_each() -> void:
	manager = add_child_autofree(GlobalStorageManager.new())

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
		manager.get_accessors_grouped_by_id(),
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
		manager.get_repeated_accessors_grouped_by_id(),
		expected,
		"Agroupation didn't work properly"
	)

#endregion

#region Method gather_data

func test_gather_data_works_properly() -> void:
	var DoubledStorageAccessor: GDScript = double(StorageAccessor)
	
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
		"id2": { "version": "1.0.0", "name2": "accessor2" },
		"id3": { "version": "1.0.0", "name3": "accessor3" }
	}
	
	assert_eq(
		manager.gather_data([] as Array[String], "1.0.0"),
		expected,
		"Gathering didn't work as expected"
	)

#endregion
