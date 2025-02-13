
extends GutTest

var JSONAccessStrategy: GDScript = preload("res://addons/locker/access_strategy/json_access_strategy.gd")

var strategy: LokAccessStrategy

var file_path: String = "res://test/saves/file_json_access_strategy"
var partition_path: String = file_path.path_join("partition1.sav")
var default_accessor1_data: Dictionary = {
	"accessor_id_1": {
		"version": "1.0.0",
		"data1": "value1",
		"data2": "value2"
	}
}
var default_accessor2_data: Dictionary = {
	"accessor_id_2": {
		"version": "1.0.1",
		"overwritten_data1": "overwritten_value1",
		"overwritten_data2": "overwritten_value2"
	}
}

func before_each() -> void:
	LokFileSystemUtil.remove_directory_recursive_if_exists(file_path)
	LokFileSystemUtil.create_directory_if_not_exists(file_path)
	
	strategy = JSONAccessStrategy.new()

func after_all() -> void:
	LokFileSystemUtil.remove_directory_recursive_if_exists(file_path)
	queue_free()

#region Method save_partition

func test_save_partition_returns_new_partition() -> void:
	var data_to_save: Dictionary = default_accessor1_data
	
	var result: Dictionary = strategy.save_partition(partition_path, data_to_save)
	
	var expected_result: Dictionary = {
		"status": Error.OK,
		"data": data_to_save
	}
	
	assert_eq(result, expected_result, "Returned data didn't match expected")

func test_save_partition_creates_new_partition() -> void:
	var data_to_save: Dictionary = default_accessor1_data
	
	var expected_result: Dictionary = {
		"status": Error.OK,
		"data": data_to_save
	}
	
	strategy.save_partition(partition_path, data_to_save)
	
	var loaded_result: Dictionary = strategy.load_partition(partition_path, false)
	
	assert_eq(loaded_result, expected_result, "Data wasn't saved properly")

func test_save_partition_overwrites_partition() -> void:
	var first_data_to_save: Dictionary = default_accessor1_data
	var second_data_to_save: Dictionary = default_accessor2_data
	
	var expected_result: Dictionary = {
		"status": Error.OK,
		"data": second_data_to_save
	}
	
	strategy.save_partition(partition_path, first_data_to_save)
	strategy.save_partition(partition_path, second_data_to_save, true)
	
	var loaded_result: Dictionary = strategy.load_partition(partition_path, false)
	
	assert_eq(loaded_result, expected_result, "Data wasn't overwritten properly")

func test_save_partition_updates_partition() -> void:
	var first_data_to_save: Dictionary = default_accessor1_data
	var second_data_to_save: Dictionary = default_accessor2_data
	
	var expected_result: Dictionary = {
		"status": Error.OK,
		"data": first_data_to_save.merged(second_data_to_save)
	}
	
	strategy.save_partition(partition_path, first_data_to_save)
	strategy.save_partition(partition_path, second_data_to_save, false)
	
	var loaded_result: Dictionary = strategy.load_partition(partition_path, false)
	
	assert_eq(loaded_result, expected_result, "Data wasn't updated properly")

#endregion

#region Method load_partition

func test_load_partition_returns_error_not_found() -> void:
	var result: Dictionary = strategy.load_partition(partition_path)
	
	var expected_result: Dictionary = {
		"status": Error.ERR_FILE_NOT_FOUND,
		"data": {}
	}
	
	assert_eq(result, expected_result, "Returned data didn't match expected")

func test_load_partition_returns_error_unrecognized() -> void:
	LokFileSystemUtil.create_file_if_not_exists(partition_path)
	
	var result: Dictionary = strategy.load_partition(partition_path)
	
	var expected_result: Dictionary = {
		"status": Error.ERR_FILE_UNRECOGNIZED,
		"data": {}
	}
	
	assert_eq(result, expected_result, "Returned data didn't match expected")

func test_load_partition_returns_result_with_partition_id() -> void:
	var data_to_save: Dictionary = default_accessor1_data
	
	strategy.save_partition(partition_path, data_to_save)
	
	var result: Dictionary = strategy.load_partition(partition_path)
	
	var expected_loaded_data: Dictionary = data_to_save.duplicate()
	expected_loaded_data["accessor_id_1"]["partition"] = "partition1"
	
	var expected_result: Dictionary = {
		"status": Error.OK,
		"data": expected_loaded_data
	}
	
	assert_eq(result, expected_result, "Returned data didn't match expected")

func test_load_partition_returns_result_without_partition_id() -> void:
	var data_to_save: Dictionary = default_accessor1_data
	
	strategy.save_partition(partition_path, data_to_save)
	
	var result: Dictionary = strategy.load_partition(partition_path, false)
	
	var expected_loaded_data: Dictionary = data_to_save
	
	var expected_result: Dictionary = {
		"status": Error.OK,
		"data": expected_loaded_data
	}
	
	assert_eq(result, expected_result, "Returned data didn't match expected")

