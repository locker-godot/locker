
extends CanvasItem

func _on_storage_operation_started(_operation: StringName) -> void:
	visible = true

func _on_storage_operation_finished(
	_result: Dictionary,
	_operation: StringName
) -> void:
	visible = false
