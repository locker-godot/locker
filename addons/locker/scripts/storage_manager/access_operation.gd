@icon("res://addons/locker/icons/access_operation.svg")
## The [LokAccessOperation] class executes given operations to access data.
## 
## The [LokAccessOperation] class helps with the execution of operations
## that can manipulate stored data. [br]
## This class is used by the [LokAccessExecutor] class in order to organize
## and queue different operations in a parallel [Thread]. [br]
## Since this class is used with different [Thread]s, it uses the
## [method Object.call_deferred] method when emitting signals, so that
## the main [Thread] can seamlessly connect with these signals. [br]
## [br]
## [b]Version[/b]: 1.0.0 [br]
## [b]Author[/b]: Daniel Sousa ([url]github.com/nadjiel[/url])
class_name LokAccessOperation
extends RefCounted

## The [signal started] signal is emitted when this operation starts with
## its [method operate] method being called.
signal started()

## The [signal finished] signal is emitted when this operations finishes with
## the end of its [method operate] method execution. [br]
## This signal passes a [param result] [Dictionary] with the result of this
## operation.
signal finished(result: Dictionary)

## The [member callable] property of this [LokAccessOperation] represents
## a [Callable] that is executed in order for this [LokAccessOperation] to
## execute. [br]
## This [Callable] is supposed to return a [Dictionary] with the result of
## this [LokAccessOperation].
var callable: Callable

func _init(_callable: Callable) -> void:
	callable = _callable

## The [method operate] is the main point of execution of this
## [LokAccessOperation]. [br]
## It's this method that is responsible for emitting the [signal started] and
## [signal finished] signals in the given times, which allows this
## [LokAccessOperation] to be handled asynchronously.
func operate() -> Dictionary:
	started.emit.call_deferred()
	
	var result: Dictionary = callable.call()
	
	finished.emit.call_deferred(result)
	
	return result
