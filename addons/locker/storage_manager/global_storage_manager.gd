## This class is registered as an autoload when the Locker plugin is active.
## 
## It's this class that's responsible for keeping track of all the
## [StorageAccessor]s that need saving and loading.
extends LokStorageManager

var accessors := {}

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

func add_accessor(accessor: LokStorageAccessor) -> bool:
	accessors[accessor.get_path()] = accessor
	
	return true

func remove_accessor(accessor: LokStorageAccessor) -> bool:
	return accessors.erase(accessor.get_path())
