@tool
## This class is registered as an autoload when the Locker plugin is active.
## 
## It's this class that's responsible for keeping track of all the
## [StorageAccessor]s that need saving and loading.
extends LokStorageManager

var accessors: Array[LokStorageAccessor] = []

var access_strategy: LokAccessStrategy = LokJSONAccessStrategy.new()

func get_saves_directory() -> String:
	return ProjectSettings.get_setting(
		"addons/locker/saves_directory",
		LockerPlugin.settings["addons/locker/saves_directory"]["default_value"]
	)

func get_save_files_prefix() -> String:
	return ProjectSettings.get_setting(
		"addons/locker/save_files_prefix",
		LockerPlugin.settings["addons/locker/save_files_prefix"]["default_value"]
	)

func get_save_files_format() -> String:
	return ProjectSettings.get_setting(
		"addons/locker/save_files_format",
		LockerPlugin.settings["addons/locker/save_files_format"]["default_value"]
	)

func get_encryption_password() -> String:
	return ProjectSettings.get_setting(
		"addons/locker/encryption_password",
		LockerPlugin.settings["addons/locker/encryption_password"]["default_value"]
	)

func get_accessors_grouped_by_id() -> Dictionary:
	var grouped_accessors: Dictionary = {}
	
	for accessor: LokStorageAccessor in accessors:
		if not grouped_accessors.has(accessor.id):
			grouped_accessors[accessor.id] = []
		
		grouped_accessors[accessor.id].append(accessor)
	
	return grouped_accessors

func get_repeated_accessors_grouped_by_id() -> Dictionary:
	var repeated_accessors: Dictionary = {}
	
	var accessor_groups: Dictionary = get_accessors_grouped_by_id()
	
	for accessor_id: String in accessor_groups.keys():
		if accessor_groups[accessor_id].size() <= 1:
			continue
		
		repeated_accessors[accessor_id] = accessor_groups[accessor_id]
	
	return repeated_accessors

func get_save_path(file_id: int) -> String:
	var result: String = ""
	
	result += get_saves_directory()
	result += get_save_files_prefix()
	result += str(file_id)
	result += get_save_files_format()
	
	return result

func add_accessor(accessor: LokStorageAccessor) -> bool:
	accessors.append(accessor)
	
	return true

func remove_accessor(accessor: LokStorageAccessor) -> bool:
	var accessor_index: int = accessors.find(accessor)
	
	accessors.remove_at(accessor_index)
	
	return accessor_index != -1

func gather_data() -> Dictionary:
	var data: Dictionary = {}
	
	for accessor: LokStorageAccessor in accessors:
		data[accessor.id] = accessor.save_data()
	
	return data

func distribute_data(data: Dictionary) -> void:
	for accessor: LokStorageAccessor in accessors:
		accessor.load_data(data.get(accessor.id, {}))
		
		var accessor := (
			get_tree().current_scene.get_node(accessor_path)
		) as LokStorageAccessor
		
		if accessor == null:
			push_error("Accessor %s not found" % [ accessor_path ])
			continue
		
		var accessor_data: Dictionary = data[str_accessor_path]
		
		accessor.load_data(accessor_data)

func save_data(file_id: int) -> Dictionary:
	var saves_directory: String = get_saves_directory()
	
	if not DirAccess.dir_exists_absolute(saves_directory):
		var err: Error = DirAccess.make_dir_recursive_absolute(saves_directory)
		
		if err != OK:
			push_error("Unable to create saves directory: '%s'" % [
				saves_directory
			])
			return {}
	
	return access_strategy.save_data(file_id)

func load_data(file_id: int) -> Dictionary:
	var saves_directory: String = get_saves_directory()
	
	if not DirAccess.dir_exists_absolute(saves_directory):
		push_error("Data not found in directory: '%s'" % [
			saves_directory
		])
		return {}
	
	return access_strategy.load_data(file_id)
