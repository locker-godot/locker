@icon("res://addons/locker/icons/access_strategy.svg")
## The [LokAccessStrategy] super class is responsible for
## defining how the writing and reading from a file should be performed.
## 
## This class should be extended in order to provide concrete implementations.
## [br]
## [b]Version[/b]: 1.0.0[br]
## [b]Author[/b]: [url]github.com/nadjiel[/url]
class_name LokAccessStrategy
extends Resource

## The [method create_directory] method creates a new directory in the
## path specified by the [param path] parameter. [br]
## If an error occurs, this method pushes it and returns [code]false[/code],
## otherwise, it returns [code]true[/code].
static func create_directory(path: String) -> bool:
	var err: Error = DirAccess.make_dir_recursive_absolute(path)
	
	if err != OK:
		push_error("Unable to create directory: '%s'" % path)
		
		return false
	
	return true

## The [method check_directory] method checks if a directory exists in the
## path specified by the [param path] parameter. [br]
## If the directory doesn't exist, this method pushes an error and returns
## [code]false[/code], otherwise, it returns [code]true[/code]. [br]
## If the [param suppress_error] is [code]true[/code], though,
## no errors are, thrown.
static func check_directory(
	path: String, suppress_error: bool = false
) -> bool:
	if not DirAccess.dir_exists_absolute(path):
		if not suppress_error:
			push_error("Directory not found: '%s'" % path)
		
		return false
	
	return true

## The [method check_and_create_directory] method uses the
## [method check_directory] and [method create_directory] methods
## to create a directory only if it doesn't already exist.
static func check_and_create_directory(path: String) -> bool:
	if not check_directory(path, true):
		return create_directory(path)
	
	return true

static func read_directory(
	path: String, formats: Array[String] = []
) -> PackedStringArray:
	var file_names: PackedStringArray = DirAccess.get_files_at(path)
	
	if formats.is_empty():
		return file_names
	
	var result: PackedStringArray = []
	
	for file_name: String in file_names:
		var file_format: String = get_file_format(file_name)
		
		if file_format in formats:
			result.append(file_name)
	
	return result

## The [method create_file] method creates a new file in the
## path specified by the [param path] parameter. [br]
## Optionally, this method can receive a [param content] parameter
## that defines what should be written in the new file. [br]
## Besides that, a [param encryption_pass] parameter can also be passed.
## Such parameter represents the password to be used in the file creation
## if it is desired to create it in encrypted mode.
## If an error occurs, this method pushes it and returns [code]false[/code],
## otherwise, it returns [code]true[/code].
static func write_or_create_file(
	path: String,
	content: String = "",
	suppress_errors: bool = false
) -> bool:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	
	if file == null:
		if not suppress_errors:
			var error: Error = FileAccess.get_open_error()
			
			push_error(
				"Error on writing or creating file %s: %s(%s)" % [
					path,
					error_string(error),
					error
				]
			)
		
		return false
	
	file.store_string(content)
	
	file.close()
	
	return true

static func write_or_create_encrypted_file(
	path: String,
	encryption_pass: String,
	content: String = "",
	suppress_errors: bool = false
) -> bool:
	var file: FileAccess = FileAccess.open_encrypted_with_pass(
		path, FileAccess.WRITE, encryption_pass
	)
	
	if file == null:
		if not suppress_errors:
			var error: Error = FileAccess.get_open_error()
			
			push_error(
				"Error on writing or creating file %s: %s(%s)" % [
					path,
					error_string(error),
					error
				]
			)
		
		return false
	
	file.store_string(content)
	
	file.close()
	
	return true

## The [method check_file] method checks if a file exists in the
## path specified by the [param path] parameter. [br]
## If the file doesn't exist, this method pushes an error and returns
## [code]false[/code], otherwise, it returns [code]true[/code]. [br]
## If the [param suppress_error] is [code]true[/code], though,
## no errors are, thrown.
static func check_file(
	path: String, suppress_error: bool = false
) -> bool:
	if not FileAccess.file_exists(path):
		if not suppress_error:
			push_error("File not found: '%s'" % path)
		
		return false
	
	return true

## The [method check_and_create_file] method uses the
## [method check_file] and [method create_file] methods
## to create a file only if it doesn't already exist. [br]
## See [method create_file] for more informations about the parameters.
static func check_and_create_file(
	path: String,
	content: String = "",
	suppress_error: bool = false
) -> bool:
	if not check_file(path, true):
		return write_or_create_file(path, content, suppress_error)
	
	return true

