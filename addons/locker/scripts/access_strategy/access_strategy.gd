@icon("res://addons/locker/icons/access_strategy.svg")
## The [LokAccessStrategy] super class is responsible for
## defining how the writing and reading from files should be performed.
## 
## This class should have its [method save_partition] and
## [method load_partition] methods overriden in order to
## provide concrete implementations for the saving and loading
## functionalities. [br]
## The [LokJSONAccessStrategy] and [LokEncryptedAccessStrategy] classes
## are two strategies built-in to the [LockerPlugin], but
## if you want, you can define your own access strategies
## inheriting from the [LokAccessStrategy] class. [br]
## If you need to deal with the file system when inheriting this class,
## the [LokFileSystemUtil] class provides lots of static methods that help
## with decreasing the boilerplate code needed for that. [br]
## [br]
## [b]Version[/b]: 1.0.0[br]
## [b]Author[/b]: [url]github.com/nadjiel[/url]
class_name LokAccessStrategy
extends RefCounted

## The [method create_result] method helps with the creation of a [Dictionary]
## representing the result of an operation done by this [LokAccessStrategy].
## [br]
## The returned [Dictionary] has two keys: the [code]"status"[/code], which
## stores a [enum @GlobalScope.Error] code, and the [code]"data"[/code],
## which stores a [Dictionary] with the resultant data of an operation.
static func create_result(
	data: Dictionary = {},
	status: Error = Error.OK
) -> Dictionary:
	var result: Dictionary = {}
	result["status"] = status
	result["data"] = data
	
	return result

## The [method get_partition_name] method receives a [param file_path],
## a [param partition_id] and a [param file_format], all of which are
## [String]s, and returns another [String] representing the name of the
## partition represented by those data. [br]
## The partition name here refers to the file name of the partition with
## the format suffix. [br]
## [b]Example:[/b]
## [codeblock]
## var partition_name: String = get_partition_name(
##   "res://saves/file_1", "partition_1", "sav"
## )
## # This would return "partition_1.sav"
## [/codeblock]
## In the case the [param partition_id] is an empty [String], this method
## considers it as being a partition with the same name as its file, so
## in the previous example, if the [param partition_id] was [code]""[/code],
## the result would be [code]"file_1.sav"[/code].
func get_partition_name(
	file_path: String,
	partition_id: String,
	file_format: String
) -> String:
	var file_name: String = LokFileSystemUtil.get_directory_name(file_path)
	var partition_name: String = partition_id
	
	if partition_name == "":
		partition_name = file_name
	
	partition_name = LokFileSystemUtil.join_file_name(
		partition_name, file_format
	)
	
	return partition_name

