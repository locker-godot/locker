@icon("res://addons/locker/icons/locker_plugin.svg")
@tool
## The [LockerPlugin] class is the manager of the Locker Plugin's settings.
## 
## This class is responsible for managing the access of the Plugin
## settings through the use of the [ProjectSettings]. [br]
## The settings of this Plugin stay available in the
## [code]addons/locker[/code] path of the [ProjectSettings]. [br]
## They only become available if the [LockerPlugin] is active, though. [br]
## When active, this Plugin also registers the [LokGlobalStorageManager]
## as an autoload singleton. [br]
## [br]
## [b]Version[/b]: 1.0.0[br]
## [b]Author[/b]: [url]github.com/nadjiel[/url]
class_name LockerPlugin
extends EditorPlugin

#region Constants

## The [constant CONFIG_PATH] constant stores the path where the
## [LockerPlugin]'s configurations should be stored, so that they can be
## persisted even when the Plugin is deactivated and activated.
const CONFIG_PATH: String = "res://addons/locker/config.cfg"

## The [constant AUTOLOAD_NAME] constant stores the name that should be
## given to the [LockerPlugin]'s autoload, when registered.
const AUTOLOAD_NAME := "LokGlobalStorageManager"

## The [constant AUTOLOAD_PATH] constant stores the path to the script of
## the [LokGlobalStorageManager] so that this [LockerPlugin] can register it
## as an autoload when it is activated.
const AUTOLOAD_PATH := "res://addons/locker/scripts/storage_manager/global_storage_manager.gd"

#endregion

#region Settings

## The [member available_strategy_paths] property should store paths
## to [LokAccessStrategy]s that will be exposed in the [ProjectSettings] as
## valid [LokAccessStrategy]s to choose from. [br]
## When adding new [LokAccessStrategy]s to the [LockerPlugin], if they are
## choosable in the [ProjectSettings], their path should be added here. [br]
## They also should have a readable and unique [String] returned from their
## [method Object._to_string] method.
static var available_strategy_paths: Array[String] = [
	"res://addons/locker/scripts/access_strategy/json_access_strategy.gd",
	"res://addons/locker/scripts/access_strategy/encrypted_access_strategy.gd"
]:
	set = set_available_strategy_paths,
	get = get_available_strategy_paths

## The [member plugin_settings] property stores a [Dictionary] that describes
## all the settings that should be appended to the [ProjectSettings] when
## the [LockerPlugin] is activated, so that they can be easily edited through
## the editor. [br]
## Each key of this [Dictionary] points to the setting path in the
## [ProjectSettings] and each value describes information about the setting.
## [br]
## The structure of this property is as follows:
## [codeblock]
## {
##   "setting_1_path": {
##     "default_value": <Variant>,
##     "current_value": <Variant>,
##     "is_basic": <bool>,
##     "property_info": {
##       "name": "setting_1_path",
##       "type": <@GlobalScope.Variant.Type>,
##       "hint": <@GlobalScope.PropertyHint>,
##       "hint_string": <String>
##     },
##     "config_section": <String>,
##   },
##   "setting_n_path": { ... }
## }
## [/codeblock]
## The settings defined in this property are the following: [br]
## - [code]"addons/locker/saves_directory"[/code]: This setting defines the
## default directory where the [LokGlobalStorageManager] should save and load
## the game data. [br]
## - [code]"addons/locker/save_files_prefix"[/code]: This setting defines the
## default prefix that should be given to the save files by the
## [LokGlobalStorageManager]. [br]
## - [code]"addons/locker/save_files_format"[/code]: This setting defines the
## default file format that should be given to the save files by the
## [LokGlobalStorageManager]. [br]
## - [code]"addons/locker/save_versions"[/code]: This setting defines if,
## by default, the [LokGlobalStorageManager] should store the save versions
## when saving. [br]
## - [code]"addons/locker/access_strategy"[/code]: This setting stores a
## [String] that represents what [LokAccessStrategy] the
## [LokGlobalStorageManager] should use to save and load data. To convert
## from this [String] representation to an actual [LokAccessStrategy] instance,
## the [method string_to_strategy] method can be used. [br]
## - [code]"addons/locker/encrypted_strategy/password"[/code]: This setting
## stores the default password that should be used by the
## [LokGlobalStorageManager]'s strategy, if it is the
## [LokEncryptedAccessStrategy].
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

