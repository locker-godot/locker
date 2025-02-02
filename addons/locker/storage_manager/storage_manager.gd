## The [LokStorageManager] is the super class of the [LokGlobalStorageManager]
## and [LokSceneStorageManager] classes.
## 
## This super class defines the signature of the [method save_data] and
## [method load_data] methods, so that its sub classes can override them.
class_name LokStorageManager
extends Node

func save_data(file_id: int) -> bool: return false

func load_data(file_id: int) -> bool: return false
