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
## with decreasing boilerplate code needed for that. [br]
## [br]
## [b]Version[/b]: 1.0.0[br]
## [b]Author[/b]: [url]github.com/nadjiel[/url]
class_name LokAccessStrategy
extends Resource

## The [method create_result] method helps with the creation of a [Dictionary]
## representing the result of an operation done by this [LokAccessStrategy].
## [br]
## The returned [Dictionary] has two keys: the [code]"status"[/code], which
## stores a [enum @GlobalScope.Error] code, and the [code]"data"[/code],
## which stores a [Dictionary] with the resultant data of an operation.
func create_result(
	data: Dictionary = {},
	status: Error = Error.OK
) -> Dictionary:
	var result: Dictionary = {}
	result["status"] = status
	result["data"] = data
	
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
## Also, the [param suppress_errors] flag can be passed to identify if this
## method should or shouldn't push any errors that occur. [br]
## The structure that the [param data] [Dictionary] should have is as follows:
## [codeblock]
## {
##   "partition_name_1": {
##     "accessor_id_1": {
##       "version": "version_number",
##       "data_1": <data>,
##       "data_n": <data>
##     },
##     "accessor_id_n": { ... },
##   },
##   "partition_name_n": { ... }
## }
## [/codeblock][br]
## The return of this method is a [Dictionary] with the [code]"status"[/code]
## of the operation and the [code]"data"[/code] that was saved. [br]
## (See [method create_result])
func save_data(
	file_path: String,
	file_format: String,
	data: Dictionary,
	replace: bool = false,
	suppress_errors: bool = false
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
	for partition: String in data:
		var partition_name: String = LokFileSystemUtil.join_file_name(
			partition, file_format
		)
		#var partition_name: String = "%s.%s" % [ partition, file_format ]
		var partition_path: String = file_path.path_join(partition_name)
		#var partition_path: String = "%s/%s.%s" % [
			#file_path, partition, file_format
		#]
		var partition_data: Dictionary = data[partition]
		
		#print("%s: Started saving partition %s;" % [
			#Time.get_ticks_msec(),
			#partition_path
		#])
		
		var partition_result: Dictionary = save_partition(
			partition_path, partition_data, replace, suppress_errors
		)
		
		result["status"] = partition_result["status"]
		
		# Cancel if partition didn't save
		if result["status"] != Error.OK:
			return result
		
		result["data"].merge(partition_result["data"])
		
		#print("%s: Finished saving partition %s;" % [
			#Time.get_ticks_msec(),
			#partition_path
		#])
	
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
## Furthermore, the [param suppress_errors] flag can be passed to identify if
## this method should or shouldn't push any errors that occur. [br]
## After completing the loading, this method returns a [Dictionary] containing
## all data obtained. Its format is as follows:
## [codeblock]
## {
##   "status": <error_code>,
##   "data": {
##     "partition_id_1": {
##       "accessor_id_1": {
##         "version": "version_number",
##         "data_1": <data>,
##         "data_n": <data>
##       },
##       "accessor_id_n": { ... },
##     },
##     "partition_id_n": { ... }
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
	version_numbers: Array[String] = [],
	suppress_errors: bool = false
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
			partition_path, suppress_errors
		)
		
		result["status"] = partition_result["status"]
		
		# Cancel loading if error appears
		if result["status"] != Error.OK:
			break
		
		result["data"].merge(partition_result["data"])
	
	# End if there are no more filters to apply
	if accessor_ids.is_empty() and version_numbers.is_empty():
		return result
	
	var filtered_data: Dictionary = {}
	
	# For each accessor loaded
	for accessor_id: String in result["data"]:
		var accessor_data: Dictionary = result["data"][accessor_id]
		var accessor_version: String = accessor_data.get("version", "")
		
		# Filter out unwanted accessors and versions
		if not LokUtil.filter_value(accessor_ids, accessor_id):
			continue
		if not LokUtil.filter_value(version_numbers, accessor_version):
			continue
		
		filtered_data[accessor_id] = accessor_data
	
	result["data"] = filtered_data
	
	return result