## The [method filter_data] method receives a [param data]
## [Dictionary] other parameters that serve as filters
## for which entries of that [Dictionary] should be kept. [br]
## The filter parameters are the [param accessor_ids], [param partition_ids] and
## the [param version_numbers]. All of these are [Array] of [String]s that
## identify the entries of the [param data] that should be kept in the
## [Dictionary] returned by this method. [br]
## To work properly, this method expects that the [param data] parameter
## follows the structure:
## [codeblock]
## {
##   "accessor_id_1": {
##     ...
##     "partition": <String>,
##     "version": <String> (optional)
##   },
##   "accessor_id_n": { ... }
## }
## [/codeblock]
func filter_data(
	data: Dictionary,
	accessor_ids: Array[String] = [],
	partition_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	var filtered_data: Dictionary = LokUtil.filter_dictionary(
		data,
		func(accessor_id: String, accessor_data: Dictionary) -> bool:
			var accessor_partition: String = accessor_data.get("partition", "")
			var accessor_version: String = accessor_data.get("version", "")
			
			return (
				LokUtil.filter_value(accessor_ids, accessor_id) and
				LokUtil.filter_value(partition_ids, accessor_partition) and
				LokUtil.filter_value(version_numbers, accessor_version)
			)
	)
	
	return filtered_data

## The [method append_partition_to_data] method receives a [param data]
## [Dictionary] and a [param partition_id] [String].
## The [param data] parameter must be a [Dictionary] with other [Dictionary]s
## as its values, so that this method can set that
## [param partition_id] as the value of a [code]"partition"[/code] key
## in each of those sub dictionaries.
func append_partition_to_data(
	data: Dictionary,
	partition_id: String
) -> Dictionary:
	return LokUtil.map_dictionary(
		data,
		func(accessor_id: String, accessor_data: Dictionary) -> Dictionary:
			accessor_data["partition"] = partition_id
			
			return accessor_data
	)

## The [method get_file_id] method returns a [String] with the id of
## a file that has [param file_name] as its name. [br]
## If the file has no [code]"_"[/code], its entire name is its id, else,
## its id is considered to be the part after the first [code]"_"[/code].
func get_file_id(file_name: String) -> String:
	var file_parts: PackedStringArray = file_name.split("_", false, 1)
	
	if file_parts.size() > 1:
		return file_parts[1]
	
	return file_parts[0]

## The [method get_file_ids] method returns a result [Dictionary]
## (with the same structure of the one created by the [method create_result])
## whose [code]"data"[/code] field stores an [Array] of [String]s
## with the ids of all files saved in the [param files_path].
func get_file_ids(files_path: String) -> Dictionary:
	var result: Dictionary = create_result()
	result["data"] = []
	
	if not LokFileSystemUtil.directory_exists(files_path):
		result["status"] = Error.ERR_FILE_NOT_FOUND
		return result
	
	var file_names: PackedStringArray = LokFileSystemUtil.get_subdirectory_names(
		files_path
	)
	
	var file_ids: Array[String] = []
	
	for file_name: String in file_names:
		file_ids.append(get_file_id(file_name))
	
	result["data"] = file_ids
	
	return result

## The [method save_data] method uses the [method save_partition] to
## save the information provided through the [param data] [Dictionary] in
## their respective partitions. [br]
## The [param file_path] parameter should specify the path to the folder where
## the data is to be saved and the [param file_format] specifies what's the
## format of the files that compose the data saved (such format shouldn't
## include the [code]"."[/code]). [br]
## Optionally, the [param replace] parameter can be passed to tell if the
## data should override any already existent data. [br]
## The structure that the [param data] [Dictionary] should have is as follows:
## [codeblock]
## {
##   "partition_id_1": {
##     "accessor_id_1": {
##       ...
##       "version": <String> (optional)
##     },
##     "accessor_id_n": { ... },
##   },
##   "partition_id_n": { ... }
## }
## [/codeblock][br]
## The return of this method is a [Dictionary] with a [code]"status"[/code]
## field representing the status of the operation and a [code]"data"[/code]
## field with the data that was saved. That [Dictionary] follows the same
## structure as the one in returned by the [method load_data] method.
func save_data(
	file_path: String,
	file_format: String,
	data: Dictionary,
	replace: bool = false
) -> Dictionary:
	var result: Dictionary = create_result()
	
	# Create file directory
	result["status"] = LokFileSystemUtil.create_directory_if_not_exists(
		file_path
	)
	
	# Cancel if directory wasn't created
	if result["status"] != Error.OK:
		return result
	
	# Save each partition
	for partition_id: String in data:
		var partition_name: String = get_partition_name(
			file_path, partition_id, file_format
		)
		var partition_path: String = file_path.path_join(partition_name)
		var partition_data: Dictionary = data[partition_id]
		
		var partition_result: Dictionary = save_partition(
			partition_path, partition_data, replace
		)
		
		result["status"] = partition_result["status"]
		
		# Cancel if partition didn't save
		if result["status"] != Error.OK:
			return result
		
		append_partition_to_data(partition_result["data"], partition_id)
		
		result["data"].merge(partition_result["data"])
	
	var all_partitions: PackedStringArray = LokFileSystemUtil.get_file_names(
		file_path, [ file_format ]
	)
	
	return result

## The [method load_data] method uses the [method load_partition] method to
## load the information from the save directory in the [param file_path]. [br]
## The [param file_format] parameter specifies from what file format the data
## should be read (such format shouldn't include the [code]"."[/code]). [br]
## Optionally, a [param partition_ids] parameter can be passed to
## specify from what partitions the data should be loaded. [br]
## Also, [param accessor_ids] and [param version_numbers] can be passed to
## filter even more what information to bring back. [br]
## If left as default, that means all partitions, accessors, and versions
## are read, which corresponds to all data from the save file. [br]
## After completing the loading, this method returns a [Dictionary] containing
## all data obtained. Its format is as follows:
## [codeblock]
## {
##   "status": <@GlobalScope.Error>,
##   "data": {
##     "accessor_id_1": {
##       ...
##       "version": <String> (optional),
##       "partition": <String>
##     },
##     "accessor_id_n": { ... }
##   }
## }
## [/codeblock]
## If an error occurs, the corresponding [enum @GlobalScope.Error] code is returned
## in the [code]"status"[/code] field of the [Dictionary].
func load_data(
	file_path: String,
	file_format: String,
	partition_ids: Array[String] = [],
	accessor_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	var result: Dictionary = create_result()
	
	# Cancel if file doesn't exist
	if not LokFileSystemUtil.directory_exists(file_path):
		result["status"] = Error.ERR_FILE_NOT_FOUND
		return result
	
	# Get all partitions stored (with file format)
	var all_partition_names: PackedStringArray = LokFileSystemUtil.get_file_names(
		file_path,
		[ file_format ]
	)
	
	# For each partition stored
	for partition_name: String in all_partition_names:
		# Get partition id from its file name
		var partition_id: String = LokFileSystemUtil.get_file_prefix(
			partition_name
		)
		
		# Filter out unwanted partitions
		if not LokUtil.filter_value(partition_ids, partition_id):
			continue
		
		var partition_path: String = file_path.path_join(partition_name)
		
		var partition_result: Dictionary = load_partition(
			partition_path
		)
		
		result["status"] = partition_result["status"]
		
		# Don't load this partition if error appears
		if result["status"] != Error.OK:
			continue
		
		append_partition_to_data(
			partition_result.get("data", {}),
			partition_id
		)
		
		result["data"].merge(partition_result["data"])
	
	# End if there are no more filters to apply
	if accessor_ids.is_empty() and version_numbers.is_empty():
		return result
	
	var filtered_data: Dictionary = filter_data(
		result["data"], accessor_ids, partition_ids, version_numbers
	)
	
	result["data"] = filtered_data
	
	return result

## The [method remove_data] method uses the [method remove_partition] method to
## remove the save directory in the [param file_path], or some of its data. [br]
## The [param file_format] parameter specifies from what file format the data
## should be removed (such format shouldn't include the [code]"."[/code]). [br]
## Optionally, a [param partition_ids] parameter can be passed to
## specify from what partitions the data should be removed. [br]
## Also, [param accessor_ids] and [param version_numbers] can be passed to
## filter even more what information to remove. [br]
## If left as default, that means all partitions, accessors, and versions
## are removed, which corresponds to all data from the save file. [br]
## After completing the removal, this method returns a [Dictionary] containing
## all data obtained. That [Dictionary] brings the removed data in the
## [code]"data"[/code] field and the data the wasn't removed stays in the
## [code]"updated_data"[/code] field. The format of the returned [Dictionary]
## is shown in more details below:
## [codeblock]
## {
##   "status": <@GlobalScope.Error>,
##   "data": {
##     "accessor_id_1": {
##       ...
##       "version": <String> (optional),
##       "partition": <String>
##     },
##     "accessor_id_n": { ... }
##   },
##   "updated_data": { ... }
## }
## [/codeblock]
## If an error occurs, the corresponding [enum @GlobalScope.Error] code is
## returned in the [code]"status"[/code] field of the [Dictionary].
func remove_data(
	file_path: String,
	file_format: String,
	partition_ids: Array[String] = [],
	accessor_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	var result: Dictionary = create_result()
	
	result["updated_data"] = {}
	
	# Cancel if file doesn't exist
	if not LokFileSystemUtil.directory_exists(file_path):
		result["status"] = Error.ERR_FILE_NOT_FOUND
		return result
	
	# Get all partitions stored (with file format)
	var all_partitions: PackedStringArray = LokFileSystemUtil.get_file_names(
		file_path,
		[ file_format ]
	)
	
	# For each partition stored
	for partition_name: String in all_partitions:
		var partition_id: String = LokFileSystemUtil.get_file_prefix(
			partition_name
		)
		
		# Filter out unwanted partitions
		if not LokUtil.filter_value(partition_ids, partition_id):
			continue
		
		var partition_path: String = file_path.path_join(partition_name)
		
		var partition_result: Dictionary = remove_partition(
			partition_path, accessor_ids, version_numbers
		)
		
		result["status"] = partition_result["status"]
		
		# Cancel loading if error appears
		if result["status"] != Error.OK:
			break
		
		result["data"].merge(partition_result["data"])
		result["updated_data"].merge(partition_result["updated_data"])
	
	# Remove file directory, if left empty
	if LokFileSystemUtil.directory_is_empty(file_path):
		LokFileSystemUtil.remove_directory_or_file(file_path)
	
	return result

## The [method remove_partition] method removes data from the partition
## specified by the [param partition_path] parameter.
## [br]
## At the end, this method returns a [Dictionary] with the data
## obtained. The format of that [Dictionary] follows the same
## structure as the one returned by the [method remove_data] method.
func remove_partition(
	partition_path: String,
	accessor_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	# Load so that removed data can be returned
	var result: Dictionary = load_partition(
		partition_path
	)
	
	result["updated_data"] = {}
	
	# If an error occurred, abort
	if result.get("status", Error.OK) != Error.OK:
		return result
	
	var split_data: Array[Dictionary] = [
		result.get("data", {}),
		result.get("updated_data", {})
	]
	
	if not accessor_ids.is_empty() or not version_numbers.is_empty():
		# Separate data to be removed and data to stay
		split_data = LokUtil.split_dictionary(
			result.get("data", {}),
			func(accessor_id: String, accessor_data: Dictionary) -> bool:
				var accessor_version: String = accessor_data.get("version", "")
				
				return (
					LokUtil.filter_value(accessor_ids, accessor_id) and
					LokUtil.filter_value(version_numbers, accessor_version)
				)
		)
	
	result["data"] = split_data[0]
	result["updated_data"] = split_data[1]
	
	# If nothing is to stay, remove everything
	if result["updated_data"].is_empty():
		LokFileSystemUtil.remove_file_if_exists(partition_path)
	# Update data with only what should stay
	else:
		save_partition(
			partition_path, result["updated_data"], true
		)
	
	var partition_name: String = LokFileSystemUtil.get_file_name(partition_path)
	var partition_id: String = LokFileSystemUtil.get_file_prefix(partition_name)
	
	# Append partition ids to resultant data
	append_partition_to_data(result["data"], partition_id)
	append_partition_to_data(result["updated_data"], partition_id)
	
	return result

## The [method save_partition] method should be overwritten so that it saves
## [param data] in the partition specified by the [param partition_path]
## parameter. [br]
## Optionally, the [param replace] parameter can be passed to tell if the
## data should override any already existent data. [br]
## The format of the [param data] [Dictionary] should follow the structure
## below:
## [codeblock]
## {
##   "accessor_id_1": {
##     ...
##     "version": <String> (optional)
##   },
##   "accessor_id_n": { ... },
## }
## [/codeblock]
func save_partition(
	_partition_path: String,
	_data: Dictionary,
	_replace: bool = false
) -> Dictionary: return {}

## The [method load_partition] method should be overwritten so that it loads
## data from the partition specified by the [param partition_path] parameter.
## [br]
## At the end, this method should return a [Dictionary] with the data
## obtained. The format of that [Dictionary] should follow the same
## structure as the one returned by the [method load_data] method.
func load_partition(
	_partition_path: String
) -> Dictionary: return {}
