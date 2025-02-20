
class_name SimpleTopdownLabelToastPopup
extends Label

func popup(_text: String, seconds: float = 1.0) -> void:
	text = _text
	
	await get_tree().create_timer(seconds).timeout
	
	text = ""
