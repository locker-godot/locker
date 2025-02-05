@tool
## This class is registered as an autoload when the Locker plugin is active.
## 
## It's this class that's responsible for keeping track of all the
## [StorageAccessor]s that need saving and loading.
extends LokStorageManager

const DEBUG_ICON_PATH: String = "res://addons/locker/assets/icon.svg"

var accessors: Array[LokStorageAccessor] = []

var access_strategy: LokAccessStrategy

#region Setters & Getters

func add_accessor(accessor: LokStorageAccessor) -> bool:
	accessors.append(accessor)
	
	if not accessor.id_changed.is_connected(_on_accessor_id_changed):
		accessor.id_changed.connect(_on_accessor_id_changed)
	
	if not Engine.is_editor_hint():
		if LockerPlugin.get_debug_mode():
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

func select_access_strategy() -> void:
	if LockerPlugin.get_use_encryption():
		access_strategy = LokEncryptedAccessStrategy.new()
	else:
		access_strategy = LokJSONAccessStrategy.new()

#endregion

func warn_repeated_accessors(repeated_accessors: Dictionary) -> void:
	var warning_color: Color = LockerPlugin.get_debug_warning_color()
	
	var warning: String = "[img]%s[/img] " % [ DEBUG_ICON_PATH ]
	warning += "[color=#%s]" % warning_color.to_html()
	warning += name
	warning += " detected repeated accessor ids, which may cause loss of data:"
	warning += "[/color]\n"
	
	for accessor_id: String in repeated_accessors.keys():
		warning += "- ID '%s':\n" % [ accessor_id ]
		
		for accessor: LokStorageAccessor in repeated_accessors[accessor_id]:
			warning += " - %s;\n" % [ accessor.get_path() ]
	
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
		
		if LockerPlugin.get_save_versions():
			accessor_data["version"] = accessor_version
		
		data[accessor_id] = accessor_data
	
	return data

func distribute_data(
	data: Dictionary,
	accessor_ids: Array[String] = [],
	version_number: String = "1.0.0"
) -> void:
	for accessor: LokStorageAccessor in accessors:
		accessor.set_version_number(version_number)
		
		var accessor_id: String = accessor.get_id()
		
		if accessor_id == "":
			continue
		if (
			not accessor_ids.is_empty() and
			not accessor_id in accessor_ids
		):
			continue
		
		accessor.consume_data(data.get(accessor_id, {}))

func save_data(
	file_id: int,
	version_number: String = "1.0.0",
	accessor_ids: Array[String] = [],
	remove_version: Callable = func(number: String) -> bool: return false
) -> Dictionary:
	var saves_directory: String = LockerPlugin.get_saves_directory()
	
	if not DirAccess.dir_exists_absolute(saves_directory):
		var err: Error = DirAccess.make_dir_recursive_absolute(saves_directory)
		
		if err != OK:
			push_error("Unable to create saves directory: '%s'" % [
				saves_directory
			])
			
			return {}
	
	var data: Dictionary = gather_data(accessor_ids, version_number)
	
	return access_strategy.save_data(file_id, data, version_number)

func load_data(
	file_id: int,
	accessor_ids: Array[String] = []
) -> Dictionary:
	var saves_directory: String = LockerPlugin.get_saves_directory()
	
	if not DirAccess.dir_exists_absolute(saves_directory):
		push_error("Data not found in directory: '%s'" % [
			saves_directory
		])
		
		return {}
	
	var data: Dictionary = access_strategy.load_data(file_id)
	var version_number: String = data.get("version", "")
	
	if version_number == "":
		distribute_data(data, accessor_ids)
	else:
		distribute_data(data, accessor_ids, version_number)
	
	return data

func _init() -> void:
	if not Engine.is_editor_hint():
		select_access_strategy()

func _on_accessor_id_changed(old_id: String, new_id: String) -> void:
	if Engine.is_editor_hint():
		return
	
	verify_accessors()
