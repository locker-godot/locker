@tool
extends EditorPlugin

var locker_autoload_name := "LokGlobalStorageManager"
var locker_autoload_path := "res://addons/locker/storage_manager/global_storage_manager.gd"

var locker_settings := {
	"addons/locker/saves_directory": {
		"default_value": "user://saves/",
		"is_basic": true,
		"property_info": {
			"name": "addons/locker/saves_directory",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_DIR
		}
	},
	"addons/locker/save_files_prefix": {
		"default_value": "file",
		"is_basic": true,
		"property_info": {
			"name": "addons/locker/save_files_prefix",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_NONE
		}
	},
	"addons/locker/save_files_format": {
		"default_value": ".sav",
		"is_basic": true,
		"property_info": {
			"name": "addons/locker/save_files_format",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_NONE
		}
	},
	"addons/locker/use_encryption": {
		"default_value": true,
		"is_basic": true,
		"property_info": {
			"name": "addons/locker/use_encryption",
			"type": TYPE_BOOL,
			"hint": PROPERTY_HINT_NONE
		}
	},
	"addons/locker/encryption_password": {
		"default_value": "",
		"is_basic": true,
		"property_info": {
			"name": "addons/locker/encryption_password",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_NONE
		}
	}
}

func add_locker_settings() -> void:
	for setting: String in locker_settings.keys():
		ProjectSettings.set_setting(setting, locker_settings[setting]["default_value"])
		ProjectSettings.set_initial_value(setting, locker_settings[setting]["default_value"])
		ProjectSettings.set_as_basic(setting, locker_settings[setting]["is_basic"])
		ProjectSettings.add_property_info(locker_settings[setting]["property_info"])

func remove_locker_settings() -> void:
	for setting: String in locker_settings.keys():
		ProjectSettings.set_setting(setting, null)

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass

# Registers plugin's autoload and settings.
func _enable_plugin() -> void:
	add_autoload_singleton(locker_autoload_name, locker_autoload_path)
	add_locker_settings()

# Unregisters plugin's autoload and settings.
func _disable_plugin() -> void:
	remove_autoload_singleton(locker_autoload_name)
	remove_locker_settings()
