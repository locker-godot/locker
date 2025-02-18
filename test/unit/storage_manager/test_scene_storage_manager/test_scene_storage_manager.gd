
extends GutTest

var SceneStorageManager: GDScript = preload("res://addons/locker/scripts/storage_manager/scene_storage_manager.gd")
var StorageManager: GDScript = preload("res://addons/locker/scripts/storage_manager/storage_manager.gd")
var DoubledStorageManager: GDScript

var manager: LokStorageManager

func before_all() -> void:
	DoubledStorageManager = partial_double(StorageManager)

func before_each() -> void:
	manager = add_child_autofree(SceneStorageManager.new())
	manager.global_manager = DoubledStorageManager.new()

func after_all() -> void:
	queue_free()

#region Method save_data

func test_save_data_passes_to_global_manager() -> void:
	manager.save_data()
	
	assert_called(manager.global_manager, "save_data")

func test_save_data_emits_saving_started_signal() -> void:
	watch_signals(manager)
	
	manager.save_data()
	
	assert_signal_emitted(manager, "saving_started", "Signal not emitted")

func test_save_data_emits_saving_finished_signal() -> void:
	watch_signals(manager)
	
	manager.save_data()
	
	assert_signal_emitted(manager, "saving_finished", "Signal not emitted")

#endregion

#region Method load_data

func test_load_data_passes_to_global_manager() -> void:
	manager.load_data()
	
	assert_called(manager.global_manager, "load_data")

func test_load_data_emits_loading_started_signal() -> void:
	watch_signals(manager)
	
	manager.load_data()
	
	assert_signal_emitted(manager, "loading_started", "Signal not emitted")

func test_load_data_emits_loading_finished_signal() -> void:
	watch_signals(manager)
	
	manager.load_data()
	
	assert_signal_emitted(manager, "loading_finished", "Signal not emitted")

#endregion

#region Method read_data

func test_read_data_passes_to_global_manager() -> void:
	manager.read_data()
	
	assert_called(manager.global_manager, "read_data")

func test_read_data_emits_reading_started_signal() -> void:
	watch_signals(manager)
	
	manager.read_data()
	
	assert_signal_emitted(manager, "reading_started", "Signal not emitted")

func test_read_data_emits_reading_finished_signal() -> void:
	watch_signals(manager)
	
	manager.read_data()
	
	assert_signal_emitted(manager, "reading_finished", "Signal not emitted")

#endregion

#region Method remove_data

func test_remove_data_passes_to_global_manager() -> void:
	manager.remove_data()
	
	assert_called(manager.global_manager, "remove_data")

func test_remove_data_emits_removing_started_signal() -> void:
	watch_signals(manager)
	
	manager.remove_data()
	
	assert_signal_emitted(manager, "removing_started", "Signal not emitted")

func test_remove_data_emits_removing_finished_signal() -> void:
	watch_signals(manager)
	
	manager.remove_data()
	
	assert_signal_emitted(manager, "removing_finished", "Signal not emitted")

#endregion
