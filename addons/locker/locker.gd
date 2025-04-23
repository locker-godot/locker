@icon("res://addons/locker/icons/locker_plugin.svg")
@tool
## The [LockerPlugin] class is the manager of the Locker Plugin's
## editor features.
## 
## This class is responsible for managing the access of the settings
## of this Plugin through the use of the [LokSettingsManager] class.[br]
## The settings of this Plugin only become available while the
## [LockerPlugin] is active, though.[br]
## When active, this Plugin also registers the [LokGlobalStorageManager]
## as an autoload singleton.[br]
## [br]
## [b]Version[/b]: 1.0.0[br]
## [b]Author[/b]: [url]github.com/nadjiel[/url]
class_name LockerPlugin
extends EditorPlugin

#region Constants

## The [constant AUTOLOAD_NAME] constant stores the name that should be
## given to the [LockerPlugin]'s autoload, when registered.
const AUTOLOAD_NAME := "LokGlobalStorageManager"

## The [constant AUTOLOAD_PATH] constant stores the path to the script of
## the [LokGlobalStorageManager] so that this [LockerPlugin] can register it
## as an autoload when it is activated.
const AUTOLOAD_PATH := "res://addons/locker/scripts/storage_manager/global_storage_manager.gd"

#endregion

#region Methods

# Registers plugin's autoload and settings.
func _enter_tree() -> void:
	_start_plugin()

# Unregisters plugin's autoload and settings.
func _exit_tree() -> void:
	_finish_plugin()

# Registers plugin's autoload and settings.
func _enable_plugin() -> void:
	_start_plugin()

# Unregisters plugin's autoload and settings.
func _disable_plugin() -> void:
	_finish_plugin()

## The [method _start_plugin] method registers the singleton needed by the
## [LockerPlugin] as an autoload, so it isn't needed to do that manually.[br]
## This method also updates and registers the settings of this plugin in the
## [ProjectSettings], making sure to load any settings used before deactivating
## this plugin.[br]
## When doing that, this method makes it so arbitrary [LokAccessStratey]s
## saved in the [member LokSettingsManager.STRATEGY_SCRIPTS_PATH] are also
## made available in the [ProjectSettings] so that they can be easily selected.
## [br]
## Finally, this method makes sure that whenever a setting from this Plugin
## is altered, it is saved in the [ConfigFile] in the
## [constant LokSettingsManager.CONFIG_PATH].
func _start_plugin() -> void:
	LokSettingsManager.update_available_strategies()
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)
	LokSettingsManager.add_settings()
	LokSettingsManager.load_settings()
	
	LokUtil.check_and_connect_signal(
		ProjectSettings, &"settings_changed", _on_project_settings_changed
	)

## The [method _finish_plugin] method unregisters the singleton needed by the
## [LockerPlugin] from the autoloads, so it doesn't stay there without the
## Plugin being active.[br]
## This method also unregisters the settings of this plugin from the
## [ProjectSettings].
func _finish_plugin() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
	LokSettingsManager.remove_settings()
	
	LokUtil.check_and_disconnect_signal(
		ProjectSettings, &"settings_changed", _on_project_settings_changed
	)

# Updates config.cfg file to store changed settings
func _on_project_settings_changed() -> void:
	var changed_settings: Dictionary = LokSettingsManager.get_changed_settings()
	
	LokSettingsManager.save_settings(changed_settings)

#endregion