## The [method set_setting_saves_directory] method is a shortcut to
## defining the [code]"addons/locker/saves_directory"[/code] setting
## in the [ProjectSettings] to the value of the passed [param path].
static func set_setting_saves_directory(path: String) -> void:
	ProjectSettings.set_setting("addons/locker/saves_directory", path)

## The [method get_setting_saves_directory] method is a getter to facilitate
## obtaining the [code]"addons/locker/saves_directory"[/code] setting
## from the [ProjectSettings].
static func get_setting_saves_directory() -> String:
	return ProjectSettings.get_setting(
		"addons/locker/saves_directory",
		plugin_settings["addons/locker/saves_directory"]["default_value"]
	)

## The [method set_setting_save_files_prefix] method is a shortcut to
## defining the [code]"addons/locker/save_files_prefix"[/code] setting
## in the [ProjectSettings] to the value of the passed [param prefix].
static func set_setting_save_files_prefix(prefix: String) -> void:
	ProjectSettings.set_setting("addons/locker/save_files_prefix", prefix)

## The [method get_setting_save_files_prefix] method is a getter to facilitate
## obtaining the [code]"addons/locker/save_files_prefix"[/code] setting
## from the [ProjectSettings].
static func get_setting_save_files_prefix() -> String:
	return ProjectSettings.get_setting(
		"addons/locker/save_files_prefix",
		plugin_settings["addons/locker/save_files_prefix"]["default_value"]
	)

## The [method set_setting_save_files_format] method is a shortcut to
## defining the [code]"addons/locker/save_files_format"[/code] setting
## in the [ProjectSettings] to the value of the passed [param format].
static func set_setting_save_files_format(format: String) -> void:
	ProjectSettings.set_setting("addons/locker/save_files_format", format)

## The [method get_setting_save_files_format] method is a getter to facilitate
## obtaining the [code]"addons/locker/save_files_format"[/code] setting
## from the [ProjectSettings].
static func get_setting_save_files_format() -> String:
	return ProjectSettings.get_setting(
		"addons/locker/save_files_format",
		plugin_settings["addons/locker/save_files_format"]["default_value"]
	)

## The [method set_setting_save_versions] method is a shortcut to
## defining the [code]"addons/locker/save_versions"[/code] setting
## in the [ProjectSettings] to the value of the passed [param state].
static func set_setting_save_versions(state: bool) -> void:
	ProjectSettings.set_setting("addons/locker/save_versions", state)

## The [method get_setting_save_versions] method is a getter to facilitate
## obtaining the [code]"addons/locker/save_versions"[/code] setting
## from the [ProjectSettings].
static func get_setting_save_versions() -> bool:
	return ProjectSettings.get_setting(
		"addons/locker/save_versions",
		plugin_settings["addons/locker/save_versions"]["default_value"]
	)

## The [method set_setting_access_strategy] method is a shortcut to
## defining the [code]"addons/locker/access_strategy"[/code] setting
## in the [ProjectSettings] to the value of the passed [param strategy].
static func set_setting_access_strategy(strategy: String) -> void:
	ProjectSettings.set_setting("addons/locker/access_strategy", strategy)

## The [method get_setting_access_strategy] method is a getter to facilitate
## obtaining the [code]"addons/locker/access_strategy"[/code] setting
## from the [ProjectSettings].
static func get_setting_access_strategy() -> String:
	return ProjectSettings.get_setting(
		"addons/locker/access_strategy",
		plugin_settings["addons/locker/access_strategy"]["default_value"]
	)

## The [method get_setting_access_strategy_parsed] method is a getter to
## facilitate obtaining the [code]"addons/locker/access_strategy"[/code]
## setting from the [ProjectSettings] already parsed as a [LokAccessStrategy].
static func get_setting_access_strategy_parsed() -> LokAccessStrategy:
	return string_to_strategy(get_setting_access_strategy())

## The [method set_setting_encrypted_strategy_password] method is a shortcut to
## defining the [code]"addons/locker/encrypted_strategy/password"[/code] setting
## in the [ProjectSettings] to the value of the passed [param password].
static func set_setting_encrypted_strategy_password(password: String) -> void:
	ProjectSettings.set_setting(
		"addons/locker/encrypted_strategy/password", password
	)

## The [method get_setting_encrypted_strategy_password] method is a getter
## to facilitate obtaining the
## [code]"addons/locker/encrypted_strategy/password"[/code]
## setting from the [ProjectSettings].
static func get_setting_encrypted_strategy_password() -> String:
	return ProjectSettings.get_setting(
		"addons/locker/encrypted_strategy/password",
		plugin_settings["addons/locker/encrypted_strategy/password"]["default_value"]
	)

