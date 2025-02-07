
class_name LokEncryptedAccessStrategy
extends LokAccessStrategy

var password: String = ""

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
			push_error(
				"Couldn't parse JSON data from partition '%s'" % partition_path
			)
		
		return {}
	
	return data

#func save_data(
	#file_path: String,
	#file_format: String,
	#data: Dictionary,
	#replace: bool = false,
	#suppress_errors: bool = false
#) -> Dictionary:
	#var file: FileAccess
	#
	#if not FileAccess.file_exists(file_path):
		#file = FileAccess.open_encrypted_with_pass(
			#file_path, FileAccess.WRITE, LockerPlugin.get_encryption_password()
		#)
		#file.store_string(JSON.stringify({}))
		#file.close()
	#
	#file = FileAccess.open_encrypted_with_pass(
		#file_path,
		#FileAccess.READ,
		#LockerPlugin.get_encryption_password()
	#)
	#
	#if file == null:
		#push_error("Error on saving data: %s" % [ FileAccess.get_open_error() ])
		#return {}
	#
	#var file_content: String = file.get_as_text()
	#
	#file.close()
	#
	#var file_data: Variant = JSON.parse_string(file_content)
	#
	#if file_data == null:
		#file_data = {}
	#
	#var merged_data: Dictionary = data.merged(file_data)
	#
	#file = FileAccess.open_encrypted_with_pass(
		#file_path,
		#FileAccess.WRITE,
		#LockerPlugin.get_encryption_password()
	#)
	#
	#file.store_string(JSON.stringify(merged_data, "\t"))
	#
	#file.close()
	#
	#return data

#func load_data(
	#file_path: String,
	#file_format
	#partitions: Array[String] = [],
	#suppress_errors: bool = false
#) -> Dictionary:
	#if not FileAccess.file_exists(file_path):
		#push_error("File not found in path %s" % file_path)
		#return {}
	#
	#var file := FileAccess.open_encrypted_with_pass(
		#file_path,
		#FileAccess.READ,
		#LockerPlugin.get_encryption_password()
	#)
	#
	#if file == null:
		#push_error("Error on loading data: %s" % [ FileAccess.get_open_error() ])
		#return {}
	#
	#var file_content: String = file.get_as_text()
	#
	#file.close()
	#
	#var data: Dictionary = JSON.parse_string(file_content)
	#
	#if data == null:
		#push_error("Couldn't parse JSON data")
		#return {}
	#
	#return data
