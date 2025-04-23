## The [LokGlobalStorageManager] class is the main manager of the
## manipulation processes.
## 
## This class is registered as an autoload when the [LockerPlugin] is active,
## so that it can do its tasks. [br]
## It's this class that's responsible for keeping track of all the
## [LokStorageAccessor]s in the current scene tree, so that they can
## easily save and load their data. [br]
## [br]
## [b]Version[/b]: 1.0.0 [br]
## [b]Author[/b]: Daniel Sousa ([url]github.com/nadjiel[/url])
extends LokStorageManager

#region Properties

## The [member saves_directory] property stores a [String] pointing to the
## directory where the save files should be accessed. [br]
## By default, this property initializes with the value from the
## [code]"addons/locker/saves_directory"[/code] setting in the [ProjectSettings]
## (which is created by the [LockerPlugin] using the [LokSettingsManager]).
var saves_directory: String = LokSettingsManager.get_setting_saves_directory():
	set = set_saves_directory,
	get = get_saves_directory

## The [member save_files_prefix] property stores a [String] that tells what's
## the prefix that should be used in the save files when creating them. [br]
## By default, this property initializes with the value from the
## [code]"addons/locker/save_files_prefix"[/code] setting in the
## [ProjectSettings] (which is created by the [LockerPlugin]
## using the [LokSettingsManager]).
var save_files_prefix: String = LokSettingsManager.get_setting_save_files_prefix():
	set = set_save_files_prefix,
	get = get_save_files_prefix

## The [member save_files_format] property stores a [String] that tells what's
## the format that should be used in the save files when accessing them. [br]
## By default, this property initializes with the value from the
## [code]"addons/locker/save_files_format"[/code] setting in the
## [ProjectSettings] (which is created by the [LockerPlugin]
## using the [LokSettingsManager]).
var save_files_format: String = LokSettingsManager.get_setting_save_files_format():
	set = set_save_files_format,
	get = get_save_files_format

## The [member save_versions] property stores a [code]bool[/code] that tells if
## the save files should store data about the version used when saving them,
## which is useful for easily versioning the saves using
## [LokStorageAccessorVersion]s. [br]
## By default, this property initializes with the value from the
## [code]"addons/locker/save_versions"[/code] setting in the
## [ProjectSettings] (which is created by the [LockerPlugin]
## using the [LokSettingsManager]).
var save_versions: bool = LokSettingsManager.get_setting_save_versions():
	set = set_save_versions,
	get = get_save_versions

## The [member _access_executor] property stores a [LokAccessExecutor] that
## is responsible for separating the save files' operations in a separate
## [Thread] so that they can be used asynchronously.
var _access_executor: LokAccessExecutor = LokAccessExecutor.new():
	set = _set_access_executor,
	get = _get_access_executor

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

func _set_access_executor(new_executor: LokAccessExecutor) -> void:
	_access_executor = new_executor

func _get_access_executor() -> LokAccessExecutor:
	return _access_executor

## The [method set_access_strategy] method allows quickly setting the
## [LokAccessStrategy] of the [member _access_executor], if it is not
## [code]null[/code].
func set_access_strategy(new_strategy: LokAccessStrategy) -> void:
	if _access_executor == null:
		_push_error_no_executor()
		return
	
	_access_executor.access_strategy = new_strategy

## The [method get_access_strategy] method allows quickly getting the
## [LokAccessStrategy] of the [member _access_executor].
func get_access_strategy() -> LokAccessStrategy:
	if _access_executor == null:
		_push_error_no_executor()
		return
	
	return _access_executor.access_strategy

#endregion

#region Methods

# Initializes values according to ProjectSettings
func _init() -> void:
	set_access_strategy(LokSettingsManager.get_setting_access_strategy_parsed())
	
	var access_strategy: LokAccessStrategy = get_access_strategy()
	
	if access_strategy != null:
		access_strategy.set(
			&"password",
			LokSettingsManager.get_setting_encrypted_strategy_password()
		)

# Finalizes AccessExecutor's Thread
func _exit_tree() -> void:
	_access_executor.finish_execution()

## The [method collect_data] method is used to get and organize the data
## from an [param accessor]. [br]
## Optionally, a [param version_number] can be passed to dictate from which
## version of the [param accessor] the data should be got. If left undefined,
## this parameter defaults to the latest available. [br]
## At the end, this method returns a [Dictionary] with all the data obtained
## from the [param accessor]. [br]
## That [Dictionary] is guaranteed to have a [code]"version"[/code] key
## saying what version was used to get that data [b]IF[/b] the
## [member save_versions] property is [code]true[/code].
func collect_data(
	accessor: LokStorageAccessor,
	version_number: String = ""
) -> Dictionary:
	if accessor == null:
		return {}
	
	accessor.set_version_number(version_number)
	
	var accessor_version: String = accessor.get_version_number()
	var accessor_data: Dictionary = await accessor.retrieve_data()
	
	if accessor_data.is_empty():
		return {}
	
	if save_versions:
		if accessor_version != "":
			accessor_data["version"] = accessor_version
	
	return accessor_data

