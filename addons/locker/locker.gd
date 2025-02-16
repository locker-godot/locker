@tool
class_name LockerPlugin
extends EditorPlugin

const CONFIG_PATH: String = "res://addons/locker/config.cfg"
const AUTOLOAD_NAME := "LokGlobalStorageManager"
const AUTOLOAD_PATH := "res://addons/locker/storage_manager/global_storage_manager.gd"

signal setting_changed(setting: Dictionary)

#region Settings

static var plugin_settings := {
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
		"default_value": "sav",
		"current_value": "sav",
		"is_basic": true,
		"property_info": {
			"name": "addons/locker/save_files_format",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_NONE
		},
		"config_section": "General"
	},
	"addons/locker/save_versions": {
		"default_value": true,
		"current_value": true,
		"is_basic": true,
		"property_info": {
			"name": "addons/locker/save_versions",
			"type": TYPE_BOOL,
			"hint": PROPERTY_HINT_NONE
		},
		"config_section": "General"
	},
	"addons/locker/access_strategy": {
		"default_value": "Encrypted",
		"current_value": "Encrypted",
		"is_basic": true,
		"property_info": {
			"name": "addons/locker/access_strategy",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "JSON,Encrypted"
		},
		"config_section": "General"
	},
	"addons/locker/encrypted_strategy/password": {
		"default_value": "",
		"current_value": "",
		"is_basic": true,
		"property_info": {
			"name": "addons/locker/encrypted_strategy/password",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_NONE
		},
		"config_section": "EncryptedStrategy"
	}
}:
	set = set_plugin_settings,
	get = get_plugin_settings

#endregion

#region Settings Setters & Getters

static func set_setting_saves_directory(path: String) -> void:
	ProjectSettings.set_setting("addons/locker/saves_directory", path)

static func get_setting_saves_directory() -> String:
	return ProjectSettings.get_setting(
		"addons/locker/saves_directory",
		plugin_settings["addons/locker/saves_directory"]["default_value"]
	)

static func set_setting_save_files_prefix(prefix: String) -> void:
	ProjectSettings.set_setting("addons/locker/save_files_prefix", prefix)

static func get_setting_save_files_prefix() -> String:
	return ProjectSettings.get_setting(
		"addons/locker/save_files_prefix",
		plugin_settings["addons/locker/save_files_prefix"]["default_value"]
	)

static func set_setting_save_files_format(new_format: String) -> void:
	ProjectSettings.set_setting("addons/locker/save_files_format", new_format)

static func get_setting_save_files_format() -> String:
	return ProjectSettings.get_setting(
		"addons/locker/save_files_format",
		plugin_settings["addons/locker/save_files_format"]["default_value"]
	)

static func set_setting_save_versions(new_state: bool) -> void:
	ProjectSettings.set_setting("addons/locker/save_versions", new_state)

static func get_setting_save_versions() -> bool:
	return ProjectSettings.get_setting(
		"addons/locker/save_versions",
		plugin_settings["addons/locker/save_versions"]["default_value"]
	)

static func set_setting_access_strategy(new_strategy: String) -> void:
	ProjectSettings.set_setting("addons/locker/access_strategy", new_strategy)

static func get_setting_access_strategy() -> String:
	return ProjectSettings.get_setting(
		"addons/locker/access_strategy",
		plugin_settings["addons/locker/access_strategy"]["default_value"]
	)

static func get_setting_access_strategy_parsed() -> LokAccessStrategy:
	return string_to_strategy(get_setting_access_strategy())

static func set_setting_encrypted_strategy_password(new_password: String) -> void:
	ProjectSettings.set_setting(
		"addons/locker/encrypted_strategy/password", new_password
	)

static func get_setting_encrypted_strategy_password() -> String:
	return ProjectSettings.get_setting(
		"addons/locker/encrypted_strategy/password",
		plugin_settings["addons/locker/encrypted_strategy/password"]["default_value"]
	)

#endregion

#region Setters & Getters

static func set_plugin_settings(new_settings: Dictionary) -> void:
	plugin_settings = new_settings

static func get_plugin_settings() -> Dictionary:
	return plugin_settings

#endregion

#region Methods

static func string_to_strategy(string: String) -> LokAccessStrategy:
	match(string):
		"JSON": return LokJSONAccessStrategy.new()
		"Encrypted": return LokEncryptedAccessStrategy.new()
	
	return LokAccessStrategy.new()

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

func load_settings(settings: Dictionary) -> void:
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

func get_changed_settings(settings: Dictionary) -> Dictionary:
	var settings_changed: Dictionary = {}
	
	for setting_path: String in settings.keys():
		var setting_data: Dictionary = settings[setting_path]
		var default_value: Variant = setting_data["default_value"]
		var new_value: Variant = ProjectSettings.get_setting(
			setting_path, default_value
		)
		
		if new_value != setting_data["current_value"]:
			settings_changed[setting_path] = setting_data
			
			setting_data["current_value"] = new_value
	
	return settings_changed

func add_settings(settings: Dictionary) -> void:
	for setting_path: String in settings.keys():
		var setting: Dictionary = settings[setting_path]
		
		ProjectSettings.set_setting(setting_path, setting["default_value"])
		ProjectSettings.set_initial_value(setting_path, setting["default_value"])
		ProjectSettings.set_as_basic(setting_path, setting["is_basic"])
		ProjectSettings.add_property_info(setting["property_info"])

func remove_settings(settings: Dictionary) -> void:
	for setting_path: String in settings.keys():
		var setting: Dictionary = settings[setting_path]
		
		ProjectSettings.set_setting(setting_path, null)

func start_plugin() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)
	add_settings(plugin_settings)
	load_settings(plugin_settings)
	
	
	LokUtil.check_and_connect_signal(
		ProjectSettings, &"settings_changed", _on_project_settings_changed
	)

func finish_plugin() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
	remove_settings(plugin_settings)
	
	LokUtil.check_and_disconnect_signal(
		ProjectSettings, &"settings_changed", _on_project_settings_changed
	)

# Registers plugin's autoload and settings.
# Initializes properties to settings' defaults
func _enter_tree() -> void:
	start_plugin()

# Unregisters plugin's autoload and settings.
func _exit_tree() -> void:
	finish_plugin()

# Registers plugin's autoload and settings.
func _enable_plugin() -> void:
	start_plugin()

# Unregisters plugin's autoload and settings.
func _disable_plugin() -> void:
	finish_plugin()

# Updates config.cfg file to store settings
func _on_project_settings_changed() -> void:
	var changed_settings: Dictionary = get_changed_settings(plugin_settings)
	
	save_settings(changed_settings)

#endregion
