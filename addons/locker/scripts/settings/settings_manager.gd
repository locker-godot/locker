@tool
@icon("res://addons/locker/icons/util.svg")
## The [LokSettingsManager] class provides simplified ways to
## manage the [LockerPlugin] settings.
## 
## This class is responsible for managing the access of the [LockerPlugin]'s
## settings through the use of the [ProjectSettings].[br]
## The settings of this Plugin stay available in the
## [code]addons/locker[/code] path of the [ProjectSettings].[br]
## With this class, the settings exposed by the [LockerPlugin] can
## be registered, unregistered, set and get from the [ProjectSettings].[br]
## [br]
## [b]Version[/b]: 1.1.2 [br]
## [b]Author[/b]: Daniel Sousa ([url]github.com/nadjiel[/url])
class_name LokSettingsManager
extends Node

#region Constants

## The [constant CONFIG_PATH] constant stores the path where the
## [LockerPlugin]'s configurations should be stored, so that they can be
## persisted even when the Plugin is deactivated and activated again.
const CONFIG_PATH: String = "res://addons/locker/config.cfg"

## The [constant STRATEGY_SCRIPTS_PATH] constant stores the path to where the
## scripts of [LokAccessStrategy]s are located.[br]
## It's the [LokAccessStrategy]s declared in that folder that are exposed
## to be selectable in the [ProjectSettings] as [LokAccessStrategy]s to be
## used by this plugin.
const STRATEGY_SCRIPTS_PATH := "res://addons/locker/scripts/access_strategy/default_strategies/"

#endregion

#region Properties

## The [member _strategy_scripts] property stores references to the [Script]s
## of the [LokAccessStrategy]s that the [LockerPlugin] knows thanks
## to the path in the [constant STRATEGY_SCRIPTS_PATH] constant.
static var _strategy_scripts: Array[Script] = _load_strategy_scripts():
	set = _set_strategy_scripts,
	get = _get_strategy_scripts

## The [member _plugin_settings] property stores a [Dictionary] that describes
## all the settings that should be appended to the [ProjectSettings] when
## the [LockerPlugin] is activated, so that they can be easily edited through
## the editor.[br]
## Each key of this [Dictionary] points to the setting path in the
## [ProjectSettings] and each value describes information about the setting.[br]
## The structure of this property is as follows:
## [codeblock lang=gdscript]
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
## The settings defined in this property are the following:[br]
## - [code]"addons/locker/saves_directory"[/code]: This setting defines the
## default directory where the [LokGlobalStorageManager] should save and load
## the game data.[br]
## - [code]"addons/locker/save_files_prefix"[/code]: This setting defines the
## default prefix that should be given to the save files by the
## [LokGlobalStorageManager].[br]
## - [code]"addons/locker/save_files_format"[/code]: This setting defines the
## default file format that should be given to the save files by the
## [LokGlobalStorageManager].[br]
## - [code]"addons/locker/save_versions"[/code]: This setting defines if,
## by default, the [LokGlobalStorageManager] should store the save versions
## when saving.[br]
## - [code]"addons/locker/access_strategy"[/code]: This setting stores a
## [String] that represents what [LokAccessStrategy] the
## [LokGlobalStorageManager] should use to save and load data. To convert
## from this [String] representation to an actual [LokAccessStrategy] instance,
## the [method _string_to_strategy] method can be used.[br]
## - [code]"addons/locker/encrypted_strategy/password"[/code]: This setting
## stores the default password that should be used by the
## [LokGlobalStorageManager]'s strategy, if it is the
## [LokEncryptedAccessStrategy].
static var _plugin_settings := {
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
	set = _set_plugin_settings,
	get = _get_plugin_settings

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
		_plugin_settings["addons/locker/saves_directory"]["default_value"]
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
		_plugin_settings["addons/locker/save_files_prefix"]["default_value"]
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
		_plugin_settings["addons/locker/save_files_format"]["default_value"]
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
		_plugin_settings["addons/locker/save_versions"]["default_value"]
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
		_plugin_settings["addons/locker/access_strategy"]["default_value"]
	)

## The [method get_setting_access_strategy_parsed] method is a getter to
## facilitate obtaining the [code]"addons/locker/access_strategy"[/code]
## setting from the [ProjectSettings] already parsed as a [LokAccessStrategy].
static func get_setting_access_strategy_parsed() -> LokAccessStrategy:
	return _string_to_strategy(get_setting_access_strategy())

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
		_plugin_settings["addons/locker/encrypted_strategy/password"]["default_value"]
	)

#endregion

#region Setters & Getters

static func _set_strategy_scripts(new_scripts: Array[Script]) -> void:
	_strategy_scripts = new_scripts

static func _get_strategy_scripts() -> Array[Script]:
	return _strategy_scripts

static func _set_plugin_settings(new_settings: Dictionary) -> void:
	_plugin_settings = new_settings

static func _get_plugin_settings() -> Dictionary:
	return _plugin_settings

#endregion

#region Methods

## The [method update_available_strategies] method uses the
## [member _strategy_scripts] to update what [LokAccessStrategy] options
## should be shown in the [ProjectSettings] as options to choose from.
static func update_available_strategies() -> void:
	_strategy_scripts = _load_strategy_scripts()
	var available_strategies: Array[LokAccessStrategy] = _get_strategies()
	var string_of_available_strategies: String = _get_strategies_enum_string()
	var default_strategy_string: String = _get_default_strategy_name("Encrypted")
	
	_plugin_settings["addons/locker/access_strategy"]["property_info"]["hint_string"] = string_of_available_strategies
	_plugin_settings["addons/locker/access_strategy"]["default_value"] = default_strategy_string
	_plugin_settings["addons/locker/access_strategy"]["current_value"] = default_strategy_string

