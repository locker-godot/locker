
extends GutTest

const TEST_FOLDER_PATH: String = "res://test/test_folder/"

var resources: Dictionary = {}

func before_all() -> void:
	LokFileSystemUtil.create_directory_if_not_exists(TEST_FOLDER_PATH)
	
	var resource_names: Array[String] = [
		"script1.gd", "script1.gd.uid", "script2.gd", "script2.gd.uid"
	]
	
	for resource_name: String in resource_names:
		var resource_path: String = TEST_FOLDER_PATH.path_join(resource_name)
		
		LokFileSystemUtil.create_file_if_not_exists(resource_path)
		
		resources[resource_name] = load(resource_path)

func after_all() -> void:
	LokFileSystemUtil.remove_directory_recursive_if_exists(TEST_FOLDER_PATH)
	queue_free()

#region Method load_resources

func test_load_resources_loads_all_files_in_folder() -> void:
	var result: Array[Resource] = LokFileSystemUtil.load_resources(
		TEST_FOLDER_PATH
	)
	
	assert_eq(result, resources.values(), "Resources didn't match expected")

func test_load_resources_loads_all_files_that_match_type() -> void:
	var result: Array[Resource] = LokFileSystemUtil.load_resources(
		TEST_FOLDER_PATH, "Script"
	)
	
	var expected: Array[Resource] = [
		resources["script1.gd"],
		resources["script2.gd"]
	]
	
	assert_eq(result, expected, "Resources didn't match expected")

#endregion
