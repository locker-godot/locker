@icon("res://addons/locker/icons/util.svg")
## The [LokFileSystemUtil] class provides utilities to
## deal with the file system.
## 
## The objective of this class is to help with boilerplate code
## when manipulating files or directories in the file system. [br]
## [br]
## [b]Version[/b]: 1.0.0 [br]
## [b]Author[/b]: Daniel Sousa ([url]github.com/nadjiel[/url])
class_name LokFileSystemUtil
extends Node

#region Debug Methods

## The [method push_error_directory_creation_failed] method is used to
## push an error when a directory creation fails. [br]
## The [param path] of where the creation was tried is expected in the
## parameters together with an [param error_code] indicating what kind of
## error happened.
static func push_error_directory_creation_failed(
	path: String, error_code: Error
) -> void:
	push_error("%s: Error on directory creation in path '%s'" % [
		error_string(error_code),
		path
	])

## The [method push_error_file_writing_or_creation_failed] method is used to
## push an error when a file creation or writing operation fails. [br]
## The [param path] of where the operation was tried is expected in the
## parameters together with an [param error_code] indicating what kind of
## error happened.
static func push_error_file_writing_or_creation_failed(
	path: String, error_code: Error
) -> void:
	push_error("%s: Error on writing or creating file in path '%s'" % [
		error_string(error_code),
		path
	])

## The [method push_error_directory_not_found] method is used to
## push an error warning that the [param path] doesn't point to an
## existing directory.
static func push_error_directory_not_found(path: String) -> void:
	push_error("%s: Directory not found in path '%s'" % [
		error_string(Error.ERR_FILE_NOT_FOUND),
		path
	])

## The [method push_error_file_not_found] method is used to
## push an error warning that the [param path] doesn't point to an
## existing file.
static func push_error_file_not_found(path: String) -> void:
	push_error("%s: File not found in path '%s'" % [
		error_string(Error.ERR_FILE_NOT_FOUND),
		path
	])

## The [method push_error_file_reading_failed] method is used to
## push an error when a file reading fails. [br]
## The [param path] of where the operation was tried is expected in the
## parameters together with an [param error_code] indicating what kind of
## error happened.
static func push_error_file_reading_failed(
	path: String, error_code: Error
) -> void:
	push_error("%s: Error on reading file in path '%s'" % [
		error_string(error_code),
		path
	])

## The [method push_error_json_parse_failed] method is used to
## push an error when a [JSON] parsing fails. [br]
## The [param json] argument is the [JSON] instance that failed
## and the [param error_code] argument represents the [enum @GlobalScope.Error]
## that occured.
static func push_error_json_parse_failed(
	json: JSON, error_code: Error
) -> void:
	push_error("%s: Error on parsing JSON (%s) at line %d" % [
		error_string(error_code),
		json.get_error_message(),
		json.get_error_line()
	])

## The [method push_error_directory_or_file_removal_failed] method is used to
## push an error when a directory or file removal fails. [br]
## The [param path] where the removal was tried is expected in the
## parameters together with an [param error_code] indicating what kind of
## error happened.
static func push_error_directory_or_file_removal_failed(
	path: String, error_code: Error
) -> void:
	push_error("%s: Error on file or directory removal in path '%s'" % [
		error_string(error_code),
		path
	])

#endregion

#region Directory Methods

## The [method create_directory] method creates a new directory in the
## path specified by the [param path] parameter. [br]
## If an error occurs, this method pushes it, either way, this method
## returns an [enum @GlobalScope.Error] code specifying the success
## of the operation.
static func create_directory(path: String) -> Error:
	var error: Error = DirAccess.make_dir_recursive_absolute(path)
	
	if error != OK:
		push_error_directory_creation_failed(path, error)
	
	return error

## The [method create_directory_if_not_exists] method uses the
## [method directory_exists] and [method create_directory] methods
## to create a directory only if it doesn't already exist. [br]
## If it already exists, this method returns the
## [code]ERR_ALREADY_EXISTS[/code] error.
static func create_directory_if_not_exists(path: String) -> Error:
	if not directory_exists(path):
		return create_directory(path)
	
	return Error.OK

