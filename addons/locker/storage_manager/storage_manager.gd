@icon("res://addons/locker/icons/storage_manager.svg")
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
extends Node

## The [method default_remover] is a static method that is used as the default
## [param remover] parameter in the [method remove_data] method. [br]
## As expected by that parameter, this method receives an [param accessor_id],
## a [param partition_id] and a [param version_number]. [br]
## As of its implementation, this method simply returns [code]false[/code],
## indicating that no data should be removed.
static func default_remover(
	accessor_id: String,
	partition_id: String,
	version_number: String
) -> bool: return false

## The [method save_data] method should work as the main way of saving the
## game, gathering together information from all active [LokStorageAccessor]s
## and saving them in a desired file. [br]
## The only mandatory parameter of this method is the [param file_id]
## that should determine in what file the game should be saved. [br]
## The [param version_number] parameter is supposed to specify what version
## of the registered [LokStorageAccessor]s should be used to save the game.
## By default, it is set to [code]""[/code], which converts to the latest
## version available. [br]
## The [param accessor_ids] parameter is an [Array] that represents what
## is the subset of [LokStorageAccessor]s that should be involved in this
## saving process. If left empty, as default, it means that all
## [LokStorageAccessor]s currently registered would have their informations
## saved. [br]
## The [param replace] parameter is a flag that tells whether the previous
## data saved, if any, should be overwritten by the new one.
## It's not recommended setting this flag to [code]true[/code] since
## [LokStorageAccessor]s from unloaded scenes may need that overwritten data.
## This flag should only be used if you know the previous data and
## are sure you want to delete it. [br]
## At the end, this method should return the data that was saved via
## a [Dictionary].
func save_data(
	file_id: String,
	version_number: String = "",
	accessor_ids: Array[String] = [],
	replace: bool = false
) -> Dictionary: return {}

## The [method load_data] method should work as the main way of loading the
## game, getting the information from a desired file and
## distributing it to all active [LokStorageAccessor]s. [br]
## The only mandatory parameter of this method is the [param file_id]
## that should determine from what file the game should be loaded. [br]
## Besides that, there's the [param accessor_ids] parameter
## which is an [Array] that represents what
## is the subset of [LokStorageAccessor]s that should receive the
## data obtained in this loading process. [br]
## To provide yet more control over what data is loaded, the
## [param partition_ids] and [param version_numbers] parameters can be passed,
## serving to filter what information is applied in the game. [br]
## If you have sure about in what partitions is the data you want to load,
## passing their [param partition_ids] is more efficient since the loading
## only needs to check those partitions. [br]
## If the optional parameters are left empty, as default, it means that all
## [param accessor_ids], [param partition_ids] and [param version_numbers]
## are used when loading. [br]
## When finished, this method should return the data it gathered loading the
## save file in a [Dictionary].
func load_data(
	file_id: String,
	accessor_ids: Array[String] = [],
	partition_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary: return {}

## The [method read_data] method is the main way of loading the game data
## from a file without distributing it to the corresponding
## [LokStorageAccessor]s. [br]
## The only mandatory parameter of this method is the [param file_id],
## that should determine from what file the data should be read. [br]
## Besides that, there's the [param accessor_ids], [param partition_ids]
## and [param version_numbers] parameters, which respectively serve to filter
## the [b]data id[/b], [b]partition id[/b], and [b]version number[/b]
## of the data obtained. ([i]See [member LokStorageAccessor.id],
## [member LokStorageAccessor.partition] and
## [member LokStorageAccessorVersion.number][/i]) [br]
## On finish, this method should return the data read filtered by the passed
## parameters in a [Dictionary].
func read_data(
	file_id: String,
	accessor_ids: Array[String] = [],
	partition_ids: Array[String] = [],
	version_numbers: Array[String] = []
) -> Dictionary: return {}

## The [method remove_data] method should serve as the main way of removing
## data previously saved in this game. [br]
## It's only mandatory parameter is the [param file_id],
## which should specify from what file the data should be removed. [br]
## If it's wanted to delete just some of the data, the [param remover]
## parameter can be passed a [Callable] to control
## which data should be removed. [br]
## In order to do that, this [Callable] should receive three [String]s:
## one representing the [param accessor_id], other representing the
## [param partition_id] and the other representing the
## [param version_number] with which that data was saved. [br]
## Finally, this [Callable] should return a
## [code]bool[/code], with [code]true[/code] meaning a data should be removed
## and [code]false[/code] meaning it shouldn't. [br]
## [i]See [method default_remover] if you want a concrete example of how
## should be the signature of the [param remover][/i].
func remove_data(
	file_id: String,
	remover: Callable = default_remover
) -> Dictionary: return {}
