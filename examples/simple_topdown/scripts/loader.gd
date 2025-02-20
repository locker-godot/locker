
extends CanvasItem

func _on_storage_operation_started() -> void:
	visible = true

func _on_storage_operation_finished(_result: Dictionary) -> void:
	visible = false