## The [method directory_exists] method checks if a directory exists in the
## path specified by the [param path] parameter and returns a [code]bool[/code]
## indicating the result.
static func directory_exists(path: String) -> bool:
	return DirAccess.dir_exists_absolute(path)

## The [method get_file_names] method scans the files of a directory
## in a given [param path] and returns their names in a [PackedStringArray].
## [br]
## The [param formats] parameter is used to filter what file formats should
## be included in the final result (without the "."). [br]
## If this parameter is left as default, that means all file formats are
## included. [br]
## If the [param path] doesn't point to an existing directory, an error
## is pushed and the method returns an empty [PackedStringArray].
static func get_file_names(
	path: String, formats: Array[String] = []
) -> PackedStringArray:
	if not directory_exists(path):
		push_error_directory_not_found(path)
		return []
	
	var file_names: PackedStringArray = DirAccess.get_files_at(path)
	
	# Filtering isn't needed
	if formats.is_empty():
		return file_names
	
	var filtered_file_names: PackedStringArray = []
	
	for file_name: String in file_names:
		if get_file_format(file_name) in formats:
			filtered_file_names.append(file_name)
	
	return filtered_file_names

## The [method get_subdirectory_names] method returns the names of the
## subdirectories of a directory in a given [param path] in a
## [PackedStringArray]. [br]
## If the [param path] doesn't point to an existing directory, an error
## is pushed and the method returns an empty [PackedStringArray].
static func get_subdirectory_names(path: String) -> PackedStringArray:
	if not directory_exists(path):
		push_error_directory_not_found(path)
		return []
	
	return DirAccess.get_directories_at(path)

## The [method directory_is_empty] method looks for the files and subdirectories
## in the directory in the [param path] and tells whether that directory
## is empty or not. [br]
## If the [param path] doesn't point to an existing directory, an error
## is pushed and the method returns [code]true[/code], indicating that
## the directory is empty because it doesn't exist.
static func directory_is_empty(path: String) -> bool:
	if not directory_exists(path):
		push_error_directory_not_found(path)
		return true
	
	return (
		get_file_names(path).is_empty() and
		get_subdirectory_names(path).is_empty()
	)

## The [method remove_directory_or_file] method removes a directory or file
## from the path specified by the [param path] parameter. [br]
## If [param path] points to a directory that isn't empty this method
## won't succed, so make sure to empty it first. [br]
## If an error occurs, this method pushes it, either way, this method
## returns an [enum @GlobalScope.Error] code specifying the success
## of the operation.
static func remove_directory_or_file(path: String) -> Error:
	var error: Error = DirAccess.remove_absolute(path)
	
	if error != OK:
		push_error_directory_or_file_removal_failed(path, error)
	
	return error

## The [method remove_directory_recursive] method removes a directory
## from the path specified by the [param path] parameter, making
## sure to remove all the subdirectories or files within it. [br]
## If an error occurs during the operation, this method pushes it
## and cancels, either way, this method returns an
## [enum @GlobalScope.Error] code specifying the success
## of the operation.
static func remove_directory_recursive(path: String) -> Error:
	var error: Error = Error.OK
	
	for file_name: String in get_file_names(path):
		if error != Error.OK:
			return error
		
		error = remove_directory_or_file(path.path_join(file_name))
	
	for subdirectory_name: String in get_subdirectory_names(path):
		if error != Error.OK:
			return error
		
		error = remove_directory_recursive(path.path_join(subdirectory_name))
	
	return remove_directory_or_file(path)

## The [method remove_directory_if_exists] method uses the
## [method directory_exists] and [method remove_directory_or_file] methods
## to remove a directory only if exists. [br]
## If it doesn't exist, this method returns the
## [code]ERR_DOES_NOT_EXIST[/code] error.
static func remove_directory_if_exists(path: String) -> Error:
	if directory_exists(path):
		return remove_directory_or_file(path)
	
	return Error.OK

## The [method remove_directory_recursive_if_exists] method uses the
## [method directory_exists] and [method remove_directory_or_file] methods
## to remove a directory only if exists. [br]
## If it doesn't exist, this method returns the
## [code]ERR_DOES_NOT_EXIST[/code] error.
static func remove_directory_recursive_if_exists(path: String) -> Error:
	if directory_exists(path):
		return remove_directory_recursive(path)
	
	return Error.ERR_DOES_NOT_EXIST

