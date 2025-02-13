
class_name LokUtil
extends Node

static func filter_value(filter: Array, value: Variant) -> bool:
	if filter.is_empty():
		return true
	if value in filter:
		return true
	
	return false

static func filter_dictionary(dict: Dictionary, filter: Callable) -> Dictionary:
	var result: Dictionary = {}
	
	for key: Variant in dict.keys():
		var value: Variant = dict[key]
		
		if filter.call(key, value):
			result[key] = value
	
	return result

static func split_dictionary(dict: Dictionary, spliter: Callable) -> Array[Dictionary]:
	var truthy_dict: Dictionary = {}
	var falsy_dict: Dictionary = {}
	
	for key: Variant in dict.keys():
		var value: Variant = dict[key]
		
		if spliter.call(key, value):
			truthy_dict[key] = value
		else:
			falsy_dict[key] = value
	
	return [ truthy_dict, falsy_dict ]

static func map_dictionary(dict: Dictionary, mapper: Callable) -> Dictionary:
	var result: Dictionary = {}
	
	for key: Variant in dict.keys():
		var value: Variant = dict[key]
		
		result[key] = mapper.call(key, value)
	
	return result
