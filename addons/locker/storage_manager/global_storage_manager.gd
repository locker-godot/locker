
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

## The [member accessors] property is an [Array] responsible for storing all the
## [LokStorageAccessor]s that are currently in the scene tree. [br]
## This [Array] shouldn't be manipulated directly, given that the
## [LokStorageAccessor]s are automatically added and removed from it
## on entering and exiting the tree.
var accessors: Array[LokStorageAccessor] = []:
	set = set_accessors,
	get = get_accessors

## The [member access_strategy] property stores a [LokAccessStrategy] that
## dictates how the data is saved and loaded. [br]
## This property shouldn't be altered by other classes, since it's a
## needed object for performing data manipulation.
#var access_strategy: LokAccessStrategy:
	#set = set_access_strategy,
	#get = get_access_strategy

var access_executor: LokAccessExecutor:
	set = set_access_executor,
	get = get_access_executor

var access_executor_connections: Array[Dictionary] = [
	{ "name": &"operation_started", "callable": _on_executor_operation_started },
	{ "name": &"saving_started", "callable": _on_executor_saving_started },
	{ "name": &"loading_started", "callable": _on_executor_loading_started },
	{ "name": &"reading_started", "callable": _on_executor_reading_started },
	{ "name": &"removing_started", "callable": _on_executor_removing_started },
	{ "name": &"operation_finished", "callable": _on_executor_operation_finished },
	{ "name": &"saving_finished", "callable": _on_executor_saving_finished },
	{ "name": &"loading_finished", "callable": _on_executor_loading_finished },
	{ "name": &"reading_finished", "callable": _on_executor_reading_finished },
	{ "name": &"removing_finished", "callable": _on_executor_removing_finished },
]

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

func set_accessors(new_accessors: Array[LokStorageAccessor]) -> void:
	accessors = new_accessors

func get_accessors() -> Array[LokStorageAccessor]:
	return accessors

func set_access_executor(new_executor: LokAccessExecutor) -> void:
	var old_executor: LokAccessExecutor = access_executor
	
	access_executor = new_executor
	
	if old_executor == new_executor:
		return
	
	LokUtil.check_and_disconnect_signals(
		old_executor,
		access_executor_connections
	)
	LokUtil.check_and_connect_signals(
		new_executor,
		access_executor_connections
	)

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

## The [method add_accessor] method is responsible for adding a new
## [LokStorageAccessor] to the [member accessors] list, so that
## it can have its data saved and loaded together with the other ones. [br]
## This method is called automatically by [LokStorageAccessor]s when they
## enter the scene tree, so there's no need to use it yourself.
func add_accessor(accessor: LokStorageAccessor) -> bool:
	accessors.append(accessor)
	
	return true

## The [method remove_accessor] method is responsible for removing a
## [LokStorageAccessor] from the [member accessors] list, so that
## it doesn't have its data saved and loaded anymore. [br]
## This makes sense when such [LokStorageAccessor] exits from the tree,
## and hence doesn't have the ability to do anything with the data. [br]
## This method is called automatically by [LokStorageAccessor]s when they
## exit the scene tree, so there's no need to use it yourself.
func remove_accessor(accessor: LokStorageAccessor) -> bool:
	var accessor_index: int = accessors.find(accessor)
	
	if accessor_index == -1:
		return false
	
	accessors.remove_at(accessor_index)
	
	return true

func get_file_path(file_id: String) -> String:
	var file_path: String = saves_directory.path_join(save_files_prefix)
	
	if file_id != "":
		file_path += file_id
	
	return file_path

## The [method get_accessors_by_id] method looks through all currently
## registered [LokStorageAccessor]s and returns the ones that match the
## [param id] passed.
func get_accessors_by_id(id: String) -> Array[LokStorageAccessor]:
	var result: Array[LokStorageAccessor] = []
	
	for accessor: LokStorageAccessor in accessors:
		if accessor.id == id:
			result.append(accessor)
	
	return result

