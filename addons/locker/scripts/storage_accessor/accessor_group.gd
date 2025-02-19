@icon("res://addons/locker/icons/accessor_group.svg")
## The [LokAccessorGroup] represents a collection of [LokStorageAccessor]s.
## 
## This class is the uppermost in the [LokStorageManager] hierarchy since
## it represents a general collection of [LokStorageAccessor]s. [br]
## Besides being able to group [member accessors] together, this class
## allows performing group operations, which trigger each [member accessors]
## operations one after the other, and emits handy signals to know when
## the group operations started and finished. [br]
## This is useful when it's wanted to perform multiple operations on different
## save files, which can be indicated individually by each [LokStorageAccessor].
## [br][br]
## [b]Version[/b]: 1.0.0 [br]
## [b]Author[/b]: Daniel Sousa ([url]github.com/nadjiel[/url])
class_name LokAccessorGroup
extends Node

## The [signal group_saving_started] signal is emitted when a group of save
## operations was started by this [LokAccessorGroup].
signal group_saving_started()

## The [signal group_loading_started] signal is emitted when a group of load
## operations was started by this [LokAccessorGroup].
signal group_loading_started()

## The [signal group_removing_started] signal is emitted when a group of remove
## operations was started by this [LokAccessorGroup].
signal group_removing_started()

## The [signal group_saving_finished] signal is emitted when a group of save
## operations was finished by this [LokAccessorGroup].
signal group_saving_finished()

## The [signal group_loading_finished] signal is emitted when a group of load
## operations was finished by this [LokAccessorGroup].
signal group_loading_finished()

## The [signal group_removing_finished] signal is emitted when a group of remove
## operations was finished by this [LokAccessorGroup].
signal group_removing_finished()

## The [member current_version] property is used as the version with which
## data is saved when using this [LokAccessorGroup]. [br]
## By default, it is set to an empty [String], which is converted to the
## latest available version.
@export var current_version: String = "":
	set = set_current_version,
	get = get_current_version

## The [member accessors] property is an [Array] responsible for storing all the
## [LokStorageAccessor]s interesting to this [LokAccessorGroup].
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
## it can have its data manipulated together with the other ones.
func add_accessor(accessor: LokStorageAccessor) -> bool:
	accessors.append(accessor)
	
	return true

## The [method remove_accessor] method is responsible for removing a
## [LokStorageAccessor] from the [member accessors] list, so that
## it doesn't have its data manipulated by this [LokAccessorGroup] anymore.
func remove_accessor(accessor: LokStorageAccessor) -> bool:
	var accessor_index: int = accessors.find(accessor)
	
	if accessor_index == -1:
		return false
	
	accessors.remove_at(accessor_index)
	
	return true

## The [method save_accessor_group] method is responsible for performing
## one save operation for each of the [member accessors] in this
## [LokAccessorGroup]. [br]
## The start and finish of this group of operations is notified via the
## [signal group_saving_started] and [signal group_saving_finished] signals.
## [br]
## If it's wanted, a [param version_number] can be passed to dictate what
## version to use in this operation. In case none is provided, the
## [member current_version] is used.
func save_accessor_group(version_number: String = current_version) -> void:
	if accessors.is_empty():
		return
	
	group_saving_started.emit()
	
	for accessor: LokStorageAccessor in accessors:
		if not accessor.is_active():
			continue
		
		await accessor.save_data("", version_number)
	
	group_saving_finished.emit()

## The [method load_accessor_group] method is responsible for performing
## one load operation for each of the [member accessors] in this
## [LokAccessorGroup]. [br]
## The start and finish of this group of operations is notified via the
## [signal group_loading_started] and [signal group_loading_finished] signals.
func load_accessor_group() -> void:
	if accessors.is_empty():
		return
	
	group_loading_started.emit()
	
	for accessor: LokStorageAccessor in accessors:
		if not accessor.is_active():
			continue
		
		await accessor.load_data("")
	
	group_loading_finished.emit()

## The [method remove_accessor_group] method is responsible for performing
## one remove operation for each of the [member accessors] in this
## [LokAccessorGroup]. [br]
## The start and finish of this group of operations is notified via the
## [signal group_removing_started] and [signal group_removing_finished] signals.
func remove_accessor_group() -> void:
	if accessors.is_empty():
		return
	
	group_removing_started.emit()
	
	for accessor: LokStorageAccessor in accessors:
		if not accessor.is_active():
			continue
		
		await accessor.remove_data("")
	
	group_removing_finished.emit()
