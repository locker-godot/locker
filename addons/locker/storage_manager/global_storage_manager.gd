## This class is registered as an autoload when the Locker plugin is active.
## 
## It's this class that's responsible for keeping track of all the
## [StorageAccessor]s that need saving and loading.
extends LokStorageManager

var accessors := {}

var access_strategy: LokAccessStrategy = LokJSONAccessStrategy.new()

func get_saves_directory() -> String:
	if not ProjectSettings.has_setting("addons/locker/saves_directory"):
		return ""
	
	return ProjectSettings.get_setting("addons/locker/saves_directory")

func get_save_files_prefix() -> String:
	if not ProjectSettings.has_setting("addons/locker/save_files_prefix"):
		return ""
	
	return ProjectSettings.get_setting("addons/locker/save_files_prefix")

func get_save_files_format() -> String:
	if not ProjectSettings.has_setting("addons/locker/save_files_format"):
		return ""
	
	return ProjectSettings.get_setting("addons/locker/save_files_format")

func get_encryption_password() -> String:
	if not ProjectSettings.has_setting("addons/locker/encryption_password"):
		return ""
	
	return ProjectSettings.get_setting("addons/locker/encryption_password")

func get_save_path(file_id: int) -> String:
	var result: String = ""
	
	result += get_saves_directory()
	result += get_save_files_prefix() 
	result += str(file_id)
	result += get_save_files_format()
	
	return result

func add_accessor(accessor: LokStorageAccessor) -> bool:
	accessors[accessor.get_path()] = accessor
	
	return true

func remove_accessor(accessor: LokStorageAccessor) -> bool:
	return accessors.erase(accessor.get_path())

func gather_data() -> Dictionary:
	var data: Dictionary = {}
	
	for accessor_path: NodePath in accessors.keys():
		data[accessor_path] = accessors[accessor_path].save_data()
	
	return data

func distribute_data(data: Dictionary) -> void:
	for accessor_path: NodePath in data.keys():
		var accessor := (
			get_tree().current_scene.get_node(accessor_path)
		) as LokStorageAccessor
		
		if accessor == null:
			push_error("Accessor %s not found" % [ accessor_path ])
			continue
		
		accessor.load_data(data.get(accessor_path))

func save_data(file_id: int) -> Dictionary:
	var saves_directory: String = get_saves_directory()
	
	if not DirAccess.dir_exists_absolute(saves_directory):
		var err: Error = DirAccess.make_dir_recursive_absolute(saves_directory)
		
		if err != OK:
			push_error("Unable to create saves directory: '%s'" % [
				saves_directory
			])
			return {}
	
	return access_strategy.save_data(file_id, accessors)

func load_data(file_id: int) -> Dictionary:
	var saves_directory: String = get_saves_directory()
	
	if not DirAccess.dir_exists_absolute(saves_directory):
		push_error("Data not found in directory: '%s'" % [
			saves_directory
		])
		return {}
	
	return access_strategy.load_data(file_id, accessors)
