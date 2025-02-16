@icon("res://addons/locker/icons/util.svg")
## The [LokUtil] class is a utility class that brings random useful
## static methods that can be used wherever convenient.
## 
## The purpose of this class is helping with common repetitive code
## that is needed in multiple places. [br]
## Since the methods of this class are [code]static[/code] it
## doesn't need to be instantiated. [br]
## [br]
## [b]Version[/b]: 1.0.0 [br]
## [b]Author[/b]: Daniel Sousa ([url]github.com/nadjiel[/url])
class_name LokUtil
extends Node

## The [method filter_value] method is a helper function that takes
## a [param filter] [Array] and a [param value] to be filtered. [br]
## This function, then, tests if the [param value] is present in the
## [param filter] [Array] (using the [code]in[/code] operator). [br]
## If present, [code]true[/code] is returned to indicate the filtering
## passed, if absent, [code]false[/code] is returned to indicate
## the filtering didn't pass. [br]
## If the received [param filter] is an empty [Array], this function
## considers the filtering as passed.
static func filter_value(filter: Array, value: Variant) -> bool:
	if filter.is_empty():
		return true
	if value in filter:
		return true
	
	return false

## The [method filter_dictionary] method takes a [param dict] ([Dictionary])
## and a [param filter] [Callable] and uses that [Callable] to test for
## each key/ value pair of that [param dict] if such entry should be
## kept or not in the resultant [Dictionary]. [br]
## In order to realize the tests, the [param filter] [Callable] should
## accept two values: a [param key] and a [param value]. That [Callable] should
## then return a [code]bool[/code] indicating if that pair should be kept
## in the result.
static func filter_dictionary(dict: Dictionary, filter: Callable) -> Dictionary:
	var result: Dictionary = {}
	
	for key: Variant in dict.keys():
		var value: Variant = dict[key]
		
		if filter.call(key, value):
			result[key] = value
	
	return result

## The [method split_dictionary] method works similarly to the
## [method filter_dictionary] method, but instead of returning only a
## [Dictionary] with the values that passed the filtering, this method
## returns an [Array] with two [Dictionary]s: one with the entries that passed
## the filtering, and the one with the entries that didn't.
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

## The [method map_dictionary] method takes a [param dict] ([Dictionary])
## and a [param mapper] [Callable] and uses that [Callable] to transform
## each key/ value pair of the original [Dictionary] into a new
## value in a new [Dictionary]. [br]
## In order to realize that mapping, the [param mapper] [Callable] should
## accept two values: a [param key] and a [param value]. That [Callable] should
## then return a value that will occupy the place of the received [param value]
## in the new [Dictionary].
static func map_dictionary(dict: Dictionary, mapper: Callable) -> Dictionary:
	var result: Dictionary = {}
	
	for key: Variant in dict.keys():
		var value: Variant = dict[key]
		
		result[key] = mapper.call(key, value)
	
	return result

## The [method check_and_disconnect_signal] method tries to
## disconnect a [param callable] from a signal in an
## [param object] if they are connected. [br]
## If they aren't, this method returns [code]false[/code] to indicate
## that nothing was done. If the [param object] is [code]null[/code]
## [code]false[/code] is also returned, and nothing is done. [br]
## If the disconection is successful, [code]true[/code] is returned.
static func check_and_disconnect_signal(
	object: Object,
	signal_name: StringName,
	callable: Callable
) -> bool:
	if object == null:
		return false
	if not object.has_signal(signal_name):
		return false
	if not object.is_connected(signal_name, callable):
		return false
	
	object.disconnect(signal_name, callable)
	
	return true

## The [method check_and_disconnect_signals] method tries to
## disconnect all the callables and signals passed
## in the [param signals] [code]Array[/code].
## The [param signals] parameter must be passed as
## an [code]Array[/code] which elements must be in the following format:
## [code]{ "name": <signal_name>, "callable": <callable_reference> }[/code]
## In the [param object] parameter is [code]null[/code], this method won't
## do nothing.
static func check_and_disconnect_signals(
	object: Object,
	signals: Array[Dictionary]
) -> void:
	if object == null:
		return
	
	for i: int in signals.size():
		check_and_disconnect_signal(
			object,
			signals[i].get("name", &""),
			signals[i].get("callable", func(): pass)
		)

## The [method check_and_connect_signal] method tries to
## connect a [param callable] to a signal in an [param object]. [br]
## If the [param object] is [code]null[/code],
## [code]false[/code] is returned and nothing is done. [br]
## If the connection is successful, [code]true[/code] is returned.
static func check_and_connect_signal(
	object: Object,
	signal_name: StringName,
	callable: Callable,
	flags: int = 0
) -> bool:
	if object == null:
		return false
	if not object.has_signal(signal_name):
		return false
	if object.is_connected(signal_name, callable):
		return false
	
	object.connect(signal_name, callable, flags)
	
	return true

## The [method check_and_connect_signals] method tries to
## connect all the callables and signals passed
## in the [param signals] [code]Array[/code].
## The [param signals] parameter must be passed as
## an [code]Array[/code] which elements must be in the following format:
## [code]{ "name": <signal_name>, "callable": <callable_reference>, "flags": <optional_flags> }[/code]
## If the [param object] parameter is [code]null[/code], this method won't
## do nothing.
static func check_and_connect_signals(
	object: Object,
	signals: Array[Dictionary]
) -> void:
	if object == null:
		return
	
	for i: int in signals.size():
		var callable: Callable = signals[i].get("callable")
		
		if callable == null:
			continue
		
		var flags: int = signals[i].get("flags", 0)
		
		object.connect(
			signals[i].get("name", &""),
			callable,
			flags
		)
