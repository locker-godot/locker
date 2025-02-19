@icon("res://addons/locker/icons/storage_accessor_version.svg")
## The [LokStorageAccessorVersion] resource describes how data is saved and
## loaded from a [LokStorageAccessor] in a specific version.
## 
## The purpose of this class is to provide different behaviors of how
## data is dealt with accross different versions of the game that require
## changes in the save files organization. [br]
## In order to achieve that, this class should be extended
## so that different implementations of the
## [method retrieve_data] and [method consume_data] methods can be
## created for different versions of a [LokStorageAccessor]. [br]
## [br]
## [b]Version[/b]: 1.0.0[br]
## [b]Author[/b]: [url]github.com/nadjiel[/url]
class_name LokStorageAccessorVersion
extends Resource

## The [member number] property specifies what version of
## [LokStorageAccessor] this [LokStorageAccessorVersion]
## corresponds to. [br]
## Initially this is set to [code]"1.0.0"[/code], which is
## the default version. [br]
## If you don't intend to version your save data, you can always just
## leave this as default.
@export var number: String = "1.0.0":
	set = set_number,
	get = get_number

func set_number(new_number: String) -> void:
	number = new_number

func get_number() -> String:
	return number

## The [method create] method is a utility to create a new
## [LokStorageAccessorVersion] with its properties already
## set to the desired values.
static func create(
	_number: String = "1.0.0"
) -> LokStorageAccessorVersion:
	var result := LokStorageAccessorVersion.new()
	result.number = _number
	
	return result

## The [method get_version_parts] method returns an [Array] with the
## substrings separated by [code]"."[/code] that compose the
## [member number] of this [LokStorageAccessorVersion].
static func get_version_parts(version: LokStorageAccessorVersion) -> Array[String]:
	return version.number.split(".")

## The [method get_minor_version] method returns a [String] with the
## minor version in the [member number] of this [LokStorageAccessorVersion].
static func get_minor_version(version: LokStorageAccessorVersion) -> String:
	return version.number.get_slice(".", 2)

## The [method get_patch_version] method returns a [String] with the
## patch version in the [member number] of this [LokStorageAccessorVersion].
static func get_patch_version(version: LokStorageAccessorVersion) -> String:
	return version.number.get_slice(".", 1)

## The [method get_major_version] method returns a [String] with the
## major version in the [member number] of this [LokStorageAccessorVersion].
static func get_major_version(version: LokStorageAccessorVersion) -> String:
	return version.number.get_slice(".", 0)

## The [method compare_versions] method returns an [code]int[/code]
## representing if two [LokStorageAccessorVersion]s are less than
## ([code]-1[/code]), equal ([code]0[/code])
## or greater than ([code]1[/code]) one another.
static func compare_versions(
	version1: LokStorageAccessorVersion,
	version2: LokStorageAccessorVersion
) -> int:
	return version1.number.naturalnocasecmp_to(version2.number)

## The [method compare_minor_versions] method returns an [code]int[/code]
## representing if the minor versions of two [LokStorageAccessorVersion]s
## are less than ([code]-1[/code]), equal ([code]0[/code])
## or greater than ([code]1[/code]) one another.
static func compare_minor_versions(
	version1: LokStorageAccessorVersion,
	version2: LokStorageAccessorVersion
) -> int:
	var minor_version1: String = get_minor_version(version1)
	var minor_version2: String = get_minor_version(version2)
	
	return minor_version1.naturalnocasecmp_to(minor_version2)

## The [method compare_patch_versions] method returns an [code]int[/code]
## representing if the patch versions of two [LokStorageAccessorVersion]s
## are less than ([code]-1[/code]), equal ([code]0[/code])
## or greater than ([code]1[/code]) one another.
static func compare_patch_versions(
	version1: LokStorageAccessorVersion,
	version2: LokStorageAccessorVersion
) -> int:
	var patch_version1: String = get_patch_version(version1)
	var patch_version2: String = get_patch_version(version2)
	
	return patch_version1.naturalnocasecmp_to(patch_version2)

## The [method compare_major_versions] method returns an [code]int[/code]
## representing if the major versions of two [LokStorageAccessorVersion]s
## are less than ([code]-1[/code]), equal ([code]0[/code])
## or greater than ([code]1[/code]) one another.
static func compare_major_versions(
	version1: LokStorageAccessorVersion,
	version2: LokStorageAccessorVersion
) -> int:
	var major_version1: String = get_major_version(version1)
	var major_version2: String = get_major_version(version2)
	
	return major_version1.naturalnocasecmp_to(major_version2)

## The [method retrieve_data] method should be overriden by concrete
## implementations of [LokStorageAccessorVersion]s in order
## to define what data this [LokStorageAccessor] should store. [br]
## This method receives a [param dependencies] [Dictionary] that brings
## all information from the [member LokStorageAccessor.dependency_paths], so
## that this [LokStorageAccessorVersion] can access it. [br]
## Any [NodePath]s from the [member LokStorageAccessor.dependency_paths]'s
## values are converted to nodes before being passed to this method so that
## they can be easily referenced by this [LokStorageAccessorVersion]. [br]
## When finished processing, this method should return a [Dictionary] with
## the data that should be stored in a save file. [br]
## If you're using the [LokJSONAccessStrategy] or the
## [LokEncryptedAccessStrategy] (the built-in strategies of the [LockerPlugin]),
## the returned [Dictionary] should only store basic data
## types like [String]s, [code]floats[/code] and [code]bools[/code],
## so you need to make sure to transform your data accordingly. [br]
## For parsing from complex data types like [Vector2]s to [String]s, I recommend
## using the [method @GlobalScope.var_to_str] method.
func retrieve_data(
	_dependencies: Dictionary
) -> Dictionary: return {}

## The [method consume_data] method should be overriden by concrete
## implementations of [LokStorageAccessorVersion]s in order
## to define what happens to the [param data] it receives when the game is
## loaded. [br]
## This method receives a [param dependencies] [Dictionary] that brings
## all information from the [member LokStorageAccessor.dependency_paths], so
## that this [LokStorageAccessorVersion] can access it. [br]
## Any [NodePath]s from the [member LokStorageAccessor.dependency_paths]'s
## values are converted to nodes before being passed to this method so that
## they can be easily referenced by this [LokStorageAccessorVersion]. [br]
## If you're using the [LokJSONAccessStrategy] or the
## [LokEncryptedAccessStrategy] (the built-in strategies of the [LockerPlugin]),
## the [param data] [Dictionary] will only be capable of storing basic data
## types like [String]s, [code]floats[/code] and [code]bools[/code],
## so you need to make sure to transform your data accordingly. [br]
## For parsing from [String] to complex data types like [Vector2]s, I recommend
## using the [method @GlobalScope.str_to_var] method.
func consume_data(
	_data: Dictionary,
	_dependencies: Dictionary
) -> void: pass
