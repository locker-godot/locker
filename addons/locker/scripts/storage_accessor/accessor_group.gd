
class_name LokAccessorGroup
extends Node

signal group_saving_started()

signal group_loading_started()

signal group_removing_started()

signal group_saving_finished()

signal group_loading_finished()

signal group_removing_finished()

## The [member current_version] property is used as the version with which
## data is saved when using this [LokSceneStorageManager]. [br]
## By default, it is set to [code]""[/code], which is converted to the
## latest available version.
@export var current_version: String = "":
	set = set_current_version,
	get = get_current_version

## The [member accessors] property is an [Array] responsible for storing all the
## [LokStorageAccessor]s that are currently in the scene tree. [br]
## This [Array] shouldn't be manipulated directly, given that the
## [LokStorageAccessor]s are automatically added and removed from it
## on entering and exiting the tree.
@export var accessors: Array[LokStorageAccessor] = []:
	set = set_accessors,
	get = get_accessors

func set_current_version(new_version: String) -> void:
	current_version = new_version

func get_current_version() -> String:
	return current_version

func set_accessors(new_accessors: Array[LokStorageAccessor]) -> void:
	accessors = new_accessors

func get_accessors() -> Array[LokStorageAccessor]:
	return accessors

## The [method add_accessor] method is responsible for adding a new
## [LokStorageAccessor] to the [member accessors] list, so that
## it can have its data saved and loaded together with the other ones. [br]
## This method is called automatically by [LokStorageAccessor]s when they
## enter the scene tree, so there's no need to use it yourself.
func add_accessor(accessor: LokStorageAccessor) -> bool:
	accessors.append(accessor)
	
	return true

## The [method remove_accessor] method is responsible for removing a
## [LokStorageAccessor] from the [member accessors] list, so that
## it doesn't have its data saved and loaded anymore. [br]
## This makes sense when such [LokStorageAccessor] exits from the tree,
## and hence doesn't have the ability to do anything with the data. [br]
## This method is called automatically by [LokStorageAccessor]s when they
## exit the scene tree, so there's no need to use it yourself.
func remove_accessor(accessor: LokStorageAccessor) -> bool:
	var accessor_index: int = accessors.find(accessor)
	
	if accessor_index == -1:
		return false
	
	accessors.remove_at(accessor_index)
	
	return true

func save_accessor_group(version_number: String = current_version) -> void:
	if accessors.is_empty():
		return
	
	group_saving_started.emit()
	
	for accessor: LokStorageAccessor in accessors:
		if not accessor.is_active():
			continue
		
		await accessor.save_data("", version_number)
	
	group_saving_finished.emit()

func load_accessor_group() -> void:
	if accessors.is_empty():
		return
	
	group_loading_started.emit()
	
	for accessor: LokStorageAccessor in accessors:
		if not accessor.is_active():
			continue
		
		await accessor.load_data("")
	
	group_loading_finished.emit()

func remove_accessor_group() -> void:
	if accessors.is_empty():
		return
	
	group_removing_started.emit()
	
	for accessor: LokStorageAccessor in accessors:
		if not accessor.is_active():
			continue
		
		await accessor.remove_data("")
	
	group_removing_finished.emit()
