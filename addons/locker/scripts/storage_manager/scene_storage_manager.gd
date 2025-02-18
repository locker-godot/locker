## The [LokSceneStorageManager] class is just an intermediate to access
## the [LokGlobalStorageManager] class through the current scene tree,
## if wanted.
## 
## This class is useful when it is desired to trigger the
## [LokGlobalStorageManager] methods through signal emissions
## in the scene tree using the inspector, for example.[br]
## [br]
## [b]Version[/b]: 1.0.0[br]
## [b]Author[/b]: [url]github.com/nadjiel[/url]
class_name LokSceneStorageManager
extends LokStorageManager

#region Properties

## The [member global_manager] property should not be altered since it's just
## a reference to the [LokGlobalStorageManager] autoload. [br]
## Its reference is stored here instead of called directly to make
## mocking it with unit testing easier. [br]
## To guarantee that this property isn't altered, its setter doesn't allow
## modifications. That could be changed if this class is overridden, though.
var global_manager: LokStorageManager:
	set = set_global_manager,
	get = get_global_manager

var global_manager_connections: Array[Dictionary] = [
	{ "name": &"operation_started", "callable": _on_global_manager_operation_started },
	{ "name": &"saving_started", "callable": _on_global_manager_saving_started },
	{ "name": &"loading_started", "callable": _on_global_manager_loading_started },
	{ "name": &"reading_started", "callable": _on_global_manager_reading_started },
	{ "name": &"removing_started", "callable": _on_global_manager_removing_started },
	{ "name": &"operation_finished", "callable": _on_global_manager_operation_finished },
	{ "name": &"saving_finished", "callable": _on_global_manager_saving_finished },
	{ "name": &"loading_finished", "callable": _on_global_manager_loading_finished },
	{ "name": &"reading_finished", "callable": _on_global_manager_reading_finished },
	{ "name": &"removing_finished", "callable": _on_global_manager_removing_finished },
]

#endregion

#region Setters & Getters

func set_global_manager(new_manager: LokStorageManager) -> void:
	var old_manager: LokStorageManager = global_manager
	
	global_manager = new_manager
	
	if old_manager == new_manager:
		return
	
	LokUtil.check_and_disconnect_signals(
		old_manager,
		global_manager_connections
	)
	LokUtil.check_and_connect_signals(
		new_manager,
		global_manager_connections
	)

func get_global_manager() -> LokStorageManager:
	return global_manager

#endregion

#region Debug methods

## The [method push_error_no_manager] method pushes an error indicating
## that no [LokGlobalStorageManager] was found in the [member global_manager]
## property, which shouldn't happen if that property wasn't altered, as
## recommended in its description.
func push_error_no_manager() -> void:
	push_error("No GlobalManager found in %s" % get_readable_name())

#endregion

#region Methods

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
	file_id: String = current_file,
	version_number: String = current_version,
	included_accessors: Array[LokStorageAccessor] = [],
	replace: bool = false
) -> Dictionary:
	if global_manager == null:
		push_error_no_manager()
		return {}
	
	return await global_manager.save_data(
		file_id,
		version_number,
		included_accessors,
		replace
	)

## The [method load_data] method uses the
## [method LokGlobalStorageManager.load_data] method to load the
## previously saved data into the currently registered [LokStorageAccessor]s
## of the game.[br]
## This method has as its only mandatory parameter the [param file_id]
## that determines from what file the game should be loaded.[br]
## The [param accessor_ids] parameter specifies which of the
## currently registered [LokStorageAccessor]s should receive the loaded data.
## If left as an empty [Array], all current [LokStorageAccessor]s
## receive the data.[br]
## The [param partition_ids] and [param version_numbers] parameters work
## in a similar way, restricting what [b]partitions[/b] and [b]versions[/b]
## should be considered when loading.
## At the end, this method returns a [Dictionary] with the information obtained.
## [i]See also: [method LokGlobalStorageManager.load_data][/i]
func load_data(
	file_id: String = current_file,
	included_accessors: Array[LokStorageAccessor] = [],
	partition_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	if global_manager == null:
		push_error_no_manager()
		return {}
	
	return await global_manager.load_data(
		file_id,
		included_accessors,
		partition_ids,
		version_numbers
	)

## The [method read_data] method is an intermediate to calling the same method
## in the [LokGlobalStorageManager] autoload. More information about it
## can be found here: [member LokGlobalStorageManager.read_data].
func read_data(
	file_id: String = current_file,
	included_accessors: Array[LokStorageAccessor] = [],
	partition_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	if global_manager == null:
		push_error_no_manager()
		return {}
	
	return await global_manager.read_data(
		file_id,
		included_accessors,
		partition_ids,
		version_numbers
	)

## The [method remove_data] method is an intermediate to calling the same method
## in the [LokGlobalStorageManager] autoload. More information about it
## can be found here: [member LokGlobalStorageManager.remove_data].
func remove_data(
	file_id: String = current_file,
	included_accessors: Array[LokStorageAccessor] = [],
	partition_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	if global_manager == null:
		push_error_no_manager()
		return {}
	
	return await global_manager.remove_data(
		file_id,
		included_accessors,
		partition_ids,
		version_numbers
	)

func _init() -> void:
	global_manager = LokGlobalStorageManager

func _on_global_manager_operation_started(operation_name: StringName) -> void:
	operation_started.emit(operation_name)

func _on_global_manager_saving_started() -> void:
	saving_started.emit()

func _on_global_manager_loading_started() -> void:
	loading_started.emit()

func _on_global_manager_reading_started() -> void:
	reading_started.emit()

func _on_global_manager_removing_started() -> void:
	removing_started.emit()

func _on_global_manager_operation_finished(
	result: Dictionary, operation: StringName
) -> void:
	operation_finished.emit(result, operation)

func _on_global_manager_saving_finished(result: Dictionary) -> void:
	saving_finished.emit(result)

func _on_global_manager_loading_finished(result: Dictionary) -> void:
	loading_finished.emit(result)

func _on_global_manager_reading_finished(result: Dictionary) -> void:
	reading_finished.emit(result)

func _on_global_manager_removing_finished(result: Dictionary) -> void:
	removing_finished.emit(result)

#endregion
