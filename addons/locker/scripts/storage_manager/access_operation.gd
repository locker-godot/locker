
class_name LokAccessOperation
extends RefCounted

signal started(operation: LokAccessOperation)

signal finished(result: Dictionary, operation: LokAccessOperation)

var callable: Callable = Callable()

func _init(_callable: Callable) -> void:
	callable = _callable

func operate() -> Dictionary:
	started.emit.call_deferred(self)
	
	var result: Dictionary = callable.call()
	
	finished.emit.call_deferred(result, self)
	
	return result