## The [method gather_data] method is the central point where the data
## from all [member LokAccessorGroup.accessors] is collected using the
## [method collect_data] method. [br]
## If the [param included_accessors] parameter is not empty, this method only
## gathers data from the [LokStorageAccessor]s that are present in that [Array].
## [br]
## The [param version_number] parameter is used as the version of the
## [LokStorageAccessor]s from which the data is collected. If left undefined,
## this parameter defaults to an empty [String], which converts
## to their latest version. [br]
## In the case there's [member LokStorageAccessor.id] conflicts in the
## same [member LokStorageAccessor.partition],
## the id of the last accessor encountered is prioritized. It is often
## unknown, though, which accessor is the last one, so it's always better
## to avoid repeated ids. [br]
## At the end, this method returns a [Dictionary] with all the data obtained
## from the [LokStorageAccessor]s. It's structure is the following:
## [codeblock]
## {
##   "partition_1_id": {
##     "accessor_1_id": {
##       "version": <String> (optional),
##       ...
##     },
##     "accessor_n_id": { ... }
##   },
##   "partition_n_id": { ... }
## }
## [/codeblock]
func gather_data(
	included_accessors: Array[LokStorageAccessor] = [],
	version_number: String = ""
) -> Dictionary:
	var data: Dictionary = {}
	
	for accessor: LokStorageAccessor in accessors:
		if accessor.id == "":
			continue
		if not LokUtil.filter_value(included_accessors, accessor):
			continue
		
		var accessor_data: Dictionary = await collect_data(accessor, version_number)
		
		if accessor_data.is_empty():
			continue
		
		if not data.has(accessor.partition):
			data[accessor.partition] = {}
		
		data[accessor.partition][accessor.id] = accessor_data
	
	return data

