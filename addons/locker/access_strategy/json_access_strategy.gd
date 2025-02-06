
class_name LokJSONAccessStrategy
extends LokAccessStrategy

func save_partition(
	partition_path: String,
	data: Dictionary,
	replace: bool = false,
	suppress_errors: bool = false
) -> Dictionary:
	check_and_create_file(partition_path)
	
	var result: Dictionary = data
	var previous_data: Dictionary = {}
	
	if not replace:
		previous_data = load_partition(partition_path, true)
	
	result = data.merged(previous_data)
	
	write_or_create_file(
		partition_path, JSON.stringify(result, "\t"), "", suppress_errors
	)
	
	return result

func load_partition(
	partition_path: String,
	suppress_errors: bool = false
) -> Dictionary:
	if not check_file(partition_path, suppress_errors):
		return {}
	
	var partition_content: String = read_file(partition_path)
	var data: Variant = JSON.parse_string(partition_content)
	
	if data == null:
		if not suppress_errors:
			push_error(
				"Couldn't parse JSON data from partition '%s'" % partition_path
			)
		
		return {}
	
	return data

func save_data(
	file_path: String,
	file_format: String,
	data: Dictionary,
	replace: bool = false,
	suppress_errors: bool = false
) -> Dictionary:
	var result: Dictionary = {}
	
	for partition: String in data:
		var partition_path: String = "%s/%s.%s" % [
			file_path, partition, file_format
		]
		var partition_data: Dictionary = data[partition]
		
		result.merge(save_partition(
			partition_path, partition_data, replace, suppress_errors
		))
	
	return result
	
	#for partition: String in data:
		#var partition_path: String = "%s/%s.%s" % [ file_path, partition, file_format ]
		#var partition_data: Dictionary = data[partition]
		#
		#check_and_create_file(partition_path)
		#
		#var result: Dictionary = {}
		#
		#var previous_data: Dictionary = {}
		#
		#if not replace:
			#previous_data = load_data(file_path, [ partition ], true)
		#
		#result = partition_data.merged(previous_data)
		#
		#write_or_create_file(
			#partition_path, JSON.stringify(result, "\t"), "", suppress_errors
		#)
		#
		#total_result.merge(result)
	#
	#return total_result
	
	#check_and_create_file(file_path)
	#
	#var result: Dictionary = data
	#
	#var file_data: Dictionary = {}
	#
	#if not replace:
		#file_data = load_data(file_path, [], true)
	#
	#result = data.merged(file_data)
	#
	#write_or_create_file(
		#file_path, JSON.stringify(result, "\t"), "", suppress_errors
	#)
	#
	#return result

func load_data(
	file_path: String,
	partitions: Array[String] = [],
	suppress_errors: bool = false
) -> Dictionary:
	#var result: Dictionary = {}
	#
	#for partition: String in data:
		#var partition_path: String = "%s/%s.%s" % [
			#file_path, partition, file_format
		#]
		#var partition_data: Dictionary = data[partition]
		#
		#result.merge(save_partition(
			#partition_path, partition_data, replace, suppress_errors
		#))
	#
	#return result
	
	
	
	#if not check_file(file_path, suppress_errors):
		#return {}
	#
	#var file_content: String = read_file(file_path)
	#
	#var data: Variant = JSON.parse_string(file_content)
	#
	#if data == null:
		#if not suppress_errors:
			#push_error("Couldn't parse JSON data")
		#
		#return {}
	#
	#return data
	return {}