## The [method get_accessor_by_id] method looks through all currently
## registered [LokStorageAccessor]s and returns the first one that matches the
## [param id] passed.
func get_accessor_by_id(id: String) -> LokStorageAccessor:
	for accessor: LokStorageAccessor in accessors:
		if accessor.id == id:
			return accessor
	
	return null

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
	accessor_ids: Array[String] = [], version_number: String = ""
) -> Dictionary:
	var data: Dictionary = {}
	
	for accessor: LokStorageAccessor in accessors:
		if accessor.id == "":
			continue
		if not LokUtil.filter_value(accessor_ids, accessor.id):
			continue
		
		var accessor_data: Dictionary = collect_data(accessor, version_number)
		
		if accessor_data.is_empty():
			continue
		
		if not data.has(accessor.partition):
			data[accessor.partition] = {}
		
		data[accessor.partition][accessor.id] = accessor_data
	
	return data

## The [method distribute_data] method is the central point where the data
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
func distribute_data(
	data: Dictionary, accessor_ids: Array[String] = []
) -> void:
	for accessor: LokStorageAccessor in accessors:
		if not LokUtil.filter_value(accessor_ids, accessor.id):
			continue
		
		var accessor_data: Dictionary = data.get(accessor.id, {})
		
		if accessor_data.is_empty():
			continue
		
		var accessor_version: String = accessor_data.get("version", "")
		
		accessor.set_version_number(accessor_version)
		accessor.consume_data(accessor_data.duplicate(true))

## Another optional parameter this method accept is the [param accessor_ids],
## which is a list that enumerates the ids of the [LokStorageAccessor]
## 
## To better understand these parameters, read about that method.
func save_data(
	file_id: String,
	version_number: String = "",
	accessor_ids: Array[String] = [],
	replace: bool = false
) -> Dictionary:
	var file_path: String = get_file_path(file_id)
	var file_format: String = save_files_format
	
	var data: Dictionary = gather_data(accessor_ids, version_number)
	
	print("%s: Started saving file %s;" % [
		Time.get_ticks_msec(),
		file_id
	])
	
	var saving_result: Dictionary = await access_executor.request_saving(
		file_path, file_format, data, replace
	)
	
	print("%s: Finished saving file %s;" % [
		Time.get_ticks_msec(),
		file_id
	])
	
	return saving_result

func load_data(
	file_id: String,
	accessor_ids: Array[String] = [],
	partition_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	var file_path: String = get_file_path(file_id)
	var file_format: String = save_files_format
	
	var loaded_data: Dictionary = await access_executor.load_data(
		file_path,
		file_format,
		partition_ids,
		accessor_ids,
		version_numbers
	)
	
	distribute_data(loaded_data, accessor_ids)
	
	return loaded_data

func read_data(
	file_id: String,
	accessor_ids: Array[String] = [],
	partition_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	var file_path: String = get_file_path(file_id)
	var file_format: String = save_files_format
	
	var reading_result: Dictionary = await access_executor.request_reading(
		file_path, file_format, partition_ids, accessor_ids, version_numbers
	)
	
	return reading_result

func remove_data(
	file_id: String,
	accessor_ids: Array[String] = [],
	partition_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	var file_path: String = get_file_path(file_id)
	var file_format: String = save_files_format
	
	var removing_result: Dictionary = await access_executor.request_removing(
		file_path, file_format, partition_ids, accessor_ids, version_numbers
	)
	
	return removing_result

# Initializes values according to settings
func _init() -> void:
	access_executor = LokAccessExecutor.new()
	set_access_strategy(LockerPlugin.get_setting_access_strategy_parsed())
	
	var access_strategy: LokAccessStrategy = get_access_strategy()
	
	if access_strategy is LokEncryptedAccessStrategy:
		access_strategy.password = LockerPlugin.get_setting_encrypted_strategy_password()

func _on_executor_operation_started(operation_name: StringName) -> void:
	operation_started.emit(operation_name)

func _on_executor_saving_started() -> void:
	saving_started.emit()

func _on_executor_loading_started() -> void:
	loading_started.emit()

func _on_executor_reading_started() -> void:
	reading_started.emit()

func _on_executor_removing_started() -> void:
	removing_started.emit()

func _on_executor_operation_finished(result: Dictionary, operation: StringName) -> void:
	operation_finished.emit(result, operation)

func _on_executor_saving_finished(result: Dictionary) -> void:
	saving_finished.emit(result)

func _on_executor_loading_finished(result: Dictionary) -> void:
	loading_finished.emit(result)

func _on_executor_reading_finished(result: Dictionary) -> void:
	reading_finished.emit(result)

func _on_executor_removing_finished(result: Dictionary) -> void:
	removing_finished.emit(result)

#endregion
