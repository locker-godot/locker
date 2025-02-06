## The [LokSceneStorageManager] class is just an intermediate to access
## the [LokGlobalStorageManager] class through the current scene tree,
## if wanted.
## 
## This class is useful when it is desired to trigger the
## [LokGlobalStorageManager] methods through signal emissions, for example.
class_name LokSceneStorageManager
extends LokStorageManager

## The [member global_manager] property should not be altered since it's just
## a reference to the [LokGlobalStorageManager] autoload. [br]
## Its reference is stored here instead of called directly to make
## mocking it with unit testing easier.
var global_manager := LokGlobalStorageManager:
	set = set_global_manager,
	get = get_global_manager

## The [member current_version] property is used as the version with which
## data is saved when using this [LokSceneStorageManager]. [br]
## By default, it is set to [code]"1.0.0"[/code].
var current_version: String = "1.0.0":
	set = set_current_version,
	get = get_current_version

func set_global_manager(new_manager: LokGlobalStorageManager) -> void:
	global_manager = new_manager

func get_global_manager() -> LokGlobalStorageManager:
	return global_manager

func set_current_version(new_version: String) -> void:
	current_version = new_version

func get_current_version() -> String:
	return current_version

## The [method get_readable_name] method is a utility for debugging. [br]
## It returns a more user friendly name for this node, so that errors
## can use it to be clearer.
func get_readable_name() -> String:
	if is_inside_tree():
		return str(get_path())
	if name != "":
		return name
	
	return str(self)

## The [method push_error_no_manager] method pushes an error indicating
## that no [LokSceneStorageManager] was found in the [member global_manager]
## property, which shouldn't happen if that property wasn't altered as
## recommended.
func push_error_no_manager() -> void:
	push_error("No GlobalManager found in %s" % get_readable_name())

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
	replace: bool = false
) -> Dictionary:
	if global_manager == null:
		push_error_no_manager()
		return {}
	
	return global_manager.save_data(
		file_id,
		version_number,
		accessor_ids,
		replace
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
## receive the data. [br]
## The [param partition_ids] and [param version_numbers] parameters work
## in a similar way, restricting what [b]partitions[/b] and [b]versions[/b]
## should be considered when loading.
## At the end, this method returns a [Dictionary] with the information obtained.
func load_data(
	file_id: int,
	accessor_ids: Array[String] = [],
	partition_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	if global_manager == null:
		push_error_no_manager()
		return {}
	
	return global_manager.load_data(
		file_id,
		accessor_ids,
		partition_ids,
		version_numbers
	)

## The [method read_data] method is an intermediate to calling the same method
## in the [LokGlobalStorageManager] autoload. More information about it
## can be found here: [member LokGlobalStorageManager.read_data].
func read_data(
	file_id: int,
	accessor_ids: Array[String] = [],
	partition_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	if global_manager == null:
		push_error_no_manager()
		return {}
	
	return global_manager.read_data(
		file_id,
		accessor_ids,
		partition_ids,
		version_numbers
	)

## The [method remove_data] method is an intermediate to calling the same method
## in the [LokGlobalStorageManager] autoload. More information about it
## can be found here: [member LokGlobalStorageManager.remove_data].
func remove_data(
	file_id: int,
	remover: Callable = default_remover
) -> Dictionary:
	if global_manager == null:
		push_error_no_manager()
		return {}
	
	return global_manager.remove_data(
		file_id,
		remover
	)