static func check_and_create_encrypted_file(
	path: String,
	encryption_pass: String,
	content: String = "",
	suppress_error: bool = false
) -> bool:
	if not check_file(path, true):
		return write_or_create_encrypted_file(
			path, encryption_pass, content, suppress_error
		)
	
	return true

## The [method read_file] method reads from a file in the
## path specified by the [param path] parameter. [br]
## Optionally, an [param encryption_pass] parameter can also be passed.
## Such parameter represents the password to be used when reading the file
## if it is desired to read it in encrypted mode.
## If an error occurs, this method pushes it and returns [code]""[/code],
## otherwise, it returns the [String] read from the file.
static func read_file(
	path: String, suppress_error: bool = false
) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	
	if file == null:
		if not suppress_error:
			var error: Error = FileAccess.get_open_error()
			
			push_error(
				"Error on reading file %s: %s(%s)" % [
					path,
					error_string(error),
					error
				]
			)
		
		return ""
	
	var result: String = file.get_as_text()
	
	file.close()
	
	return result

static func read_encrypted_file(
	path: String, encryption_pass: String, suppress_error: bool = false
) -> String:
	var file: FileAccess = FileAccess.open_encrypted_with_pass(
		path, FileAccess.READ, encryption_pass
	)
	
	if file == null:
		if not suppress_error:
			var error: Error = FileAccess.get_open_error()
			
			push_error(
				"Error on reading file %s: %s(%s)" % [
					path,
					error_string(error),
					error
				]
			)
		
		return ""
	
	var result: String = file.get_as_text()
	
	file.close()
	
	return result

static func get_file_format(file_name: String) -> String:
	var file_parts: PackedStringArray = file_name.rsplit(".", false, 1)
	var file_format: String = ""
	
	if file_parts.size() == 2:
		file_format = file_parts[1]
	
	return file_format

static func get_file_prefix(file_name: String) -> String:
	var file_parts: PackedStringArray = file_name.rsplit(".", true, 1)
	var file_prefix: String = ""
	
	if file_parts.size() > 0:
		file_prefix = file_parts[0]
	
	return file_prefix

func save_partition(
	_partition_path: String,
	_data: Dictionary,
	_replace: bool = false,
	_suppress_errors: bool = false
) -> Dictionary: return {}

func load_partition(
	_partition_path: String,
	_suppress_errors: bool = false
) -> Dictionary: return {}

## The [method save_data] method should be overwritten so that it saves
## the given [param data] in the file specified by the [param file_id]. [br]
## If the [param replace] flag is set to [code]true[/code], any previous
## data should be overwritten. [br]
## If the [param suppress_errors] is [code]true[/code], this method
## shouldn't push any errors. [br]
## At the end, this method should return a [Dictionary] with the data
## saved.
func save_data(
	file_path: String,
	file_format: String,
	data: Dictionary,
	replace: bool = false,
	suppress_errors: bool = false
) -> Dictionary:
	var result: Dictionary = {}
	
	for partition: String in data:
		var partition_path: String = "%s/%s.%s" % [
			file_path, partition, file_format
		]
		var partition_data: Dictionary = data[partition]
		
		result.merge(save_partition(
			partition_path, partition_data, replace, suppress_errors
		))
	
	return result

## The [method load_data] method should be overwritten so that it loads
## data from the file specified by the [param file_id]. [br]
## Iff the [param suppress_errors] is [code]true[/code], this method
## shouldn't push any errors. [br]
## At the end, this method should return a [Dictionary] with the data
## obtained.
func load_data(
	file_path: String,
	file_format: String,
	included_partitions: Array[String] = [],
	suppress_errors: bool = false
) -> Dictionary:
	var result: Dictionary = {}
	
	var all_partitions: PackedStringArray = read_directory(
		file_path,
		[ file_format ]
	)
	
	for partition: String in all_partitions:
		var partition_without_format: String = get_file_prefix(partition)
		
		if (
			not included_partitions.is_empty() and
			not partition_without_format in included_partitions
		):
			continue
		
		var partition_path: String = "%s/%s" % [
			file_path, partition
		]
		var partition_data: Dictionary = load_partition(
			partition_path, suppress_errors
		)
		
		result.merge(partition_data)
	
	return result