## The [method save_settings] method takes a [param settings] [Dictionary] and
## takes the current value of each one of them from the [ProjectSettings],
## saving them in a [ConfigFile] in the [constant CONFIG_PATH].[br]
## The [param settings] parameter has to conform to the structure explained in
## the [member _plugin_settings] description.
static func save_settings(settings: Dictionary) -> void:
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
## This method, then, sets the loaded settings in the [ProjectSettings].[br]
## The [param settings] parameter has to conform to the structure explained in
## the [member _plugin_settings] description.
static func load_settings(settings: Dictionary = _plugin_settings) -> void:
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
## [Dictionary] and looks for settings that had their values changed.[br]
## When found, their values are updated and they are returned.
## The [param settings] parameter as well as the returned [Dictionary]
## conform to the structure explained in the [member _plugin_settings]
## description.
static func get_changed_settings(settings: Dictionary = _plugin_settings) -> Dictionary:
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
## [Dictionary] and saves each of its settings in the [ProjectSettings].[br]
## The [param settings] parameter must conform to the structure explained
## in the [member _plugin_settings] description.
static func add_settings(settings: Dictionary = _plugin_settings) -> void:
	for setting_path: String in settings.keys():
		var setting: Dictionary = settings[setting_path]
		
		ProjectSettings.set_setting(setting_path, setting["default_value"])
		ProjectSettings.set_initial_value(setting_path, setting["default_value"])
		ProjectSettings.set_as_basic(setting_path, setting["is_basic"])
		ProjectSettings.add_property_info(setting["property_info"])

## The [method remove_settings] method takes a [param settings]
## [Dictionary] and removes each of its settings from the [ProjectSettings].[br]
## The [param settings] parameter must conform to the structure explained
## in the [member _plugin_settings] description.
static func remove_settings(settings: Dictionary = _plugin_settings) -> void:
	for setting_path: String in settings.keys():
		var setting: Dictionary = settings[setting_path]
		
		ProjectSettings.set_setting(setting_path, null)

## The [method _load_strategy_scripts] method returns an [Array] of
## [Script]s with the scripts that could be found in the path
## pointed by the [constant STRATEGY_SCRIPTS_PATH] constant.
static func _load_strategy_scripts() -> Array[Script]:
	var scripts: Array[Script] = []
	
	for resource: Resource in LokFileSystemUtil.load_resources(STRATEGY_SCRIPTS_PATH, "Script"):
		if not resource is Script:
			continue
		
		scripts.append(resource as Script)
	
	return scripts

## The [method _get_strategies] method returns an [Array] of
## [LokAccessStrategy] instances got from the [Script]s in the
## [member _strategy_scripts] property.
static func _get_strategies() -> Array[LokAccessStrategy]:
	var strategies: Array[LokAccessStrategy] = []
	
	for script: Script in _strategy_scripts:
		var strategy: Object = script.new()
		
		if strategy is LokAccessStrategy:
			strategies.append(strategy as LokAccessStrategy)
	
	return strategies

## The [method _get_strategies_enum_string] method parses the
## [LokAccessStrategy]s that the [LockerPlugin] knows into a [String]
## that describes them in a way compatible with [code]hint_string[/code]s.
static func _get_strategies_enum_string() -> String:
	var result: String = ""
	
	var strategies: Array[LokAccessStrategy] = _get_strategies()
	
	for i: int in strategies.size():
		var strategy: LokAccessStrategy = strategies[i]
		
		result += str(strategy)
		
		if i != strategies.size() - 1:
			result += ","
	
	return result

## The [method _get_default_strategy_name] method tries to get the
## name of the [LokAccessStrategy] specified by the [param wanted_name]
## parameter, so that name can be used in the [ProjectSettings] as the
## default choice in the strategies enum.[br]
## If there's no such [LokAccessStrategy] known by the [LockerPlugin], this
## method will return any [LokAccessStrategy] name it knows, or even
## an empty [String], if it doesn't know any [LokAccessStrategy]s.
static func _get_default_strategy_name(wanted_name: String) -> String:
	var result: String = ""
	
	var strategies: Array[LokAccessStrategy] = _get_strategies()
	
	for strategy: LokAccessStrategy in strategies:
		var strategy_name: String = str(strategy)
		
		if strategy_name == wanted_name:
			result = wanted_name
			
			return result
	
	if result == "" and not strategies.is_empty():
		result = str(strategies[0])
	
	return result

## The [method _string_to_strategy] method takes a [param string] and
## returns a [LokAccessStrategy] that corresponds to that [param string].[br]
## If an invalid [param string] is passed, this method returns
## [code]null[/code].
static func _string_to_strategy(string: String) -> LokAccessStrategy:
	var strategies: Array[LokAccessStrategy] = _get_strategies()
	
	for strategy: LokAccessStrategy in strategies:
		if string == str(strategy):
			return strategy
	
	return null

## The [method _strategy_to_string] method takes a [param strategy] and
## returns a [String] that represents that [param strategy] in the
## [code]"addons/locker/access_strategy"[/code] setting of the
## [ProjectSettings].[br]
## If an invalid [param strategy] is passed, this method returns
## an empty [String].
static func _strategy_to_string(strategy: LokAccessStrategy) -> String:
	if strategy == null:
		return ""
	
	return str(strategy)

#endregion
