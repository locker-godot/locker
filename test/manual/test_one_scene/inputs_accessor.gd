@tool
extends LokStorageAccessor

@onready var color: ColorPickerButton = $"../Color"

@onready var name_input: LineEdit = $"../Name"

func save_data() -> Dictionary:
	return {
		"color": var_to_str(color.color),
		"name": name_input.text
	}

func load_data(data: Dictionary) -> void:
	if data.has("color"):
		color.color = str_to_var(data["color"])
		
		color.color_changed.emit(color.color)
	if data.has("name"):
		name_input.text = data["name"]
