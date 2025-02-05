## The [LokSceneStorageManager] class is just an intermediate to access
## the [LokGlobalStorageManager] class through the current scene tree,
## if wanted.
## 
## This class is useful when it is desired to trigger the
## [LokGlobalStorageManager] methods through signal emissions, for example.
class_name LokSceneStorageManager
extends LokStorageManager

## The [member current_version] property is used as the version with which
## data is saved when using this [LokSceneStorageManager]. [br]
## By default, it is set to [code]"1.0.0"[/code].
var current_version: String = "1.0.0":
	set = set_current_version,
	get = get_current_version

func set_current_version(new_version: String) -> void:
	current_version = new_version

func get_current_version() -> String:
	return current_version

## The [method save_data] method is just another way of calling
## the [method LokGlobalStorageManager.save_data] method, which
## performs the procedure of saving the game. [br]
## This method has as its only mandatory parameter the [param file_id]
## that determines in what file the game should be saved. [br]
## The [param version_number] parameter specifies what version of the
## currently registered [LokStorageAccessor]s should be used to save the game.
## By default, it is set to the value of the [member current_version] property.
## [br]
## The remaining parameters are better explained in the
## [method LokGlobalStorageManager.save_data] method.
func save_data(
	file_id: int,
	version_number: String = current_version,
	accessor_ids: Array[String] = [],
	replace: bool = false,
	remover: Callable = default_remover
) -> Dictionary:
	return LokGlobalStorageManager.save_data(
		file_id,
		version_number,
		accessor_ids,
		replace,
		remover
	)

## The [method load_data] method uses the
## [method LokGlobalStorageManager.load_data] method to load the
## previously saved data into the currently registered [LokStorageAccessor]s
## of the game. [br]
## This method has as its only mandatory parameter the [param file_id]
## that determines from what file the game should be loaded. [br]
## The [param accessor_ids] parameter specifies which of the
## currently registered [LokStorageAccessor]s should receive the loaded data.
## If left as an empty [Array], all current [LokStorageAccessor]s
## receive the data.
func load_data(
	file_id: int,
	accessor_ids: Array[String] = []
) -> Dictionary:
	return LokGlobalStorageManager.load_data(
		file_id,
		accessor_ids
	)