func remove_data(
	file_path: String,
	file_format: String,
	partition_ids: Array[String] = [],
	accessor_ids: Array[String] = [],
	version_numbers: Array[String] = [],
	suppress_errors: bool = false
) -> Dictionary:
	var result: Dictionary = create_result()
	
	# Cancel if file doesn't exist
	if not LokFileSystemUtil.directory_exists(file_path):
		result["status"] = Error.ERR_FILE_NOT_FOUND
		return result
	
	var removed_data: Dictionary = {}
	
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
			partition_path, accessor_ids, version_numbers, suppress_errors
		)
		
		result["status"] = partition_result["status"]
		
		# Cancel loading if error appears
		if result["status"] != Error.OK:
			break
		
		result["data"].merge(partition_result["data"])
	
	# Remove file directory, if left empty
	if LokFileSystemUtil.directory_is_empty(file_path):
		LokFileSystemUtil.remove_directory_or_file(file_path)
	
	return removed_data

func remove_partition(
	partition_path: String,
	accessor_ids: Array[String] = [],
	version_numbers: Array[String] = [],
	suppress_errors: bool = false
) -> Dictionary:
	var result: Dictionary = create_result()
	
	# Cancel if file doesn't exist
	if not LokFileSystemUtil.file_exists(partition_path):
		LokFileSystemUtil.push_error_file_not_found(partition_path)
		
		result["status"] = Error.ERR_FILE_NOT_FOUND
		return result
	
	result = load_partition(partition_path, suppress_errors)
	
	var data: Dictionary = result.get("data", {})
	
	# If nothing is to stay, remove everything
	if accessor_ids.is_empty() and version_numbers.is_empty():
		LokFileSystemUtil.remove_directory_or_file(partition_path)
		
		return result
	
	var split_data: Array[Dictionary] = LokUtil.split_dictionary(
		data,
		func(accessor_id: String, accessor_data: Dictionary) -> bool:
			var accessor_version: String = accessor_data.get("version", "")
			
			return (
				LokUtil.filter_value(accessor_ids, accessor_id) and
				LokUtil.filter_value(version_numbers, accessor_version)
			)
	)
	
	var removed_data: Dictionary = split_data[0]
	var updated_data: Dictionary = split_data[1]
	
	result["data"] = removed_data
	result["updated_data"] = updated_data
	
	if updated_data.is_empty():
		LokFileSystemUtil.remove_directory_or_file(partition_path)
		
		return result
	
	save_partition(partition_path, updated_data, true, suppress_errors)
	
	return result
	
	
	
	#var data: Dictionary = load_partition(partition_path, suppress_errors)
	#
	#if accessor_ids.is_empty() and version_numbers.is_empty():
		#LokFileSystemUtil.remove_directory_or_file(partition_path)
		#
		#return data
	#
	#var new_data: Dictionary = {}
	#var removed_data: Dictionary = {}
	#
	#for accessor_id: String in data:
		#var accessor_data: Dictionary = data[accessor_id]
		#var accessor_version: String = accessor_data.get("version", "")
		#
		#if (
			#LokUtil.filter_value(accessor_ids, accessor_id) and
			#LokUtil.filter_value(version_numbers, accessor_version)
		#):
			#removed_data[accessor_id] = accessor_data
			#
			#continue
		#
		#accessor_data.erase("partition")
		#new_data[accessor_id] = accessor_data
	#
	#if new_data.is_empty():
		#LokFileSystemUtil.remove_directory_or_file(partition_path)
		#
		#return removed_data
	#
	#save_partition(partition_path, new_data, true, suppress_errors)
	#
	#return removed_data

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
	_bring_partition: bool = true,
	_suppress_errors: bool = false
) -> Dictionary: return {}