## The [method distribute_result] method is the central point where the result
## of loadings is distributed to all [member LokAccessorGroup.accessors]. [br]
## If the [param included_accessors] parameter is not empty, this method only
## distributes data to the [LokStorageAccessor]s present in that [Array]. [br]
## The version of the [LokStorageAccessor]s that receives the data is
## determined by the [code]"version"[/code] key of its data in the
## [code]data[/code] subdictionary of the [param result] [Dictionary]. [br]
## If there's no such entry, the version that receives the
## data is the latest available. [br]
## If there are more than one [LokStorageAccessor]s with the same id found,
## the data with that id is distributed to all of these [LokStorageAccessor]s.
## [br]
## The [param result] [Dictionary] that this method expects should match the
## following pattern:
## [codeblock]
## {
##   "result": <@GlobalScope.Error>,
##   "data": {
##     "accessor_1_id": {
##       "version": <String>,
##       ...
##     },
##     "accessor_n_id": { ... }
##   }
## }
## [/codeblock]
func distribute_result(
	result: Dictionary,
	included_accessors: Array[LokStorageAccessor] = []
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
		await accessor.consume_data(accessor_result.duplicate(true))

## The [method get_saved_files_ids] method returns an [Array] of [String]s
## with the ids of all files saved in the [member saves_directory].
func get_saved_files_ids() -> Array[String]:
	var result: Dictionary = await _access_executor.request_get_file_ids(
		saves_directory
	)
	
	return result.get("data", [] as Array[String])

## The [method save_data] method is the main method for saving data
## using the [LockerPlugin]. [br]
## To read more about the parameters and return of this method, see
## the [method LokStorageManager.save_data] description. [br]
## Note that if a [param file_id] is passed but is an empty [String], the
## [member LokStorageManager.current_file] is prioritized over the empty one.
func save_data(
	file_id: String = current_file,
	version_number: String = current_version,
	included_accessors: Array[LokStorageAccessor] = [],
	replace: bool = false
) -> Dictionary:
	if file_id == "" and current_file != "":
		file_id = current_file
	
	var file_path: String = _get_file_path(file_id)
	var file_format: String = save_files_format
	
	saving_started.emit()
	
	var data: Dictionary = await gather_data(included_accessors, version_number)
	
	var result: Dictionary = await _access_executor.request_saving(
		file_path, file_format, data, replace
	)
	
	saving_finished.emit(result)
	
	return result

## The [method load_data] method is the main method for loading data
## using the [LockerPlugin]. [br]
## To read more about the parameters and return of this method, see
## the [method LokStorageManager.load_data] description. [br]
## Note that if a [param file_id] is passed but is an empty [String], the
## [member LokStorageManager.current_file] is prioritized over the empty one.
func load_data(
	file_id: String = current_file,
	included_accessors: Array[LokStorageAccessor] = [],
	partition_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	if file_id == "" and current_file != "":
		file_id = current_file
	
	var file_path: String = _get_file_path(file_id)
	var file_format: String = save_files_format
	
	var accessor_ids: Array[String] = _get_accessor_ids(included_accessors)
	
	loading_started.emit()
	
	var result: Dictionary = await _access_executor.request_loading(
		file_path,
		file_format,
		partition_ids,
		accessor_ids,
		version_numbers
	)
	
	await distribute_result(result, included_accessors)
	
	loading_finished.emit(result)
	
	return result

## The [method read_data] method is the main method for reading data
## using the [LockerPlugin]. [br]
## To read more about the parameters and return of this method, see
## the [method LokStorageManager.read_data] description. [br]
## Note that if a [param file_id] is passed but is an empty [String], the
## [member LokStorageManager.current_file] is prioritized over the empty one.
func read_data(
	file_id: String = current_file,
	included_accessors: Array[LokStorageAccessor] = [],
	partition_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	if file_id == "" and current_file != "":
		file_id = current_file
	
	var file_path: String = _get_file_path(file_id)
	var file_format: String = save_files_format
	
	var accessor_ids: Array[String] = _get_accessor_ids(included_accessors)
	
	reading_started.emit()
	
	var result: Dictionary = await _access_executor.request_loading(
		file_path, file_format, partition_ids, accessor_ids, version_numbers
	)
	
	reading_finished.emit(result)
	
	return result

## The [method remove_data] method is the main method for removing data
## using the [LockerPlugin]. [br]
## To read more about the parameters and return of this method, see
## the [method LokStorageManager.remove_data] description. [br]
## Note that if a [param file_id] is passed but is an empty [String], the
## [member LokStorageManager.current_file] is prioritized over the empty one.
func remove_data(
	file_id: String = current_file,
	included_accessors: Array[LokStorageAccessor] = [],
	partition_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	if file_id == "" and current_file != "":
		file_id = current_file
	
	var file_path: String = _get_file_path(file_id)
	var file_format: String = save_files_format
	
	var accessor_ids: Array[String] = _get_accessor_ids(included_accessors)
	
	removing_started.emit()
	
	var result: Dictionary = await _access_executor.request_removing(
		file_path, file_format, partition_ids, accessor_ids, version_numbers
	)
	
	removing_finished.emit(result)
	
	return result

## The [method _get_accessor_ids] method returns an [Array] of [String]s
## representing the ids from the [LokStorageAccessor]s received in the
## [param from_accessors] parameter.
func _get_accessor_ids(
	from_accessors: Array[LokStorageAccessor]
) -> Array[String]:
	var accessor_ids: Array[String] = []
	
	for accessor: LokStorageAccessor in from_accessors:
		accessor_ids.append(accessor.id)
	
	return accessor_ids

## The [method _get_file_name] method returns a [String] with the name of
## a file that has [param file_id] as its id. [br]
## If [param file_id] is an empty [String], the file name defaults to the
## [member save_files_prefix]. [br]
## If that property is an empty [String], then the file name equals to the
## [param file_id]. [br]
## If both are not empty [String], then the file name equals to a nicely
## concatenated [code]<save_files_prefix>_<file_id>[/code].
func _get_file_name(file_id: String) -> String:
	if file_id == "":
		return save_files_prefix
	if save_files_prefix == "":
		return file_id
	
	return "%s_%s" % [ save_files_prefix, file_id ]

## The [method _get_file_path] method returns a [String] with the path of
## a file that has [param file_id] as its id. [br]
## If both the [member save_files_prefix] and the [param file_id] are empty
## [String]s, then the file path will return an empty [String] to avoid
## that the [member saves_directory] is used as a file.
func _get_file_path(file_id: String) -> String:
	var file_name: String = _get_file_name(file_id)
	
	if file_name == "":
		return ""
	
	var file_path: String = saves_directory.path_join(file_name)
	
	return file_path

#endregion

#region Debug Methods

## The [method _push_error_no_executor] method pushes an error saying
## that no [LokAccessExecutor] was found in this class.
func _push_error_no_executor() -> void:
	push_error("%s: No AccessExecutor found in %s" % [
		error_string(Error.ERR_UNCONFIGURED),
		_get_readable_name()
	])

#endregion
