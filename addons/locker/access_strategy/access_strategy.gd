@icon("res://addons/locker/icons/access_strategy.svg")
## The [LokAccessStrategy] super class is responsible for
## defining how the writing and reading from files should be performed.
## 
## This class should have its [method save_partition] and
## [method load_partition] methods overriden in order to
## provide concrete implementations for the saving and loading
## functionalities.
## [br]
## Besides that, this class provides multiple static utility methods to help
## with boilerplate code when dealing with the file system.
## [br]
## [b]Version[/b]: 1.0.0[br]
## [b]Author[/b]: [url]github.com/nadjiel[/url]
class_name LokAccessStrategy
extends Resource

static func push_error_unrecognized_partition(path: String) -> void:
	push_error("Couldn't parse unrecognized partition '%s'" % path)

static func push_error_directory_creation_failed(
	path: String, error_code: Error
) -> void:
	push_error("Error on directory creation in path '%s': %s(%s)" % [
		path,
		error_string(error_code),
		error_code
	])

static func push_error_directory_not_found(path: String) -> void:
	push_error("Directory not found in path '%s'" % path)

static func push_error_file_writing_or_creation_failed(
	path: String, error_code: Error
) -> void:
	push_error("Error on writing or creating file in path %s: %s(%s)" % [
		path,
		error_string(error_code),
		error_code
	])

static func push_error_file_not_found(path: String) -> void:
	push_error("File not found in path '%s'" % path)

static func push_error_file_reading_failed(
	path: String, error_code: Error
) -> void:
	push_error("Error on reading file in path %s: %s(%s)" % [
		path,
		error_string(error_code),
		error_code
	])

## The [method create_directory] method creates a new directory in the
## path specified by the [param path] parameter. [br]
## If an error occurs, this method pushes it and returns [code]false[/code],
## otherwise, it returns [code]true[/code].
static func create_directory(path: String) -> bool:
	var err: Error = DirAccess.make_dir_recursive_absolute(path)
	
	if err != OK:
		push_error_directory_creation_failed(path, err)
		
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
			push_error_directory_not_found(path)
		
		return false
	
	return true

## The [method check_and_create_directory] method uses the
## [method check_directory] and [method create_directory] methods
## to create a directory only if it doesn't already exist.
static func check_and_create_directory(path: String) -> bool:
	if not check_directory(path, true):
		return create_directory(path)
	
	return true

## The [method read_directory] method scans the files of a directory
## in a given [param path] and returns their names in a [PackedStringArray].
## [br]
## The [param formats] parameter is used to filter what file formats should
## be included in the final result (without the "."). [br]
## If this parameter is left as default, that means all file formats are
## included.
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

## The [method write_or_create_file] method creates a new file in the
## path specified by the [param path] parameter, if it doesn't already
## exists, else, it simply writes in that file. [br]
## Optionally, this method can receive a [param content] parameter
## that defines what should be written in the file. [br]
## Besides that, a [param suppress_errors] parameter can be passed to
## tell if this method should push any errors that might occur.
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
			
			push_error_file_writing_or_creation_failed(path, error)
		
		return false
	
	file.store_string(content)
	
	file.close()
	
	return true

## The [method write_or_create_encrypted_file] method creates a new file in the
## path specified by the [param path] parameter, if it doesn't already
## exists, else, it simply writes in that file using encryption. [br]
## The [param encryption_pass] parameter is used as the password to encrypt
## the contents of the file. [br]
## Optionally, this method can receive a [param content] parameter
## that defines what should be written in the file. [br]
## Besides that, a [param suppress_errors] parameter can be passed to
## tell if this method should push any errors that might occur.
## If an error occurs, this method pushes it and returns [code]false[/code],
## otherwise, it returns [code]true[/code].
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
			
			push_error_file_writing_or_creation_failed(path, error)
		
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
			push_error_file_not_found(path)
		
		return false
	
	return true

## The [method check_and_create_file] method uses the
## [method check_file] and [method write_or_create_file] methods
## to create a file only if it doesn't already exist. [br]
## See [method write_or_create_file] for more informations about the parameters.
static func check_and_create_file(
	path: String,
	content: String = "",
	suppress_error: bool = false
) -> bool:
	if not check_file(path, true):
		return write_or_create_file(path, content, suppress_error)
	
	return true

