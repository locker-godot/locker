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
	var creation_succeded: bool = check_and_create_encrypted_file(
		partition_path, password, JSON.stringify({}, "\t"), suppress_errors
	)
	
	if not creation_succeded:
		return {}
	
	var result: Dictionary = data
	var previous_data: Dictionary = {}
	
	if not replace:
		previous_data = load_partition(partition_path, true)
	
	result = data.merged(previous_data)
	
	var writing_succeded: bool = write_or_create_encrypted_file(
		partition_path, password, JSON.stringify(result, "\t"), suppress_errors
	)
	
	if not writing_succeded:
		return {}
	
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
	suppress_errors: bool = false
) -> Dictionary:
	if not check_file(partition_path, suppress_errors):
		return {}
	
	var partition_content: String = read_encrypted_file(
		partition_path, password, suppress_errors
	)
	var data: Variant = JSON.parse_string(partition_content)
	
	if data == null:
		if not suppress_errors:
			push_error_unrecognized_partition(partition_path)
		
		return {}
	
	var partition_name: String = get_file_prefix(get_file_name(partition_path))
	
	for accessor_id: String in data:
		var accessor: Dictionary = data[accessor_id]
		
		accessor["partition"] = partition_name
	
	return data
