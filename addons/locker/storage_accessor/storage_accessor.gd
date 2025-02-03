@tool
## The [LokStorageAccessor] is a node specialized in saving and loading data.
## 
## This class should have its [method save_data] and [method load_data] methods
## overwritten in order for them to respectively save and load data. [br]
## Those methods are called by the [LokGlobalStorageManager] in order to get
## or retrieve data from save files.
## [br]
## [b][color=orange]WARNING:[/color][/b]
## In order for that to happen, the [LokGlobalStorageManager] has to keep
## track of this node. That's achievable because this [LokStorageAccessor]
## adds and removes itself from the [LokGlobalStorageManager] on entering and
## on exiting the node tree using the [method _enter_tree]
## and [method _exit_tree] methods. [br]
## That means these methods, if overriden, must have their super implementations
## called in order for this node to work properly.
class_name LokStorageAccessor
extends Node

signal id_changed(from: String, to: String)

@export var id: String:
	set = set_id

func set_id(new_id: String) -> void:
	var old_id: String = id
	
	id = new_id
	
	if new_id != old_id:
		id_changed.emit(old_id, new_id)
		
		update_configuration_warnings()

func _enter_tree() -> void:
	LokGlobalStorageManager.add_accessor(self)

func _exit_tree() -> void:
	LokGlobalStorageManager.remove_accessor(self)

func save_data() -> Dictionary: return {}

func load_data(_data: Dictionary) -> void: pass

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if id == "":
		warnings.append("To work properly, you must set a unique id to this Storage Accessor.")
	
	return warnings
