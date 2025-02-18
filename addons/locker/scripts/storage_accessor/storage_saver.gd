@icon("res://addons/locker/icons/storage_saver.svg")
@tool
## The [LokStorageSaver] is a node specialized in saving data.
## 
## This class extends the [LokStorageAccessor], but limits its
## functionalities to only saving data, for cases where the user
## wants to be sure this class won't be able to load data. [br]
## All the other behavior of this class is pretty much the same as the
## [LokStorageAccessor]'s, so see that class' documentation to
## know more about it. [br]
## [br]
## [b]Version[/b]: 1.0.0[br]
## [b]Author[/b]: [url]github.com/nadjiel[/url]
class_name LokStorageSaver
extends LokStorageAccessor

## The [method push_error_tried_loading_with_saver] method pushes
## an error saying that a loading operation was tried in this
## [LokStorageSaver], which is forbidden.
func push_error_tried_loading_with_saver() -> void:
	push_error(
		"Tried loading data using the StorageSaver '%s'" % get_readable_name()
	)

## The [method load_data] method is overridden by this [LokStorageSaver]
## in order to make it unable to load data. [br]
## If it is attempted to call it, an error is pushed.
func load_data(file_id: String = file) -> Dictionary:
	push_error_tried_loading_with_saver()
	
	return {}

## The [method consume_data] method is overriden by this [LokStorageSaver]
## in order to make it unable to consume data. [br]
## That means when called, this method does nothing.
func consume_data(_data: Dictionary) -> void:
	pass
