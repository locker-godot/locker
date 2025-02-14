## The [LokEncryptedAccessStrategy] class is responsible for
## implementing encrypted data accessing.
## 
## This class inherits from the [LokAccessStrategy] in order to implement
## its [method save_partition] and [method load_partition] methods and
## with that provide saving and loading functionalities for
## encrypted data.
## [br]
## [b]Version[/b]: 1.0.0[br]
## [b]Author[/b]: [url]github.com/nadjiel[/url]
class_name LokEncryptedAccessStrategy
extends LokAccessStrategy

## The [member password] property is used when encrypting/ decrypting data,
## so it must be set to a password intended before starting using this class.
var password: String = "":
	set = set_password,
	get = get_password

func set_password(new_password: String) -> void:
	password = new_password

func get_password() -> String:
	return password

## The [method save_partition] method overrides its super counterpart
## [method LokAccessStrategy.save_partition] in order to provide [param data]
## saving in a encrypted format. [br]
## When finished, this method returns a [Dictionary] with the data it
## saved. [br]
## To read more about the parameters of this method, see
## [method LokAccessStrategy.save_partition].
func save_partition(
	partition_path: String,
	data: Dictionary,
	replace: bool = false,
	suppress_errors: bool = false
) -> Dictionary:
	var result: Dictionary = create_result()
	
	var error: Error = LokFileSystemUtil.create_encrypted_file_if_not_exists(
		partition_path, password
	)
	
	# If partition wasn't created, cancel
	if error != Error.OK:
		result["status"] = error
		return result
	
	var load_result: Dictionary = {}
	
	if not replace:
		load_result = load_partition(partition_path, true)
	
	# Merge previous and new datas
	result["data"] = data.merged(load_result.get("data", {}))
	
	error = LokFileSystemUtil.write_or_create_encrypted_file(
		partition_path, password, JSON.stringify(result["data"], "\t")
	)
	
	if error != Error.OK:
		result["status"] = error
	
	return result

## The [method load_partition] method overrides its super counterpart
## [method LokAccessStrategy.load_partition] in order to provide encrypted data
## loading. [br]
## When finished, this method returns a [Dictionary] with the data it
## loaded. [br]
## To read more about the parameters of this method and the format of
## its return, see [method LokAccessStrategy.load_partition].
func load_partition(
	partition_path: String,
	#accessor_ids: Array[String] = [],
	#version_numbers: Array[String] = [],
	#bring_partition: bool = true,
	suppress_errors: bool = false
) -> Dictionary:
	var result: Dictionary = create_result()
	
	# Abort if partition doesn't exist
	if not LokFileSystemUtil.file_exists(partition_path):
		if not suppress_errors:
			LokFileSystemUtil.push_error_file_not_found(partition_path)
		
		result["status"] = Error.ERR_FILE_NOT_FOUND
		return result
	
	var loaded_content: String = LokFileSystemUtil.read_encrypted_file(
		partition_path, password
	)
	var loaded_data: Variant = LokFileSystemUtil.parse_json_from_string(
		loaded_content, suppress_errors
	)
	
	# Cancel if no data could be parsed
	if loaded_data == {}:
		result["status"] = Error.ERR_FILE_UNRECOGNIZED
		return result
	
	# Append the partition ID to each accessor data
	#if bring_partition:
		#var partition_name: String = LokFileSystemUtil.get_file_name(
			#partition_path
		#)
		#var partition_id: String = LokFileSystemUtil.get_file_prefix(
			#partition_name
		#)
		#
		#for accessor_id: String in loaded_data:
			#var accessor_data: Dictionary = loaded_data[accessor_id]
			#
			#accessor_data["partition"] = partition_id
	
	result["data"] = loaded_data
	
	return result
