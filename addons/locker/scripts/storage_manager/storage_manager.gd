## The [LokStorageManager] is the super class of the [LokGlobalStorageManager]
## and [LokSceneStorageManager] classes.
## 
## This super class serves as an interface for the [method save_data],
## [method load_data], [method read_data] and [method remove_data] methods,
## so that its sub classes can override them. [br]
## [br]
## [b]Version[/b]: 1.0.0[br]
## [b]Author[/b]: [url]github.com/nadjiel[/url]
class_name LokStorageManager
extends LokAccessorGroup

#region Signals

## The [signal saving_started] signal is emitted when a save
## operation was started by this [LokStorageManager].
signal saving_started()

## The [signal loading_started] signal is emitted when a load
## operation was started by this [LokStorageManager].
signal loading_started()

## The [signal reading_started] signal is emitted when a read
## operation was started by this [LokStorageManager].
signal reading_started()

## The [signal removing_started] signal is emitted when a remove
## operation was started by this [LokStorageManager].
signal removing_started()

## The [signal saving_finished] signal is emitted when a save
## operation was finished by this [LokStorageManager]. [br]
## This signal brings a [Dictionary] representing the result of the operation.
## This [Dictionary] has a [code]"status"[/code] key, with a
## [enum @GlobalScope.Error] code and a [code]"data"[/code] key, with the data
## saved.
signal saving_finished(result: Dictionary)

## The [signal loading_finished] signal is emitted when a load
## operation was finished by this [LokStorageManager]. [br]
## This signal brings a [Dictionary] representing the result of the operation.
## This [Dictionary] has a [code]"status"[/code] key, with a
## [enum @GlobalScope.Error] code and a [code]"data"[/code] key, with the data
## loaded.
signal loading_finished(result: Dictionary)

## The [signal reading_finished] signal is emitted when a read
## operation was finished by this [LokStorageManager]. [br]
## This signal brings a [Dictionary] representing the result of the operation.
## This [Dictionary] has a [code]"status"[/code] key, with a
## [enum @GlobalScope.Error] code and a [code]"data"[/code] key, with the data
## readed.
signal reading_finished(result: Dictionary)

## The [signal removing_finished] signal is emitted when a remove
## operation was finished by this [LokStorageManager]. [br]
## This signal brings a [Dictionary] representing the result of the operation.
## This [Dictionary] has a [code]"status"[/code] key, with a
## [enum @GlobalScope.Error] code and a [code]"data"[/code] key, with the data
## removed.
signal removing_finished(result: Dictionary)

#endregion

#region Properties

## The [member current_file] property stores the id of the default file
## to be used when performing operations with this [LokStorageManager].
@export var current_file: String = "":
	set = set_current_file,
	get = get_current_file

#endregion

#region Setters & Getters

func set_current_file(new_file: String) -> void:
	current_file = new_file

func get_current_file() -> String:
	return current_file

#endregion

#region Debug Methods

## The [method get_readable_name] method is a utility for debugging. [br]
## It returns a more user friendly name for this node, so that errors
## can use it to be clearer.
func get_readable_name() -> String:
	if is_inside_tree():
		return str(get_path())
	if name != "":
		return name
	
	return str(self)

#endregion

#region Methods

