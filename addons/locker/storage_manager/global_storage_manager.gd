@tool
## This class is registered as an autoload when the Locker plugin is active.
## 
## It's this class that's responsible for keeping track of all the
## [StorageAccessor]s that need saving and loading.
extends LokStorageManager

const DEBUG_ICON_PATH: String = "res://addons/locker/assets/icon.svg"

var accessors: Array[LokStorageAccessor] = []:
	set = set_accessors,
	get = get_accessors

var access_strategy: LokAccessStrategy:
	set = set_access_strategy,
	get = get_access_strategy

#region Setters & Getters

func set_accessors(new_accessors: Array[LokStorageAccessor]) -> void:
	accessors = new_accessors

func get_accessors() -> Array[LokStorageAccessor]:
	return accessors

func add_accessor(accessor: LokStorageAccessor) -> bool:
	accessors.append(accessor)
	
	if not accessor.id_changed.is_connected(_on_accessor_id_changed):
		accessor.id_changed.connect(_on_accessor_id_changed)
	
	if not Engine.is_editor_hint():
		if get_debug_mode():
			verify_accessors()
	
	return true

func remove_accessor(accessor: LokStorageAccessor) -> bool:
	var accessor_index: int = accessors.find(accessor)
	
	if accessor_index == -1:
		return false
	
	accessors.remove_at(accessor_index)
	
	if accessor.id_changed.is_connected(_on_accessor_id_changed):
		accessor.id_changed.disconnect(_on_accessor_id_changed)
	
	return true

func get_accessor_by_id(
	id: String, version_number: String = ""
) -> LokStorageAccessor:
	for accessor: LokStorageAccessor in accessors:
		accessor.set_version_number(version_number)
		
		if accessor.get_id() == id:
			return accessor
	
	return null

func get_accessors_grouped_by_id() -> Dictionary:
	var grouped_accessors: Dictionary = {}
	
	for accessor: LokStorageAccessor in accessors:
		var accessor_id: String = accessor.get_id()
		
		if not grouped_accessors.has(accessor_id):
			grouped_accessors[accessor_id] = []
		
		grouped_accessors[accessor_id].append(accessor)
	
	return grouped_accessors

func get_repeated_accessors_grouped_by_id() -> Dictionary:
	var repeated_accessors: Dictionary = {}
	
	var accessor_groups: Dictionary = get_accessors_grouped_by_id()
	
	for accessor_id: String in accessor_groups.keys():
		if accessor_groups[accessor_id].size() <= 1:
			continue
		
		repeated_accessors[accessor_id] = accessor_groups[accessor_id]
	
	return repeated_accessors

func set_access_strategy(new_strategy: LokAccessStrategy) -> void:
	access_strategy = new_strategy

func get_access_strategy() -> LokAccessStrategy:
	return access_strategy

func select_access_strategy() -> void:
	if get_use_encryption():
		access_strategy = LokEncryptedAccessStrategy.new()
	else:
		access_strategy = LokJSONAccessStrategy.new()

func get_saves_directory() -> String:
	return LockerPlugin.get_saves_directory()

func get_save_files_prefix() -> String:
	return LockerPlugin.get_save_files_prefix()

func get_save_files_format() -> String:
	return LockerPlugin.get_save_files_format()

func get_save_versions() -> bool:
	return LockerPlugin.get_save_versions()

func get_use_encryption() -> bool:
	return LockerPlugin.get_use_encryption()

func get_encryption_password() -> String:
	return LockerPlugin.get_encryption_password()

func get_debug_mode() -> bool:
	return LockerPlugin.get_debug_mode()

func get_debug_warning_color() -> Color:
	return LockerPlugin.get_debug_warning_color()

func get_save_path(file_id: int) -> String:
	var result: String = ""
	
	result += get_saves_directory()
	result += get_save_files_prefix()
	result += str(file_id)
	result += get_save_files_format()
	
	return result

#endregion

func warn_repeated_accessors(repeated_accessors: Dictionary) -> void:
	var warning_color: Color = get_debug_warning_color()
	
	var warning: String = "[img]%s[/img] " % [ DEBUG_ICON_PATH ]
	warning += "[color=#%s]" % warning_color.to_html()
	warning += name
	warning += " detected repeated accessor ids, which may cause loss of data:"
	warning += "[/color]\n"
	
	for accessor_id: String in repeated_accessors.keys():
		warning += "- ID '%s':\n" % [ accessor_id ]
		
		for accessor: LokStorageAccessor in repeated_accessors[accessor_id]:
			var accessor_name: Variant
			
			if accessor.is_inside_tree():
				accessor_name = accessor.get_path()
			elif not accessor.name == "":
				accessor_name = accessor.name
			else:
				accessor_name = str(accessor)
			
			warning += " - %s;\n" % [ accessor_name ]
	
	print_rich(warning)

func verify_accessors() -> void:
	var repeated_accessors: Dictionary = get_repeated_accessors_grouped_by_id()
	
	if repeated_accessors.is_empty():
		return
	
	warn_repeated_accessors(repeated_accessors)

func gather_data(
	accessor_ids: Array[String] = [],
	version_number: String = "1.0.0"
) -> Dictionary:
	var data: Dictionary = {}
	
	for accessor: LokStorageAccessor in accessors:
		accessor.set_version_number(version_number)
		
		var accessor_id: String = accessor.get_id()
		var accessor_version: String = accessor.get_version_number()
		var accessor_data: Dictionary = accessor.retrieve_data()
		
		if accessor_id == "":
			continue
		if accessor_data.is_empty():
			continue
		if (
			not accessor_ids.is_empty() and
			not accessor_id in accessor_ids
		):
			continue
		
		if get_save_versions() and accessor_version != "":
			accessor_data["version"] = accessor_version
		
		data[accessor_id] = accessor_data
	
	return data

func distribute_data(
	data: Dictionary,
	accessor_ids: Array[String] = []
) -> void:
	for accessor_id: String in data.keys():
		if (
			not accessor_ids.is_empty() and
			not accessor_id in accessor_ids
		):
			continue
		
		var accessor_data: Dictionary = data[accessor_id]
		var accessor_version: String = accessor_data.get("version", "")
		
		var accessor: LokStorageAccessor = get_accessor_by_id(
			accessor_id, accessor_version
		)
		
		if accessor == null:
			continue
		
		accessor.consume_data(accessor_data)

## Another optional parameter this method accept is the [param accessor_ids],
## which is a list that enumerates the ids of the [LokStorageAccessor]
## 
## To better understand these parameters, read about that method.
func save_data(
	file_id: int,
	version_number: String = "1.0.0",
	accessor_ids: Array[String] = [],
	replace: bool = false
) -> Dictionary:
	var saves_directory: String = get_saves_directory()
	
	if LokAccessStrategy.check_and_create_directory(saves_directory) == false:
		return {}
	
	var data: Dictionary = gather_data(accessor_ids, version_number)
	
	return access_strategy.save_data(file_id, data, replace)

func load_data(
	file_id: int,
	accessor_ids: Array[String] = [],
	partition_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	var saves_directory: String = get_saves_directory()
	
	if LokAccessStrategy.check_directory(saves_directory) == false:
		return {}
	
	var data: Dictionary = access_strategy.load_data(file_id)
	
	distribute_data(data, accessor_ids)
	
	return data

func _init() -> void:
	if not Engine.is_editor_hint():
		select_access_strategy()

func _on_accessor_id_changed(old_id: String, new_id: String) -> void:
	if Engine.is_editor_hint():
		return
	
	verify_accessors()