## The [method get_directory_name] method is a utility method that grabs
## the name of a directory from a [param directory_path].
static func get_directory_name(directory_path: String) -> String:
	var path_parts: PackedStringArray = directory_path.rsplit("/", false)
	var directory_name: String = ""
	
	if path_parts.size() > 0:
		directory_name = path_parts[-1]
	
	return directory_name

#endregion

#region File Methods

## The [method write_or_create_file] method creates a new file in the
## path specified by the [param path] parameter, if it doesn't already
## exists, else, it simply writes in that file. [br]
## Optionally, this method can receive a [param content] parameter
## that defines what should be written in the file. [br]
## If an error occurs during the operation, this method pushes it
## and cancels, either way, this method returns an
## [enum @GlobalScope.Error] code specifying the success
## of the operation.
static func write_or_create_file(path: String, content: String = "") -> Error:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	
	if file == null:
		var error: Error = FileAccess.get_open_error()
		
		push_error_file_writing_or_creation_failed(path, error)
		
		return error
	
	file.store_string(content)
	
	file.close()
	
	return Error.OK

## The [method write_or_create_encrypted_file] method creates a new file in the
## path specified by the [param path] parameter, if it doesn't already
## exist, else, it simply writes in that file using encryption. [br]
## The [param encryption_pass] parameter is used as the password to encrypt
## the contents of the file. [br]
## Optionally, this method can receive a [param content] parameter
## that defines what should be written in the file. [br]
## If an error occurs during the operation, this method pushes it
## and cancels, either way, this method returns an
## [enum @GlobalScope.Error] code specifying the success
## of the operation.
static func write_or_create_encrypted_file(
	path: String,
	encryption_pass: String,
	content: String = ""
) -> Error:
	var file: FileAccess = FileAccess.open_encrypted_with_pass(
		path, FileAccess.WRITE, encryption_pass
	)
	
	if file == null:
		var error: Error = FileAccess.get_open_error()
		
		push_error_file_writing_or_creation_failed(path, error)
		
		return error
	
	file.store_string(content)
	
	file.close()
	
	return Error.OK

## The [method create_file_if_not_exists] method uses the
## [method file_exists] and [method write_or_create_file] methods
## to create a file only if it doesn't already exist. [br]
## If it already exists, this method returns the
## [code]ERR_ALREADY_EXISTS[/code] error.
static func create_file_if_not_exists(path: String) -> Error:
	if not file_exists(path):
		return write_or_create_file(path)
	
	return Error.OK

## The [method create_encrypted_file_if_not_exists] method uses the
## [method file_exists] and [method write_or_create_encrypted_file] methods
## to create an encrypted file only if it doesn't already exist. [br]
## If it already exists, this method returns the
## [code]ERR_ALREADY_EXISTS[/code] error.
static func create_encrypted_file_if_not_exists(
	path: String,
	encryption_pass: String,
	content: String = ""
) -> Error:
	if not file_exists(path):
		return write_or_create_encrypted_file(
			path, encryption_pass, content
		)
	
	return Error.OK

## The [method file_exists] method checks if a file exists in the
## path specified by the [param path] parameter and returns a [code]bool[/code]
## indicating the result.
static func file_exists(path: String) -> bool:
	return FileAccess.file_exists(path)

## The [method read_file] method reads from a file in the
## path specified by the [param path] parameter. [br]
## If an error occurs, this method pushes it and returns [code]""[/code],
## otherwise, it returns the [String] read from the file.
static func read_file(path: String) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	
	if file == null:
		var error: Error = FileAccess.get_open_error()
		
		push_error_file_reading_failed(path, error)
		
		return ""
	
	var result: String = file.get_as_text()
	
	file.close()
	
	return result