#endregion

#region Setters & Getters

static func set_available_strategy_paths(new_paths: Array[String]) -> void:
	available_strategy_paths = new_paths

static func get_available_strategy_paths() -> Array[String]:
	return available_strategy_paths

static func set_plugin_settings(new_settings: Dictionary) -> void:
	plugin_settings = new_settings

static func get_plugin_settings() -> Dictionary:
	return plugin_settings

#endregion

#region Methods

## The [method get_strategy_scripts] method returns an [Array] of
## [Script]s from an [Array] of paths pointing to those [Script]s.
static func get_strategy_scripts(strategy_paths: Array[String]) -> Array[Script]:
	var scripts: Array[Script] = []
	
	for strategy_path: String in strategy_paths:
		if ResourceLoader.exists(strategy_path):
			scripts.append(load(strategy_path))
	
	return scripts

## The [method get_strategies] method returns an [Array] of
## [LokAccessStrategy] instances from an [Array] of
## [LokAccessStrategy] [Script]s.
static func get_strategies(strategy_scripts: Array[Script]) -> Array[LokAccessStrategy]:
	var strategies: Array[LokAccessStrategy] = []
	
	for script: Script in strategy_scripts:
		var strategy: Object = script.new()
		
		if strategy is LokAccessStrategy:
			strategies.append(strategy as LokAccessStrategy)
	
	return strategies

## The [method get_strategy_strings] method returns an [Array] of
## stringified [LokAccessStrategy]s from an [Array] of
## [LokAccessStrategy] instances.
static func get_strategy_strings(strategies: Array[LokAccessStrategy]) -> Array[String]:
	var result: Array[String] = []
	
	for strategy: LokAccessStrategy in strategies:
		result.append(str(strategy))
	
	return result

## The [method get_string_of_strategies] method converts an [Array] of
## [LokAccessStrategy]s into a [String] that describes that collection in
## a way compatible with [code]hint_string[/code]s.
static func get_string_of_strategies(strategies: Array[LokAccessStrategy]) -> String:
	var result: String = ""
	
	for i: int in strategies.size():
		var strategy: LokAccessStrategy = strategies[i]
		
		result += str(strategy)
		
		if i != strategies.size() - 1:
			result += ","
	
	return result

## The [method get_default_strategy_string] method tries to get a
## [param default] [LokAccessStrategy] [String] that can be used in the
## [ProjectSettings] as the default choice in the strategies enum.
static func get_default_strategy_string(default: String, strategies: Array[LokAccessStrategy]) -> String:
	var result: String = ""
	
	var strategy_strings: Array[String] = get_strategy_strings(strategies)
	
	for strategy_string: String in strategy_strings:
		if strategy_string == default:
			result = default
			
			break
	
	if result == "" and not strategy_strings.is_empty():
		result = strategy_strings[0]
	
	return result

## The [method update_available_strategies] method uses the
## [member available_strategy_paths] to update what [LokAccessStrategy] options
## should be shown in the [ProjectSettings] as options to choose from.
func update_available_strategies() -> void:
	var available_strategy_scripts: Array[Script] = get_strategy_scripts(available_strategy_paths)
	var available_strategies: Array[LokAccessStrategy] = get_strategies(available_strategy_scripts)
	var string_of_available_strategies: String = get_string_of_strategies(available_strategies)
	var default_strategy_string: String = get_default_strategy_string("Encrypted", available_strategies)
	
	plugin_settings["addons/locker/access_strategy"]["property_info"]["hint_string"] = string_of_available_strategies
	plugin_settings["addons/locker/access_strategy"]["default_value"] = default_strategy_string
	plugin_settings["addons/locker/access_strategy"]["current_value"] = default_strategy_string

## The [method string_to_strategy] method takes a [param string] and
## returns a [LokAccessStrategy] that corresponds to that [param string]. [br]
## If an invalid [param string] is passed, this method returns
## [code]null[/code].
static func string_to_strategy(string: String) -> LokAccessStrategy:
	var strategy_scripts: Array[Script] = get_strategy_scripts(available_strategy_paths)
	var strategies: Array[LokAccessStrategy] = get_strategies(strategy_scripts)
	
	for strategy: LokAccessStrategy in strategies:
		if string == str(strategy):
			return strategy
	
	return null

