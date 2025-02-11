@tool
## The [LokGlobalStorageManager] class serves as the manager of the data
## saving and loading process.
## 
## This class is registered as an autoload when the [LockerPlugin] is active,
## so that it can do its tasks. [br]
## It's this class that's responsible for keeping track of all the
## [LokStorageAccessor]s that need saving and loading.
extends LokStorageManager

## The [const DEBUG_ICON_PATH] const is a [String] that points to the path of
## an icon used for debugging.
const DEBUG_ICON_PATH: String = "res://addons/locker/assets/icon.svg"

#region Properties

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
var access_strategy: LokAccessStrategy:
	set = set_access_strategy,
	get = get_access_strategy

#endregion

#region Setters & Getters

func set_accessors(new_accessors: Array[LokStorageAccessor]) -> void:
	accessors = new_accessors

func get_accessors() -> Array[LokStorageAccessor]:
	return accessors

func set_access_strategy(new_strategy: LokAccessStrategy) -> void:
	access_strategy = new_strategy

func get_access_strategy() -> LokAccessStrategy:
	return access_strategy

#endregion

#region Configuration Getters

func get_config_saves_directory() -> String:
	return LockerPlugin.get_saves_directory()

func get_config_save_files_prefix() -> String:
	return LockerPlugin.get_save_files_prefix()

func get_config_save_files_format() -> String:
	return LockerPlugin.get_save_files_format()

func get_config_save_versions() -> bool:
	return LockerPlugin.get_save_versions()

func get_config_use_encryption() -> bool:
	return LockerPlugin.get_use_encryption()

func get_config_encryption_password() -> String:
	return LockerPlugin.get_encryption_password()

func get_save_file_name(file_id: String) -> String:
	var file_prefix: String = get_config_save_files_prefix()
	
	if file_prefix == "":
		return file_id
	
	return "%s_%s" % [ file_prefix, file_id ]

func get_save_file_path(file_id: String) -> String:
	var file_directory: String = get_config_saves_directory()
	var file_name: String = get_save_file_name(file_id)
	
	return "%s/%s" % [ file_directory, file_name ]

#
func get_config_debug_mode() -> bool:
	return LockerPlugin.get_debug_mode()

#
func get_config_debug_warning_color() -> Color:
	return LockerPlugin.get_debug_warning_color()

#
func get_config_save_path(file_id: int) -> String:
	var result: String = ""
	
	result += get_config_saves_directory()
	result += get_config_save_files_prefix()
	result += str(file_id)
	result += get_config_save_files_format()
	
	return result

#endregion

#region Debug Methods

## The [method push_warning_repeated_accessors] method prints to the
## output log a warning saying that [LokStorageAccessor]s with repeated
## ids were found in a [param version_number]. [br]
## If the [param version_number] passed to this method is an empty [String],
## nothing is done, since it doesn't matter if [LokStorageAccessor]s with
## different [member [LokStorageAccessorVersion.number]s
## have repeated [member [LokStorageAccessorVersion.id]s.
func push_warning_repeated_accessors(
	repeated_accessors: Dictionary,
	version_number: String
) -> void:
	if version_number == "":
		return
	
	var warning_color: Color = get_config_debug_warning_color()
	
	var warning: String = "[img]%s[/img] " % DEBUG_ICON_PATH
	warning += "[color=#%s]" % warning_color.to_html()
	warning += name
	warning += " detected repeated accessor ids in version %s" % version_number
	warning += ", which may cause loss of data:"
	warning += "[/color]\n"
	
	for accessor_id: String in repeated_accessors.keys():
		warning += "- ID '%s':\n" % accessor_id
		
		for accessor: LokStorageAccessor in repeated_accessors[accessor_id]:
			var accessor_name: String = accessor.get_readable_name()
			
			warning += " - %s;\n" % accessor_name
	
	print_rich(warning)

## The [method verify_accessors] method looks through all current
## [member accessors], setting their version to the [param version_number]
## and checking if they have repeated ids. If they do, this method
## prints a warning using the [method push_warning_repeated_accessors]
## method. [br]
## If the [param version_number] passed to this method is an empty [String],
## nothing is done, since it doesn't matter if [LokStorageAccessor]s with
## different [member [LokStorageAccessorVersion.number]s
## have repeated [member [LokStorageAccessorVersion.id]s.
func verify_accessors(version_number: String) -> void:
	if version_number == "":
		return
	
	var repeated_accessors: Dictionary = get_repeated_accessors_grouped_by_id(
		version_number
	)
	
	if repeated_accessors.is_empty():
		return
	
	push_warning_repeated_accessors(repeated_accessors, version_number)

#endregion

#region Methods

## The [method add_accessor] method is responsible for adding a new
## [LokStorageAccessor] to the [member accessors] list, so that
## it can have its data saved and loaded together with the other ones. [br]
## This method is called automatically by [LokStorageAccessor]s when they
## enter the scene tree, so there's no need to use it yourself.
func add_accessor(accessor: LokStorageAccessor) -> bool:
	accessors.append(accessor)
	
	#if not accessor.id_changed.is_connected(_on_accessor_id_changed):
		#accessor.id_changed.connect(_on_accessor_id_changed)
	#
	#if not Engine.is_editor_hint():
		#if get_config_debug_mode():
			#verify_accessors()
	
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
	
	#if accessor.id_changed.is_connected(_on_accessor_id_changed):
		#accessor.id_changed.disconnect(_on_accessor_id_changed)
	
	return true

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

