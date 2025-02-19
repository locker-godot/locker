## The [LokSceneStorageManager] class can be communicate with the
## [LokGlobalStorageManager] Singleton.
## 
## This class is useful when it is desired to trigger the
## [LokGlobalStorageManager] methods through signal emissions
## in the scene tree using the inspector, for example. [br]
## Also, this class can be used to perform certain operations including only
## some nodes of the current scene. [br]
## [br]
## [b]Version[/b]: 1.0.0[br]
## [b]Author[/b]: [url]github.com/nadjiel[/url]
class_name LokSceneStorageManager
extends LokStorageManager

#region Properties

## The [member global_manager] property should not be altered since it's just
## a reference to the [LokGlobalStorageManager] autoload. [br]
## Its reference is stored here instead of called directly to make
## mocking it with unit testing easier.
var global_manager: LokStorageManager = LokGlobalStorageManager:
	set = set_global_manager,
	get = get_global_manager

#endregion

#region Setters & Getters

func set_global_manager(new_manager: LokStorageManager) -> void:
	global_manager = new_manager

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

## The [method save_data] method is an intermidiate to calling the
## [method LokGlobalStorageManager.save_data] method. [br]
## Using this method, though, only the [member LokAccessorGroup.accessors] of
## this [LokSceneStorageManager] are included in the saving process, by default.
## [br]
## To read more about the parameters and return of this method, see
## the [method LokStorageManager.save_data] description. [br]
## The start and finish of this operation is notified via the
## [signal LokStorageManager.saving_started] and
## [signal LokStorageManager.saving_finished] signals.
func save_data(
	file_id: String = current_file,
	version_number: String = current_version,
	included_accessors: Array[LokStorageAccessor] = accessors,
	replace: bool = false
) -> Dictionary:
	if global_manager == null:
		push_error_no_manager()
		return {}
	
	saving_started.emit()
	
	var result: Dictionary = await global_manager.save_data(
		file_id,
		version_number,
		included_accessors,
		replace
	)
	
	saving_finished.emit(result)
	
	return result

## The [method load_data] method is an intermidiate to calling the
## [method LokGlobalStorageManager.load_data] method. [br]
## Using this method, though, only the [member LokAccessorGroup.accessors] of
## this [LokSceneStorageManager] are included in the loading process,
## by default. [br]
## To read more about the parameters and return of this method, see
## the [method LokStorageManager.load_data] description. [br]
## The start and finish of this operation is notified via the
## [signal LokStorageManager.loading_started] and
## [signal LokStorageManager.loading_finished] signals.
func load_data(
	file_id: String = current_file,
	included_accessors: Array[LokStorageAccessor] = accessors,
	partition_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	if global_manager == null:
		push_error_no_manager()
		return {}
	
	loading_started.emit()
	
	var result: Dictionary = await global_manager.load_data(
		file_id,
		included_accessors,
		partition_ids,
		version_numbers
	)
	
	loading_finished.emit(result)
	
	return result

## The [method read_data] method is an intermidiate to calling the
## [method LokGlobalStorageManager.read_data] method. [br]
## Using this method, though, only the [member LokAccessorGroup.accessors] of
## this [LokSceneStorageManager] are included in the reading process,
## by default. [br]
## To read more about the parameters and return of this method, see
## the [method LokStorageManager.read_data] description. [br]
## The start and finish of this operation is notified via the
## [signal LokStorageManager.reading_started] and
## [signal LokStorageManager.reading_finished] signals.
func read_data(
	file_id: String = current_file,
	included_accessors: Array[LokStorageAccessor] = accessors,
	partition_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	if global_manager == null:
		push_error_no_manager()
		return {}
	
	reading_started.emit()
	
	var result: Dictionary = await global_manager.read_data(
		file_id,
		included_accessors,
		partition_ids,
		version_numbers
	)
	
	reading_finished.emit(result)
	
	return result

## The [method remove_data] method is an intermidiate to calling the
## [method LokGlobalStorageManager.remove_data] method. [br]
## Using this method, though, only the [member LokAccessorGroup.accessors] of
## this [LokSceneStorageManager] are included in the removing process,
## by default. [br]
## To read more about the parameters and return of this method, see
## the [method LokStorageManager.remove_data] description. [br]
## The start and finish of this operation is notified via the
## [signal LokStorageManager.removing_started] and
## [signal LokStorageManager.removing_finished] signals.
func remove_data(
	file_id: String = current_file,
	included_accessors: Array[LokStorageAccessor] = accessors,
	partition_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary:
	if global_manager == null:
		push_error_no_manager()
		return {}
	
	removing_started.emit()
	
	var result: Dictionary = await global_manager.remove_data(
		file_id,
		included_accessors,
		partition_ids,
		version_numbers
	)
	
	removing_finished.emit(result)
	
	return result

#endregion
