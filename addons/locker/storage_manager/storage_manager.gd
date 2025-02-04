## The [LokStorageManager] is the super class of the [LokGlobalStorageManager]
## and [LokSceneStorageManager] classes.
## 
## This super class defines the signature of the [method save_data] and
## [method load_data] methods, so that its sub classes can override them.
class_name LokStorageManager
extends Node

func save_data(
	file_id: int,
	version_number: String = "1.0.0",
	accessor_ids: Array[String] = [],
	remove_version: Callable = func(number: String) -> bool: return false
) -> Dictionary: return {}

func load_data(
	file_id: int,
	accessor_ids: Array[String] = []
) -> Dictionary: return {}
