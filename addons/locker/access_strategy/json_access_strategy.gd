## The [LokJSONAccessStrategy] class is responsible for
## implement [code]JSON[/code] data accessing.
## 
## This class inherits from the [LokAccessStrategy] in order to implement
## its [method save_partition] and [method load_partition] methods and
## with that provide saving and loading functionalities for
## [code]JSON[/code] data.
## [br]
## [b]Version[/b]: 1.0.0[br]
## [b]Author[/b]: [url]github.com/nadjiel[/url]
class_name LokJSONAccessStrategy
extends LokAccessStrategy

## The [method save_partition] method overrides its super counterpart
## [method LokAccessStrategy.save_partition] in order to provide [param data]
## saving in the [code]JSON[/code] format. [br]
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
	var creation_succeded: bool = check_and_create_file(
		partition_path, "", suppress_errors
	)
	
	if not creation_succeded:
		return {}
	
	var result: Dictionary = data
	var previous_data: Dictionary = {}
	
	if not replace:
		previous_data = load_partition(partition_path, true)
	
	result = data.merged(previous_data)
	
	var writing_succeded: bool = write_or_create_file(
		partition_path, JSON.stringify(result, "\t"), suppress_errors
	)
	
	if not writing_succeded:
		return {}
	
	return result

## The [method load_partition] method overrides its super counterpart
## [method LokAccessStrategy.load_partition] in order to provide data
## loading in the [code]JSON[/code] format. [br]
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
	
	var partition_content: String = read_file(
		partition_path, suppress_errors
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
