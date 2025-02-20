## The [LokJSONAccessStrategy] class is responsible for
## implementing [code]JSON[/code] data accessing.
## 
## This class inherits from the [LokAccessStrategy] in order to implement
## its [method save_partition] and [method load_partition] methods and,
## with that, provide saving and loading functionalities for
## [code]JSON[/code] data. [br]
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
	replace: bool = false
) -> Dictionary:
	var result: Dictionary = create_result()
	
	var error: Error = LokFileSystemUtil.create_file_if_not_exists(
		partition_path
	)
	
	# If partition wasn't created, cancel
	if error != Error.OK:
		result["status"] = error
		return result
	
	var load_result: Dictionary = {}
	
	if not replace:
		load_result = load_partition(partition_path)
	
	# Merge previous and new datas
	result["data"] = data.merged(load_result.get("data", {}))
	
	error = LokFileSystemUtil.write_or_create_file(
		partition_path, JSON.stringify(result["data"], "\t")
	)
	
	if error != Error.OK:
		result["status"] = error
	
	return result

## The [method load_partition] method overrides its super counterpart
## [method LokAccessStrategy.load_partition] in order to provide data
## loading in the [code]JSON[/code] format. [br]
## When finished, this method returns a [Dictionary] with the data it
## loaded. [br]
## To read more about the parameters of this method and the format of
## its return, see [method LokAccessStrategy.load_partition].
func load_partition(
	partition_path: String
) -> Dictionary:
	var result: Dictionary = create_result()
	
	# Abort if partition doesn't exist
	if not LokFileSystemUtil.file_exists(partition_path):
		result["status"] = Error.ERR_FILE_NOT_FOUND
		return result
	
	var loaded_content: String = LokFileSystemUtil.read_file(
		partition_path
	)
	var loaded_data: Variant = LokFileSystemUtil.parse_json_from_string(
		loaded_content, true
	)
	
	# Cancel if no data could be parsed
	if loaded_data == {}:
		result["status"] = Error.ERR_FILE_UNRECOGNIZED
	
	result["data"] = loaded_data
	
	return result

# Returns a simple String representing this AccessStrategy
func _to_string() -> String:
	return "JSON"