## The [method save_data] method should save the information from all active
## [member LokAccessorGroup.accessors] of this [LokStorageManager]
## in a desired file. [br]
## This method receives several parameters to customize that process. [br]
## The [param file_id] should determine in what file the game should be saved.
## This id defaults to the one set in the [member current_file] property. [br]
## The [param version_number] parameter is supposed to specify what version
## of the registered [LokStorageAccessor]s should be used to save the game.
## By default, it is set to the [member LokAccessorGroup.current_version],
## which converts to the latest version available. [br]
## The [param included_accessors] parameter is an [Array] that represents what
## is the subset of [LokStorageAccessor]s that should be involved in this
## saving process. If left empty, as default, it would mean that all
## [LokStorageAccessor]s currently registered would have their informations
## saved. [br]
## The [param replace] parameter is a flag that tells whether the previous
## data saved, if any, should be overwritten by the new one.
## It's not recommended setting this flag to [code]true[/code] since
## [LokStorageAccessor]s not included in the saving may need that
## overwritten data later on.
## This flag should only be used if you know the previous data and
## are sure you want to delete it. [br]
## At the end, this method should return the result of the saving via
## a [Dictionary] with a [code]"status"[/code] key specifying a
## [enum @GlobalScope.Error] code, and a [code]"data"[/code] key
## storing all data saved. [br]
## The start and finish of this operation should be notified via the
## [signal saving_started] and [signal saving_finished] signals.
func save_data(
	file_id: String = current_file,
	version_number: String = current_version,
	included_accessors: Array[LokStorageAccessor] = [],
	replace: bool = false
) -> Dictionary: return {}

## The [method load_data] method should load the information from all active
## [member LokAccessorGroup.accessors] of this [LokStorageManager]
## from a desired file and further distribute it to them, so they
## can use it with their [method LokStorageAccessor.consume_data] method. [br]
## This method receives several parameters to customize that process. [br]
## The [param file_id] should determine from what file the game should be
## loaded.
## This id defaults to the one set in the [member current_file] property. [br]
## Besides that, the [param included_accessors] parameter is an [Array] that
## represents what is the subset of [LokStorageAccessor]s that should be
## involved in this loading process.
## If left empty, as default, it would mean that all
## [LokStorageAccessor]s currently registered would have their informations
## loaded. [br]
## To provide yet more control over what data is loaded, the
## [param partition_ids] and [param version_numbers] parameters can be passed,
## serving to filter what information should be applied to the game. [br]
## If you have sure about in what partitions is the data you want to load,
## passing their [param partition_ids] is more efficient since the loading
## only needs to check those partitions. [br]
## If the optional parameters are left empty, as default, it means that all
## [param included_accessors], [param partition_ids] and [param version_numbers]
## are used when loading. [br]
## At the end, this method should return the result of the loading via
## a [Dictionary] with a [code]"status"[/code] key specifying a
## [enum @GlobalScope.Error] code, and a [code]"data"[/code] key
## storing all data loaded. [br]
## The start and finish of this operation should be notified via the
## [signal loading_started] and [signal loading_finished] signals.
func load_data(
	file_id: String = current_file,
	included_accessors: Array[LokStorageAccessor] = [],
	partition_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary: return {}

## The [method read_data] method should read the information from
## a desired file, like the [method load_data] method,
## but not distribute that data to its respective [LokStorageAccessor]s. [br]
## Excluding that small difference, this method is basically the same as the
## [method load_data] method, but more inclined for possibilitating saved data
## analysis without necessarily applying it to the game. [br]
## To read more about the parameters and return of this method, see the
## [method load_data] method. [br]
## The start and finish of this operation should be notified via the
## [signal reading_started] and [signal reading_finished] signals.
func read_data(
	file_id: String = current_file,
	included_accessors: Array[LokStorageAccessor] = [],
	partition_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary: return {}

## The [method remove_data] method should remove the information from a
## desired file of specified by the [param file_id] parameter. [br]
## By default, that [param file_id] is set to the
## [member current_file] property. [br]
## The [param included_accessors], [param partition_ids] and
## [param version_numbers] parameters can be used to filter what should be
## removed, if it's not desired to remove the entire file. [br]
## To read more about those parameters, see the [method load_data] method,
## which uses them as filters in the same way. [br]
## At the end, this method should return the result of the removing via
## a [Dictionary] with a [code]"status"[/code] key specifying a
## [enum @GlobalScope.Error] code, a [code]"data"[/code] key
## storing all data removed, and an [code]"updated_data"[/code] key
## storing all data kept. [br]
## The start and finish of this operation should be notified via the
## [signal removing_started] and [signal removing_finished] signals.
func remove_data(
	file_id: String = current_file,
	included_accessors: Array[LokStorageAccessor] = [],
	partition_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary: return {}

#endregion
