
extends GutTest

var AccessStrategy: GDScript = preload("res://addons/locker/scripts/access_strategy/access_strategy.gd")

var strategy: LokAccessStrategy

var files_path: String = "res://test/saves/"

func before_each() -> void:
	strategy = AccessStrategy.new()

func after_all() -> void:
	LokFileSystemUtil.remove_directory_recursive_if_exists(files_path)
	LokFileSystemUtil.create_directory_if_not_exists(files_path)
	
	queue_free()

#region Method get_file_id

func test_get_file_id_returns_file_id() -> void:
	var expected: String = "access_strategy"
	var result: String = strategy.get_file_id("file_access_strategy")
	
	assert_eq(result, expected, "Result unexpected")

func test_get_file_id_returns_file_prefix() -> void:
	var expected: String = "file"
	var result: String = strategy.get_file_id("file")
	
	assert_eq(result, expected, "Result unexpected")

func test_get_file_id_returns_file_prefix_if_it_has_underscore_at_end() -> void:
	var expected: String = "file"
	var result: String = strategy.get_file_id("file_")
	
	assert_eq(result, expected, "Result unexpected")

#endregion

#region Method get_file_ids

func test_get_file_ids_returns_file_ids() -> void:
	var file1_name: String = "file_1"
	var file2_name: String = "file_2"
	var file3_name: String = "file_3"
	
	LokFileSystemUtil.create_directory_if_not_exists(
		files_path.path_join(file1_name)
	)
	LokFileSystemUtil.create_directory_if_not_exists(
		files_path.path_join(file2_name)
	)
	LokFileSystemUtil.create_directory_if_not_exists(
		files_path.path_join(file3_name)
	)
	
	var expected_data: Array[String] = [ "1", "2", "3" ]
	var result: Dictionary = strategy.get_file_ids(files_path)
	
	var expected: Dictionary = {
		"status": Error.OK,
		"data": expected_data
	}
	
	assert_eq(result, expected, "Result unexpected")

func test_get_file_ids_returns_file_not_found() -> void:
	LokFileSystemUtil.remove_directory_recursive(files_path)
	
	var result: Dictionary = strategy.get_file_ids(files_path)
	
	var expected: Dictionary = {
		"status": Error.ERR_FILE_NOT_FOUND,
		"data": []
	}
	
	assert_eq(result, expected, "Result unexpected")

#endregion
