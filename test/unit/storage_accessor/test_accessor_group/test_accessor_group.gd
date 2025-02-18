
extends GutTest

var AccessorGroup: GDScript = preload("res://addons/locker/scripts/storage_accessor/accessor_group.gd")
var StorageAccessor: GDScript = preload("res://addons/locker/scripts/storage_accessor/storage_accessor.gd")
var DoubledStorageAccessor: GDScript

var group: LokAccessorGroup

func slow_operation() -> void:
	for i: int in 10:
		await get_tree().create_timer(0.01).timeout

func slow_saving(_file_id: String = "", _version_number: String = "") -> void:
	await slow_operation()

func slow_loading(_file_id: String = "") -> void:
	await slow_operation()

func slow_removing(_file_id: String = "") -> void:
	await slow_operation()

func before_all() -> void:
	DoubledStorageAccessor = partial_double(StorageAccessor)

func before_each() -> void:
	group = add_child_autofree(AccessorGroup.new())
	
	stub(DoubledStorageAccessor, "save_data").to_call(slow_saving)
	stub(DoubledStorageAccessor, "load_data").to_call(slow_loading)
	stub(DoubledStorageAccessor, "remove_data").to_call(slow_removing)

func after_all() -> void:
	queue_free()

#region Signals

func test_group_saving_started_is_emitted_once() -> void:
	watch_signals(group)
	
	var accessor1: LokStorageAccessor = DoubledStorageAccessor.new()
	var accessor2: LokStorageAccessor = DoubledStorageAccessor.new()
	
	group.accessors = [ accessor1, accessor2 ]
	
	group.save_accessor_group()
	
	assert_signal_emit_count(
		group, "group_saving_started", 1, "Saving Started emitted irregularly"
	)

func test_group_loading_started_is_emitted_once() -> void:
	watch_signals(group)
	
	var accessor1: LokStorageAccessor = DoubledStorageAccessor.new()
	var accessor2: LokStorageAccessor = DoubledStorageAccessor.new()
	
	group.accessors = [ accessor1, accessor2 ]
	
	group.load_accessor_group()
	
	assert_signal_emit_count(
		group, "group_loading_started", 1, "Loading Started emitted irregularly"
	)

func test_group_removing_started_is_emitted_once() -> void:
	watch_signals(group)
	
	var accessor1: LokStorageAccessor = DoubledStorageAccessor.new()
	var accessor2: LokStorageAccessor = DoubledStorageAccessor.new()
	
	group.accessors = [ accessor1, accessor2 ]
	
	group.remove_accessor_group()
	
	assert_signal_emit_count(
		group, "group_removing_started", 1, "Removing Started emitted irregularly"
	)

func test_group_saving_finished_is_emitted_once() -> void:
	watch_signals(group)
	
	var accessor1: LokStorageAccessor = DoubledStorageAccessor.new()
	var accessor2: LokStorageAccessor = DoubledStorageAccessor.new()
	
	group.accessors = [ accessor1, accessor2 ]
	
	await group.save_accessor_group()
	
	assert_signal_emit_count(
		group, "group_saving_finished", 1, "Saving Finished emitted irregularly"
	)

func test_group_loading_finished_is_emitted_once() -> void:
	watch_signals(group)
	
	var accessor1: LokStorageAccessor = DoubledStorageAccessor.new()
	var accessor2: LokStorageAccessor = DoubledStorageAccessor.new()
	
	group.accessors = [ accessor1, accessor2 ]
	
	await group.load_accessor_group()
	
	assert_signal_emit_count(
		group, "group_loading_finished", 1, "Loading Finished emitted irregularly"
	)

func test_group_removing_finished_is_emitted_once() -> void:
	watch_signals(group)
	
	var accessor1: LokStorageAccessor = DoubledStorageAccessor.new()
	var accessor2: LokStorageAccessor = DoubledStorageAccessor.new()
	
	group.accessors = [ accessor1, accessor2 ]
	
	await group.remove_accessor_group()
	
	assert_signal_emit_count(
		group, "group_removing_finished", 1, "Removing Finished emitted irregularly"
	)

#endregion
