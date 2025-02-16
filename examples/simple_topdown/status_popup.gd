
extends "res://examples/simple_topdown/label_toast_popup.gd"

func _on_storage_operation_finished(
	_result: Dictionary,
	operation: StringName
) -> void:
	popup(operation)
