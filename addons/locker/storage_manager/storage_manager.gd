## The [LokStorageManager] is the super class of the [LokGlobalStorageManager]
## and [LokSceneStorageManager] classes.
## 
## This super class serves as an interface for the [method save_data],
## [method load_data] and [method remove_data] methods,
## so that its sub classes can override them.
class_name LokStorageManager
extends Node

## The [method default_remover] is a static method that is used as the default
## [param remover] parameter in the [method remove_data] method. [br]
## As expected by that parameter, this method receives a [param data_id] and
## a [param version_number]. [br]
## As of its implementation, this method simply returns [code]false[/code],
## indicating that no data should be removed.
static func default_remover(
	data_id: String, version_number: String
) -> bool: return false

## The [method save_data] method should work as the main way of saving the
## game, gathering together information from all active [LokStorageAccessor]s
## and saving them in a desired file. [br]
## The only mandatory parameter of this method is the [param file_id]
## that should determine in what file the game should be saved. [br]
## The [param version_number] parameter is supposed to specify what version
## of the registered [LokStorageAccessor]s should be used to save the game.
## By default, it is set to [code]"1.0.0"[/code], which is the initial version
## when [LokStorageAccessor]s are created. [br]
## The [param accessor_ids] parameter is an [Array] that represents what
## is the subset of [LokStorageAccessor]s that should be involved in this
## saving process. If left empty, as default, it means that all
## [LokStorageAccessor]s currently registered would have their informations
## saved. [br]
## The [param replace] parameter is a flag that tells whether the previous
## data saved, if any, should be completly overwritten by the new one.
## It's not recommended setting this flag to [code]true[/code] since
## [LokStorageAccessor]s from unloaded scenes may need that overwritten data.
## This flag should only be used if you know the previous data and
## are sure you want to delete it. [br]
## At the end, this method should return the data that was saved via
## a [Dictionary].
func save_data(
	file_id: int,
	version_number: String = "1.0.0",
	accessor_ids: Array[String] = [],
	replace: bool = false,
	remover: Callable = default_remover
) -> Dictionary: return {}

## The [method load_data] method should work as the main way of loading the
## game, getting the information from a desired file and
## distributing it to all active [LokStorageAccessor]s. [br]
## The only mandatory parameter of this method is the [param file_id]
## that should determine from what file the game should be loaded. [br]
## Besides that, there's the [param accessor_ids] parameter
## which is an [Array] that represents what
## is the subset of [LokStorageAccessor]s that should receive the
## data obtained in this loading process.
## If left empty, as default, it means that all
## [LokStorageAccessor]s currently registered would
## receive the information. [br]
## When finished, this method should return the data it gathered loading the
## save file in a [Dictionary].
func load_data(
	file_id: int,
	accessor_ids: Array[String] = []
) -> Dictionary: return {}

## The [method remove_data] method should serve as the main way of removing
## data previously saved in this game. [br]
## It's only mandatory parameter is the [param file_id],
## which should specify from what file the data should be removed. [br]
## If it's wanted to delete just some of the data, the [param remover]
## parameter can be passed a [Callable] to control
## which data should be removed. [br]
## In order to do that, this [Callable] should receive two [String]s:
## one representing the [param data_id] and other representing the
## [param version_number] with which that data was saved. [br]
## Finally, this [Callable] should return a
## [code]bool[/code], with [code]true[/code] meaning a data should be removed
## and [code]false[/code] meaning it shouldn't.
func remove_data(
	file_id: int,
	remover: Callable = default_remover
) -> Dictionary: return {}