## The [method check_and_create_encrypted_file] method uses the
## [method check_file] and [method write_or_create_encrypted_file] methods
## to create a file (using encryption) only if it doesn't already exist. [br]
## See [method write_or_create_encrypted_file] for
## more informations about the parameters.
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
## Optionally, a [param suppress_error] parameter can be passed to
## prevent this method from pushing errors. [br]
## If an error occurs, this method pushes it and returns [code]""[/code],
## otherwise, it returns the [String] read from the file.
static func read_file(
	path: String, suppress_error: bool = false
) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	
	if file == null:
		if not suppress_error:
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
## Optionally, a [param suppress_error] parameter can be passed to
## prevent this method from pushing errors. [br]
## If an error occurs, this method pushes it and returns [code]""[/code],
## otherwise, it returns the [String] read from the file.
static func read_encrypted_file(
	path: String, encryption_pass: String, suppress_error: bool = false
) -> String:
	var file: FileAccess = FileAccess.open_encrypted_with_pass(
		path, FileAccess.READ, encryption_pass
	)
	
	if file == null:
		if not suppress_error:
			var error: Error = FileAccess.get_open_error()
			
			push_error_file_reading_failed(path, error)
		
		return ""
	
	var result: String = file.get_as_text()
	
	file.close()
	
	return result

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

## The [method save_data] method uses the [method save_partition] to
## save the information provided through the [param data] [Dictionary] in
## their respective partitions. [br]
## The [param file_path] parameter should specify the path to the folder where
## the data is to be saved and the [param file_format] specifies what's the
## format of the files that compose the data saved (such format shouldn't
## include the [code]"."[/code]). [br]
## Optionally, the [param replace] parameter can be passed to tell if the
## data should override any already existent data. [br]
## Also, the [param suppress_errors] flag can be passed to identify if this
## method should or not push any errors that occur. [br]
## The format of the [param data] [Dictionary] should be as follows:
## [codeblock]
## {
##   "partition_name_1": {
##     "accessor_id_1": {
##       "version": "version_number",
##       "data_1": "data",
##       "data_n": "data"
##     },
##     "accessor_id_n": { ... },
##   },
##   "partition_name_n": { ... }
## }
## [/codeblock]
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

## The [method load_data] method uses the [method load_partition] method to
## load the information from the save directory in the [param file_path]. [br]
## The [param file_format] parameter specifies from what file format the data
## should be read (such format shouldn't include the [code]"."[/code]). [br]
## Optionally, a [param included_partitions] parameter can be passed to
## specify from what partitions the data should be loaded. [br]
## If left as default, that means all partitions are read, which corresponds
## to all data from the save file.
## Also, the [param suppress_errors] flag can be passed to identify if this
## method should or not push any errors that occur. [br]
## After completing the loading, this method returns a [Dictionary] containing
## all data obtained. Its format is as follows:
## [codeblock]
## {
##   "accessor_id_1": {
##     "version": "version_number",
##     "partition": "parition_name",
##     "data_1": "data",
##     "data_n": "data"
##   },
##   "accessor_id_n": { ... },
## }
## [/codeblock]
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

## The [method save_partition] method should be overwritten so that it saves
## [param data] in the partition specified by the
## [param partition_path] parameter.
## [br]
## Optionally, the [param replace] parameter can be passed to tell if the
## data should override any already existent data. [br]
## Also, the [param suppress_errors] flag can be passed to identify if this
## method should or not push any errors that occur. [br]
## The format of the [param data] [Dictionary] should be as follows:
## [codeblock]
## {
##   "accessor_id_1": {
##     "version": "version_number",
##     "data_1": "data",
##     "data_n": "data"
##   },
##   "accessor_id_n": { ... },
## }
## [/codeblock]
func save_partition(
	_partition_path: String,
	_data: Dictionary,
	_replace: bool = false,
	_suppress_errors: bool = false
) -> Dictionary: return {}

## The [method load_partition] method should be overwritten so that it loads
## data from the partition specified by the [param partition_path] parameter.
## [br]
## If the [param suppress_errors] parameter is [code]true[/code], this method
## shouldn't push any errors. [br]
## At the end, this method should return a [Dictionary] with the data
## obtained. The format of such [Dictionary] should follow the structure:
## [codeblock]
## {
##   "accessor_id_1": {
##     "version": "version_number",
##     "partition": "partition_name",
##     "data_1": "data",
##     "data_n": "data"
##   },
##   "accessor_id_n": { ... },
## }
## [/codeblock]
func load_partition(
	_partition_path: String,
	_suppress_errors: bool = false
) -> Dictionary: return {}