## The [method read_encrypted_file] method reads from a encrypted file in the
## path specified by the [param path] parameter. [br]
## The [param encryption_pass] parameter is used as the password to decrypt
## the contents of the file. [br]
## If an error occurs, this method pushes it and returns [code]""[/code],
## otherwise, it returns the [String] read from the file. [br]
## If the [param suppress_errors] is [code]true[/code], though,
## no errors are pushed, except for errors that come from the
## [method FileAccess.open_encrypted_with_pass] method.
static func read_encrypted_file(
	path: String, encryption_pass: String, suppress_errors: bool = false
) -> String:
	var file: FileAccess = FileAccess.open_encrypted_with_pass(
		path, FileAccess.READ, encryption_pass
	)
	
	if file == null:
		if not suppress_errors:
			var error: Error = FileAccess.get_open_error()
			
			push_error_file_reading_failed(path, error)
		
		return ""
	
	var result: String = file.get_as_text()
	
	file.close()
	
	return result

## The [method parse_json_from_string] method can be used to parse a [String]
## into a [Dictionary] using a [JSON] instance. [br]
## If the parsing fails, an error is pushed and an empty [Dictionary] is
## returned. [br]
## If the [param suppress_errors] is [code]true[/code], though,
## no errors are pushed.
static func parse_json_from_string(
	string: String, suppress_errors: bool
) -> Variant:
	var json := JSON.new()
	
	var error: Error = json.parse(string)
	
	if error != Error.OK:
		if not suppress_errors:
			push_error_json_parse_failed(json, error)
		
		return {}
	
	return json.data

## The [method load_resources] method is a quick way to load all [Resource]s
## located in a specific [param directory_path]. [br]
## Optionally, a [param resource_type] [String] can be passed to filter
## what types of [Resource]s should be loaded or to prevent unknown
## file types from being loaded. [br]
## As an example, if a [code]"Script"[/code] [String] is passed in the
## [param resource_type] parameter, only files with formats that can represent
## [Script]s are loaded. [br]
## What formats can represent what [Resource] types are dictated by the
## [method ResourceLoader.get_recognized_extensions_for_type] method.
static func load_resources(
	directory_path: String,
	resource_type: String = ""
) -> Array[Resource]:
	var resources: Array[Resource] = []
	
	var resource_names: PackedStringArray = get_file_names(directory_path)
	
	var formats: PackedStringArray = []
	
	if resource_type != "":
		formats = ResourceLoader.get_recognized_extensions_for_type(resource_type)
	
	for resource_name: String in resource_names:
		var resource_format: String = get_file_format(resource_name)
		
		if not LokUtil.filter_value(formats, resource_format):
			continue
		
		var resource_path: String = directory_path.path_join(resource_name)
		
		resources.append(load(resource_path))
	
	return resources

## The [method remove_file_if_exists] method uses the
## [method file_exists] and [method remove_directory_or_file] methods
## to remove a file only if exists. [br]
## If it doesn't exist, this method returns the
## [code]ERR_DOES_NOT_EXIST[/code] error.
static func remove_file_if_exists(path: String) -> Error:
	if file_exists(path):
		return remove_directory_or_file(path)
	
	return Error.OK

## The [method join_file_name] method takes a [param file_prefix] [String] and
## a [param file_format] [String] and joins them together with a
## [code]"."[/code] in the middle, so that they form a complete file_name.
static func join_file_name(file_prefix: String, file_format: String) -> String:
	return "%s.%s" % [ file_prefix, file_format ]

## The [method get_file_name] method is a utility method that grabs
## the name of a file from a [param file_path], including its format.
static func get_file_name(file_path: String) -> String:
	var path_parts: PackedStringArray = file_path.rsplit("/", true, 1)
	var file_name: String = ""
	
	if path_parts.size() > 0:
		file_name = path_parts[-1]
	
	return file_name

## The [method get_file_format] method is a utility method that grabs
## the format of a file from a [param file_name]. [br]
## The return of this method doesn't include the [code]"."[/code] of
## the format.
static func get_file_format(file_name: String) -> String:
	var file_parts: PackedStringArray = file_name.rsplit(".", true, 1)
	var file_format: String = ""
	
	if file_parts.size() == 2:
		file_format = file_parts[1]
	
	return file_format

## The [method get_file_prefix] method is a utility method that grabs
## the name of a file without its format. [br]
## The return of this method doesn't include the [code]"."[/code] of
## the format.
static func get_file_prefix(file_name: String) -> String:
	var file_parts: PackedStringArray = file_name.rsplit(".", true, 1)
	var file_prefix: String = ""
	
	if file_parts.size() > 0:
		file_prefix = file_parts[0]
	
	return file_prefix

#endregion
