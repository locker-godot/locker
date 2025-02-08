@icon("res://addons/locker/icons/storage_loader.svg")
@tool
## The [LokStorageLoader] is a node specialized in loading data.
## 
## This class extends the [LokStorageAccessor], but limits its
## functionalities to only loading data, for cases where the user
## wants to be sure this class won't be able to save data. [br]
## All the other behavior of this class is pretty much the same as the
## [LokStorageAccessor]'s, so see that class' documentation to
## know more about it. [br]
## [br]
## [b]Version[/b]: 1.0.0[br]
## [b]Author[/b]: [url]github.com/nadjiel[/url]
class_name LokStorageLoader
extends LokStorageAccessor

## The [method push_error_tried_saving_with_loader] method pushes
## an error saying that a saving operation was tried in this
## [LokStorageLoader], which is forbidden.
func push_error_tried_saving_with_loader() -> void:
	push_error(
		"Tried saving data using the StorageLoader '%s'" % get_readable_name()
	)

## The [method save_data] method is overridden by this [LokStorageLoader]
## in order to make it unable to save data. [br]
## If it is attempted to call it, an error is pushed.
func save_data(
	file_id: String,
	version_number: String = ""
) -> Dictionary:
	push_error_tried_saving_with_loader()
	
	return {}

## The [method retrieve_data] method is overriden by this [LokStorageLoader]
## in order to make it unable to retrieve data. [br]
## That means when called, this method just returns an empty [Dictionary].
func retrieve_data() -> Dictionary:
	return {}
