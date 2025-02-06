@icon("res://addons/locker/icons/access_strategy.svg")
## The [LokAccessStrategy] super class is responsible for
## defining how the writing and reading from a file should be performed.
## 
## This class should be extended in order to provide concrete implementations.
## [br]
## [b]Version[/b]: 1.0.0[br]
## [b]Author[/b]: [url]github.com/nadjiel[/url]
class_name LokAccessStrategy
extends Resource

## The [method create_directory] method creates a new directory in the
## path specified by the [param path] parameter. [br]
## If an error occurs, this method pushes it and returns [code]false[/code],
## otherwise, it returns [code]true[/code].
static func create_directory(path: String) -> bool:
	var err: Error = DirAccess.make_dir_recursive_absolute(path)
	
	if err != OK:
		push_error("Unable to create directory: '%s'" % path)
		
		return false
	
	return true

## The [method check_directory] method checks if a directory exists in the
## path specified by the [param path] parameter. [br]
## If the directory doesn't exist, this method pushes an error and returns
## [code]false[/code], otherwise, it returns [code]true[/code]. [br]
## If the [param suppress_error] is [code]true[/code], though,
## no errors are, thrown.
static func check_directory(
	path: String, suppress_error: bool = false
) -> bool:
	if not DirAccess.dir_exists_absolute(path):
		if not suppress_error:
			push_error("Directory not found: '%s'" % path)
		
		return false
	
	return true

## The [method check_and_create_directory] method uses the
## [method check_directory] and [method create_directory] methods
## to create a directory only if it doesn't already exist.
static func check_and_create_directory(directory: String) -> bool:
	if not check_directory(directory, true):
		return create_directory(directory)
	
	return true

## The [method save_data] method should be overwritten so that it saves
## the given [param data] in the file specified by the [param file_id]. [br]
## If the [param replace] flag is set to [code]true[/code], any previous
## data should be overwritten. [br]
## If the [param suppress_errors] is [code]true[/code], this method
## shouldn't push any errors. [br]
## At the end, this method should return a [Dictionary] with the data
## saved.
func save_data(
	_file_id: String,
	_data: Dictionary,
	_replace: bool = false,
	_suppress_errors: bool = false
) -> Dictionary: return {}

## The [method load_data] method should be overwritten so that it loads
## data from the file specified by the [param file_id]. [br]
## Iff the [param suppress_errors] is [code]true[/code], this method
## shouldn't push any errors. [br]
## At the end, this method should return a [Dictionary] with the data
## obtained.
func load_data(
	_file_id: String,
	_suppress_errors: bool = false
) -> Dictionary: return {}