## The [method strategy_to_string] method takes a [param strategy] and
## returns a [String] that represents that [param strategy] in the
## [code]"addons/locker/access_strategy"[/code] setting of the
## [ProjectSettings]. [br]
## If an invalid [param strategy] is passed, this method returns
## an empty [String].
static func strategy_to_string(strategy: LokAccessStrategy) -> String:
	if strategy == null:
		return ""
	
	return str(strategy)

## The [method save_settings] method takes a [param settings] [Dictionary] and
## takes the current value of each one of them from the [ProjectSettings],
## saving them in a [ConfigFile] in the [constant CONFIG_PATH]. [br]
## The [param settings] parameter has to conform to the structure explained in
## the [member plugin_settings] description.
func save_settings(settings: Dictionary) -> void:
	if settings.is_empty():
		return
	
	var config := ConfigFile.new()
	var err: Error = config.load(CONFIG_PATH)
	
	for setting_path: String in settings:
		var setting_data: Dictionary = settings[setting_path]
		var setting_section: String = setting_data["config_section"]
		var setting_name: String = setting_path.get_slice("/locker/", 1)
		var setting_value: Variant = ProjectSettings.get_setting(
			setting_path, setting_data["default_value"]
		)
		
		config.set_value(setting_section, setting_name, setting_value)
	
	config.save(CONFIG_PATH)

## The [method load_settings] method takes a [param settings] [Dictionary] and
## loads the settings described by it from the [ConfigFile] in the
## [constant CONFIG_PATH].
## This method, then, sets the loaded settings in the [ProjectSettings]. [br]
## The [param settings] parameter has to conform to the structure explained in
## the [member plugin_settings] description.
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

## The [method get_changed_settings] method takes a [param settings]
## [Dictionary] and looks for settings that had their values changed. [br]
## When found, their values are updated and they are returned.
## The [param settings] parameter as well as the returned [Dictionary]
## conform to the structure explained in the [member plugin_settings]
## description.
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

## The [method add_settings] method takes a [param settings]
## [Dictionary] and saves each of its settings in the [ProjectSettings]. [br]
## The [param settings] parameter must conform to the structure explained
## in the [member plugin_settings] description.
func add_settings(settings: Dictionary) -> void:
	for setting_path: String in settings.keys():
		var setting: Dictionary = settings[setting_path]
		
		ProjectSettings.set_setting(setting_path, setting["default_value"])
		ProjectSettings.set_initial_value(setting_path, setting["default_value"])
		ProjectSettings.set_as_basic(setting_path, setting["is_basic"])
		ProjectSettings.add_property_info(setting["property_info"])

## The [method remove_settings] method takes a [param settings]
## [Dictionary] and removes each of its settings from the [ProjectSettings].
## [br]
## The [param settings] parameter must conform to the structure explained
## in the [member plugin_settings] description.
func remove_settings(settings: Dictionary) -> void:
	for setting_path: String in settings.keys():
		var setting: Dictionary = settings[setting_path]
		
		ProjectSettings.set_setting(setting_path, null)

## The [method start_plugin] method registers the singleton needed by the
## [LockerPlugin] as an autoload, so it isn't needed to do that manually. [br]
## This method also updates and registers the settings of this plugin in the
## [ProjectSettings], making sure to load any settings used before deactivating
## this plugin. [br]
## When doing that, this method makes it so arbitrary [LokAccessStratey]s
## registered in the [member access_strategy_paths] property are also
## registered in the [ProjectSettings] so that they can be easily selected. [br]
## Finally, this method makes sure that whenever a setting from this Plugin
## is altered, it is saved in the [ConfigFile] in the [constant CONFIG_PATH].
func start_plugin() -> void:
	update_available_strategies()
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)
	add_settings(plugin_settings)
	load_settings(plugin_settings)
	
	LokUtil.check_and_connect_signal(
		ProjectSettings, &"settings_changed", _on_project_settings_changed
	)

## The [method finish_plugin] method unregisters the singleton needed by the
## [LockerPlugin] from the autoloads, so it doesn't stay there without the
## Plugin being active. [br]
## This method also unregisters the settings of this plugin from the
## [ProjectSettings].
func finish_plugin() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
	remove_settings(plugin_settings)
	
	LokUtil.check_and_disconnect_signal(
		ProjectSettings, &"settings_changed", _on_project_settings_changed
	)

# Registers plugin's autoload and settings.
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

# Updates config.cfg file to store changed settings
func _on_project_settings_changed() -> void:
	var changed_settings: Dictionary = get_changed_settings(plugin_settings)
	
	save_settings(changed_settings)

#endregion
