
class_name LokUtil
extends Node

static func filter_value(filter: Array, value: Variant) -> bool:
	if filter.is_empty():
		return true
	if value in filter:
		return true
	
	return false
