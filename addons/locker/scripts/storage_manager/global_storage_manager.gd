
## The [LokGlobalStorageManager] class serves as the manager of the data
## saving and loading process.
## 
## This class is registered as an autoload when the [LockerPlugin] is active,
## so that it can do its tasks. [br]
## It's this class that's responsible for keeping track of all the
## [LokStorageAccessor]s that need saving and loading.
extends LokStorageManager

#region Properties

var saves_directory: String = LockerPlugin.get_setting_saves_directory():
	set = set_saves_directory,
	get = get_saves_directory

var save_files_prefix: String = LockerPlugin.get_setting_save_files_prefix():
	set = set_save_files_prefix,
	get = get_save_files_prefix

var save_files_format: String = LockerPlugin.get_setting_save_files_format():
	set = set_save_files_format,
	get = get_save_files_format

var save_versions: bool = LockerPlugin.get_setting_save_versions():
	set = set_save_versions,
	get = get_save_versions

var access_executor: LokAccessExecutor = LokAccessExecutor.new():
	set = set_access_executor,
	get = get_access_executor

#endregion

#region Setters & Getters

func set_saves_directory(new_directory: String) -> void:
	saves_directory = new_directory

func get_saves_directory() -> String:
	return saves_directory

func set_save_files_prefix(new_prefix: String) -> void:
	save_files_prefix = new_prefix

func get_save_files_prefix() -> String:
	return save_files_prefix

func set_save_files_format(new_format: String) -> void:
	save_files_format = new_format

func get_save_files_format() -> String:
	return save_files_format

func set_save_versions(new_value: bool) -> void:
	save_versions = new_value

func get_save_versions() -> bool:
	return save_versions

func set_access_executor(new_executor: LokAccessExecutor) -> void:
	access_executor = new_executor

func get_access_executor() -> LokAccessExecutor:
	return access_executor

func set_access_strategy(new_strategy: LokAccessStrategy) -> void:
	if access_executor == null:
		push_warning_no_executor()
		return
	
	access_executor.access_strategy = new_strategy

func get_access_strategy() -> LokAccessStrategy:
	if access_executor == null:
		push_warning_no_executor()
		return
	
	return access_executor.access_strategy

#endregion

#region Debug Methods

func push_warning_no_executor() -> void:
	push_error("%s: No AccessExecutor found in %s" % [
		error_string(Error.ERR_UNCONFIGURED),
		get_readable_name()
	])

#endregion

#region Methods

func get_accessor_ids(
	from_accessors: Array[LokStorageAccessor]
) -> Array[String]:
	var accessor_ids: Array[String] = []
	
	for accessor: LokStorageAccessor in from_accessors:
		accessor_ids.append(accessor.id)
	
	return accessor_ids

func get_file_path(file_id: String) -> String:
	var file_path: String = saves_directory.path_join(save_files_prefix)
	
	if file_id != "":
		file_path = "%s_%s" % [ file_path, file_id ]
	
	return file_path

## The [method collect_data] method is used to get and organize the data
## from an [param accessor].[br]
## Optionally, a [param version_number] can be passed to dictate from which
## version of the [param accessor] the data should be got. If left undefined,
## this parameter defaults to the version [code]""[/code], which
## converts to the latest available.[br]
## At the end, this method returns a [Dictionary] with all the data obtained
## from the [param accessor]. It's structure is the following:[br]
## [codeblock]
## {
##   "version" = "version_number",
##   "accessor_data_1" = <data>,
##   "accessor_data_n" = <data>
## }
## [/codeblock]
func collect_data(
	accessor: LokStorageAccessor,
	version_number: String = ""
) -> Dictionary:
	if accessor == null:
		return {}
	
	accessor.set_version_number(version_number)
	
	var accessor_version: String = accessor.get_version_number()
	var accessor_data: Dictionary = accessor.retrieve_data()
	
	if accessor_data.is_empty():
		return {}
	
	if save_versions:
		if accessor_version != "":
			accessor_data["version"] = accessor_version
	
	return accessor_data

## The [method gather_data] method is the central point where the data
## from all [member accessors] is collected using the
## [method collect_data] method.[br]
## If the [param accessor_ids] parameter is not empty, this method only
## gathers data from the [LokStorageAccessor]s that match those ids.[br]
## The [param version_number] parameter is used as the version of the
## [LokStorageAccessor]s from which the data is collected. If left undefined,
## this parameter defaults to [code]""[/code], which converts
## to the latest version.[br]
## In the case there's [member LokStorageAccessor.id] conflicts in the
## same [member LokStorageAccessor.partition],
## the id of the last accessor encountered is prioritized. It is often
## unknown, though, which accessor is the last one, so it's always better
## to avoid repeated ids.[br]
## At the end, this method returns a [Dictionary] with all the data obtained
## from the [LokStorageAccessor]s. It's structure is the following:[br]
## [codeblock]
## {
##   "partition_1_id": {
##     "accessor_1_id": {
##       "version": "version_number",
##       "data_1": <data>,
##       "data_n": <data>
##     },
##     "accessor_n_id": { ... }
##   },
##   "partition_n_id": { ... }
## }
## [/codeblock]
func gather_data(
	included_accessors: Array[LokStorageAccessor] = [], version_number: String = ""
) -> Dictionary:
	var data: Dictionary = {}
	
	for accessor: LokStorageAccessor in accessors:
		if accessor.id == "":
			continue
		if not LokUtil.filter_value(included_accessors, accessor):
			continue
		
		var accessor_data: Dictionary = collect_data(accessor, version_number)
		
		if accessor_data.is_empty():
			continue
		
		if not data.has(accessor.partition):
			data[accessor.partition] = {}
		
		data[accessor.partition][accessor.id] = accessor_data
	
	return data

