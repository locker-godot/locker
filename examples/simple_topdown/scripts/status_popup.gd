
extends SimpleTopdownLabelToastPopup

func _on_storage_saving_finished(_result: Dictionary) -> void:
	popup("saved")

func _on_storage_loading_finished(_result: Dictionary) -> void:
	popup("loaded")