## The [method get_accessors_grouped_by_id] method looks through all currently
## registered [LokStorageAccessor]s and returns a [Dictionary] that groups
## together the [LokStorageAccessor]s with same
## [member LokStorageAccessorVersion.id]. [br]
## Before looking the ids, the [LokStorageAccessor]'s version is set
## to the [param version_number] passed in the parameter, so that the
## comparison takes that version specifically into account. [br]
## If the version number is an empty [String], as default, it means the
## latest version of the [LokStorageAccessor] is used in the comparison. [br]
## The format of the [Dictionary] returned is as follows:[br]
## [code]{
##   <id_1>: String: [
##     <accessor_1>: LokStorageAccessor,
##     <accessor_n>: LokStorageAccessor
##   ],
##   <id_n>: String: [
##     <accessor_1>: LokStorageAccessor,
##     <accessor_n>: LokStorageAccessor
##   ]
## }[/code]
func get_accessors_grouped_by_id(version_number: String = "") -> Dictionary:
	var result: Dictionary = {}
	
	for accessor: LokStorageAccessor in accessors:
		accessor.set_version_number(version_number)
		var accessor_id: String = accessor.get_id()
		
		if not result.has(accessor_id):
			result[accessor_id] = []
		
		result[accessor_id].append(accessor)
	
	return result

## The [method get_repeated_accessors_grouped_by_id] method
## does the same as the [method get_accessors_grouped_by_id] method,
## with the difference that this method filters out the groups that
## have one or less [LokStorageAccessor]s. [br]
## In other words, this method returns the [LokStorageAccessor]s that
## have repeated ids grouped by id.
## The format of the [Dictionary] returned is as follows:[br]
## [code]{
##   <id_1>: String: [
##     <accessor_1>: LokStorageAccessor,
##     <accessor_n>: LokStorageAccessor
##   ],
##   <id_n>: String: [
##     <accessor_1>: LokStorageAccessor,
##     <accessor_n>: LokStorageAccessor
##   ]
## }[/code]
func get_repeated_accessors_grouped_by_id(version_number: String = "") -> Dictionary:
	var result: Dictionary = {}
	
	var accessor_groups: Dictionary = get_accessors_grouped_by_id(
		version_number
	)
	
	for accessor_id: String in accessor_groups.keys():
		if accessor_groups[accessor_id].size() <= 1:
			continue
		
		result[accessor_id] = accessor_groups[accessor_id]
	
	return result

## The [method select_access_strategy] method uses the
## [method get_config_use_encryption] method to
## select whether the [member access_strategy] should be the
## [LokEncryptedAccessStrategy] or the [LokJSONAccessStrategy].
func select_access_strategy() -> void:
	if get_config_use_encryption():
		access_strategy = LokEncryptedAccessStrategy.new()
	else:
		access_strategy = LokJSONAccessStrategy.new()

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
	
	if get_config_save_versions():
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
		if not accessor_ids.is_empty() and not accessor.id in accessor_ids:
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
	for accessor_id: String in data.keys():
		if not accessor_ids.is_empty() and not accessor_id in accessor_ids:
			continue
		
		var accessor_data: Dictionary = data[accessor_id]
		var accessor_version: String = accessor_data.get("version", "")
		
		var accessors_found: Array[LokStorageAccessor] = get_accessors_by_id(
			accessor_id
		)
		
		for accessor: LokStorageAccessor in accessors_found:
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
	var file_path: String = get_save_file_path(file_id)
	var file_format: String = get_config_save_files_format()
	
	var data: Dictionary = gather_data(accessor_ids, version_number)
	
	return access_strategy.save_data(file_path, file_format, data, replace)

func load_data(
	file_id: String,
	accessor_ids: Array[String] = [],
	partition_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	var data: Dictionary = read_data(
		file_id,
		accessor_ids,
		partition_ids,
		version_numbers
	)
	
	distribute_data(data, accessor_ids)
	
	return data

func read_data(
	file_id: String,
	accessor_ids: Array[String] = [],
	partition_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	var file_path: String = get_save_file_path(file_id)
	var file_format: String = get_config_save_files_format()
	
	var data: Dictionary = access_strategy.load_data(
		file_path, file_format, partition_ids
	)
	
	if accessor_ids.is_empty() and version_numbers.is_empty():
		return data
	
	var filtered_data: Dictionary = {}
	
	for accessor_id: String in data:
		var accessor_data: Dictionary = data[accessor_id]
		var accessor_version: String = accessor_data.get("version", "")
		
		if not accessor_ids.is_empty() and not accessor_id in accessor_ids:
			continue
		if(
			not version_numbers.is_empty() and
			not accessor_version in version_numbers
		):
			continue
		
		filtered_data[accessor_id] = accessor_data
	
	return filtered_data

func remove_data(
	file_id: String,
	accessor_ids: Array[String] = [],
	partition_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	var file_path: String = get_save_file_path(file_id)
	var file_format: String = get_config_save_files_format()
	
	return access_strategy.remove_data(
		file_path, file_format, partition_ids, accessor_ids, version_numbers
	)

func _init() -> void:
	if not Engine.is_editor_hint():
		select_access_strategy()

func _on_accessor_id_changed(old_id: String, new_id: String) -> void:
	if Engine.is_editor_hint():
		return
	
	#verify_accessors()

#endregion