## The [method distribute_result] method is the central point where the data
## can be distributed to all [member accessors].[br]
## If the [param accessor_ids] parameter is not empty, this method only
## distributes data to the [LokStorageAccessor]s that match those ids.[br]
## The version of the [LokStorageAccessor]s that receives the data is
## determined by the [code]"version"[/code] key of its data in the [param data]
## [Dictionary]. If there's no such entry, the version that receives the
## data is the latest available.[br]
## If there are more than one [LokStorageAccessor]s with the same id found,
## the data with that id is distributed to all of these [LokStorageAccessor]s.
## [br]
## The [param data] [Dictionary] that this method expects should match the
## following pattern:[br]
## [codeblock]
## {
##   "accessor_1_id": {
##     "version": "version_number",
##     "data_1": <data>,
##     "data_n": <data>
##   },
##   "accessor_n_id": { ... }
## }
## [/codeblock]
func distribute_result(
	result: Dictionary, included_accessors: Array[LokStorageAccessor] = []
) -> void:
	for accessor: LokStorageAccessor in accessors:
		if not LokUtil.filter_value(included_accessors, accessor):
			continue
		
		var status: Error = result.get("status", Error.OK)
		var data: Dictionary = result.get("data", {})
		
		var accessor_data: Dictionary = data.get(accessor.id, {})
		var accessor_result: Dictionary = {
			"status": status,
			"data": accessor_data
		}
		
		var accessor_version: String = accessor_data.get("version", "")
		
		accessor.set_version_number(accessor_version)
		accessor.consume_data(accessor_result.duplicate(true))

## Another optional parameter this method accept is the [param accessor_ids],
## which is a list that enumerates the ids of the [LokStorageAccessor]
## 
## To better understand these parameters, read about that method.
func save_data(
	file_id: String = current_file,
	version_number: String = current_version,
	accessors: Array[LokStorageAccessor] = [],
	replace: bool = false
) -> Dictionary:
	if file_id == "" and current_file != "":
		file_id = current_file
	
	var file_path: String = get_file_path(file_id)
	var file_format: String = save_files_format
	
	var data: Dictionary = gather_data(accessors, version_number)
	
	saving_started.emit()
	
	var result: Dictionary = await access_executor.request_saving(
		file_path, file_format, data, replace
	)
	
	saving_finished.emit(result)
	
	return result

func load_data(
	file_id: String = current_file,
	included_accessors: Array[LokStorageAccessor] = [],
	partition_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	if file_id == "" and current_file != "":
		file_id = current_file
	
	var file_path: String = get_file_path(file_id)
	var file_format: String = save_files_format
	
	var accessor_ids: Array[String] = get_accessor_ids(included_accessors)
	
	loading_started.emit()
	
	var result: Dictionary = await access_executor.request_loading(
		file_path,
		file_format,
		partition_ids,
		accessor_ids,
		version_numbers
	)
	
	loading_finished.emit(result)
	
	distribute_result(result, included_accessors)
	
	return result

func read_data(
	file_id: String = current_file,
	included_accessors: Array[LokStorageAccessor] = [],
	partition_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	if file_id == "" and current_file != "":
		file_id = current_file
	
	var file_path: String = get_file_path(file_id)
	var file_format: String = save_files_format
	
	var accessor_ids: Array[String] = get_accessor_ids(included_accessors)
	
	reading_started.emit()
	
	var result: Dictionary = await access_executor.request_reading(
		file_path, file_format, partition_ids, accessor_ids, version_numbers
	)
	
	reading_finished.emit(result)
	
	return result

func remove_data(
	file_id: String = current_file,
	included_accessors: Array[LokStorageAccessor] = [],
	partition_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	if file_id == "" and current_file != "":
		file_id = current_file
	
	var file_path: String = get_file_path(file_id)
	var file_format: String = save_files_format
	
	var accessor_ids: Array[String] = get_accessor_ids(included_accessors)
	
	removing_started.emit()
	
	var result: Dictionary = await access_executor.request_removing(
		file_path, file_format, partition_ids, accessor_ids, version_numbers
	)
	
	removing_finished.emit(result)
	
	return result

# Initializes values according to settings
func _init() -> void:
	set_access_strategy(LockerPlugin.get_setting_access_strategy_parsed())
	
	var access_strategy: LokAccessStrategy = get_access_strategy()
	
	if access_strategy is LokEncryptedAccessStrategy:
		access_strategy.password = LockerPlugin.get_setting_encrypted_strategy_password()

#endregion
