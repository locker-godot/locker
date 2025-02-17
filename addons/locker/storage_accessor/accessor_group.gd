
class_name LokAccessorGroup
extends Node

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

## The [method get_accessors_by_id] method looks through all currently
## registered [LokStorageAccessor]s and returns the ones that match the
## [param id] passed.
func get_accessors_by_id(id: String) -> Array[LokStorageAccessor]:
	var result: Array[LokStorageAccessor] = []
	
	for accessor: LokStorageAccessor in accessors:
		if accessor.id == id:
			result.append(accessor)
	
	return result

## The [method get_accessor_by_id] method looks through all currently
## registered [LokStorageAccessor]s and returns the first one that matches the
## [param id] passed.
func get_accessor_by_id(id: String) -> LokStorageAccessor:
	for accessor: LokStorageAccessor in accessors:
		if accessor.id == id:
			return accessor
	
	return null

func save_data_per_accessor(version_number: String = current_version) -> void:
	for accessor: LokStorageAccessor in accessors:
		if not accessor.is_active():
			continue
		
		await accessor.save_data("", version_number)

func load_data_per_accessor() -> void:
	for accessor: LokStorageAccessor in accessors:
		if not accessor.is_active():
			continue
		
		await accessor.load_data()

func remove_data_per_accessor() -> void:
	for accessor: LokStorageAccessor in accessors:
		if not accessor.is_active():
			continue
		
		await accessor.remove_data()
