@tool
class_name LockerPlugin
extends EditorPlugin

const CONFIG_PATH: String = "res://addons/locker/config.cfg"

var locker_autoload_name := "LokGlobalStorageManager"
var locker_autoload_path := "res://addons/locker/storage_manager/global_storage_manager.gd"

static var settings := {
	"addons/locker/saves_directory": {
		"default_value": "user://saves/",
		"current_value": "user://saves/",
		"is_basic": true,
		"property_info": {
			"name": "addons/locker/saves_directory",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_DIR
		},
		"config_section": "General"
	},
	"addons/locker/save_files_prefix": {
		"default_value": "file",
		"current_value": "file",
		"is_basic": true,
		"property_info": {
			"name": "addons/locker/save_files_prefix",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_NONE
		},
		"config_section": "General"
	},
	"addons/locker/save_files_format": {
		"default_value": ".sav",
		"current_value": ".sav",
		"is_basic": true,
		"property_info": {
			"name": "addons/locker/save_files_format",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_NONE
		},
		"config_section": "General"
	},
	"addons/locker/use_encryption": {
		"default_value": true,
		"current_value": true,
		"is_basic": true,
		"property_info": {
			"name": "addons/locker/use_encryption",
			"type": TYPE_BOOL,
			"hint": PROPERTY_HINT_NONE
		},
		"config_section": "Encryption"
	},
	"addons/locker/encryption_password": {
		"default_value": "",
		"current_value": "",
		"is_basic": true,
		"property_info": {
			"name": "addons/locker/encryption_password",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_NONE
		},
		"config_section": "Encryption"
	}
}

# Saves the settings in the settings_to_save dictionary
func save_settings(settings_to_save: Dictionary) -> void:
	if settings_to_save.is_empty():
		return
	
	var config := ConfigFile.new()
	var err: Error = config.load(CONFIG_PATH)
	
	for setting_path: String in settings_to_save:
		var setting_data: Dictionary = settings_to_save[setting_path]
		var setting_section: String = setting_data["config_section"]
		var setting_name: String = setting_path.get_slice("/locker/", 1)
		var setting_value: Variant = ProjectSettings.get_setting(
			setting_path, setting_data["default_value"]
		)
		
		config.set_value(setting_section, setting_name, setting_value)
	
	config.save(CONFIG_PATH)

func load_settings() -> void:
	var config := ConfigFile.new()
	var err: Error = config.load(CONFIG_PATH)
	
	if err != OK:
		return
	
	for setting_path: String in settings:
		var setting_data: Dictionary = settings[setting_path]
		var setting_section: String = setting_data["config_section"]
		var setting_name: String = setting_path.get_slice("/locker/", 1)
		var default_value: Variant = setting_data["default_value"]
		
		var new_value: Variant = config.get_value(
			setting_section, setting_name, default_value
		)
		
		if new_value != setting_data["current_value"]:
			setting_data["current_value"] = new_value
		
		ProjectSettings.set_setting(setting_path, new_value)

func save_changed_settings() -> void:
	var settings_to_save: Dictionary = {}
	
	for setting_path: String in settings.keys():
		var setting_data: Dictionary = settings[setting_path]
		var default_value: Variant = setting_data["default_value"]
		var new_value: Variant = ProjectSettings.get_setting(
			setting_path, default_value
		)
		
		if new_value != setting_data["current_value"]:
			settings_to_save[setting_path] = setting_data
			
			setting_data["current_value"] = new_value
	
	save_settings(settings_to_save)

func add_settings() -> void:
	for setting: String in settings.keys():
		ProjectSettings.set_setting(setting, settings[setting]["default_value"])
		ProjectSettings.set_initial_value(setting, settings[setting]["default_value"])
		ProjectSettings.set_as_basic(setting, settings[setting]["is_basic"])
		ProjectSettings.add_property_info(settings[setting]["property_info"])

func remove_settings() -> void:
	for setting: String in settings.keys():
		ProjectSettings.set_setting(setting, null)

func _enter_tree() -> void:
	add_settings()
	load_settings()
	
	if not ProjectSettings.settings_changed.is_connected(_on_project_settings_changed):
		ProjectSettings.settings_changed.connect(_on_project_settings_changed)

func _exit_tree() -> void:
	remove_settings()
	
	if ProjectSettings.settings_changed.is_connected(_on_project_settings_changed):
		ProjectSettings.settings_changed.disconnect(_on_project_settings_changed)

# Registers plugin's autoload and settings.
func _enable_plugin() -> void:
	add_autoload_singleton(locker_autoload_name, locker_autoload_path)
	add_settings()

# Unregisters plugin's autoload and settings.
func _disable_plugin() -> void:
	remove_autoload_singleton(locker_autoload_name)
	remove_settings()

func _on_project_settings_changed() -> void:
	save_changed_settings()