#endregion

#region Method remove_partition

func test_remove_partition_returns_removed_result() -> void:
	var data_to_save1: Dictionary = default_accessor1_data
	var data_to_save2: Dictionary = default_accessor2_data
	
	strategy.save_partition(partition_path, data_to_save1)
	strategy.save_partition(partition_path, data_to_save2)
	
	var result: Dictionary = strategy.remove_partition(partition_path)
	
	var expected_removed_data: Dictionary = data_to_save1.merged(data_to_save2)
	expected_removed_data["accessor_id_1"]["partition"] = "partition1"
	expected_removed_data["accessor_id_2"]["partition"] = "partition1"
	
	var expected_result: Dictionary = {
		"status": Error.OK,
		"data": expected_removed_data,
		"updated_data": {}
	}
	
	assert_eq(result, expected_result, "Returned data didn't match expected")

func test_remove_partition_removes_from_files() -> void:
	var data_to_save: Dictionary = default_accessor1_data
	
	strategy.save_partition(partition_path, data_to_save)
	
	strategy.remove_partition(partition_path)
	
	assert_false(
		LokFileSystemUtil.file_exists(partition_path),
		"Partition wasn't deleted from files"
	)

func test_remove_partition_filters_accessor_ids() -> void:
	var data_to_save1: Dictionary = default_accessor1_data
	var data_to_save2: Dictionary = default_accessor2_data
	
	strategy.save_partition(partition_path, data_to_save1)
	strategy.save_partition(partition_path, data_to_save2)
	
	var result: Dictionary = strategy.remove_partition(
		partition_path, [ "accessor_id_1" ]
	)
	
	var expected_removed_data: Dictionary = data_to_save1
	expected_removed_data["accessor_id_1"]["partition"] = "partition1"
	
	var expected_updated_data: Dictionary = data_to_save2
	expected_updated_data["accessor_id_2"]["partition"] = "partition1"
	
	var expected_result: Dictionary = {
		"status": Error.OK,
		"data": expected_removed_data,
		"updated_data": expected_updated_data
	}
	
	assert_eq(result, expected_result, "Returned data didn't match expected")

func test_remove_partition_filters_version_numbers() -> void:
	var data_to_save1: Dictionary = default_accessor1_data
	var data_to_save2: Dictionary = default_accessor2_data
	
	strategy.save_partition(partition_path, data_to_save1)
	strategy.save_partition(partition_path, data_to_save2)
	
	var result: Dictionary = strategy.remove_partition(
		partition_path, [], [ "1.0.0" ]
	)
	
	var expected_removed_data: Dictionary = data_to_save1
	expected_removed_data["accessor_id_1"]["partition"] = "partition1"
	
	var expected_updated_data: Dictionary = data_to_save2
	expected_updated_data["accessor_id_2"]["partition"] = "partition1"
	
	var expected_result: Dictionary = {
		"status": Error.OK,
		"data": expected_removed_data,
		"updated_data": expected_updated_data
	}
	
	assert_eq(result, expected_result, "Returned data didn't match expected")

func test_remove_partition_filters_accessor_ids_and_version_numbers() -> void:
	var data_to_save1: Dictionary = default_accessor1_data
	var data_to_save2: Dictionary = default_accessor2_data
	
	strategy.save_partition(partition_path, data_to_save1)
	strategy.save_partition(partition_path, data_to_save2)
	
	var result: Dictionary = strategy.remove_partition(
		partition_path, [ "accessor_id_2" ], [ "1.0.0" ]
	)
	
	var expected_removed_data: Dictionary = {}
	
	var expected_updated_data: Dictionary = data_to_save1.merged(data_to_save2)
	expected_updated_data["accessor_id_1"]["partition"] = "partition1"
	expected_updated_data["accessor_id_2"]["partition"] = "partition1"
	
	var expected_result: Dictionary = {
		"status": Error.OK,
		"data": expected_removed_data,
		"updated_data": expected_updated_data
	}
	
	assert_eq(result, expected_result, "Returned data didn't match expected")

func test_remove_partition_updates_in_file_system() -> void:
	var data_to_save1: Dictionary = default_accessor1_data
	var data_to_save2: Dictionary = default_accessor2_data
	
	strategy.save_partition(partition_path, data_to_save1)
	strategy.save_partition(partition_path, data_to_save2)
	
	strategy.remove_partition(partition_path, [ "accessor_id_1" ])
	
	var expected_updated_data: Dictionary = data_to_save2
	
	var load_result: Dictionary = strategy.load_partition(partition_path, false)
	
	var expected_result: Dictionary = {
		"status": Error.OK,
		"data": expected_updated_data
	}
	
	assert_eq(load_result, expected_result, "Updated data didn't match expected")

#endregion
