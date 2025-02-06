@tool
class_name InputsAccessorV1_0_0
extends LokStorageAccessorVersion

func retrieve_data(dependencies: Dictionary) -> Dictionary:
	var color: ColorPickerButton = dependencies.get("color")
	var name_input: LineEdit = dependencies.get("name_input")
	
	var result := {}
	
	if color != null:
		result["color"] = var_to_str(color.color)
	if name_input != null:
		result["name"] = name_input.text
	
	return result

func consume_data(
	data: Dictionary,
	dependencies: Dictionary
) -> void:
	var color: ColorPickerButton = dependencies.get("color")
	var name_input: LineEdit = dependencies.get("name_input")
	
	if color != null and data.has("color"):
		color.color = str_to_var(data["color"])
		
		color.color_changed.emit(color.color)
	if name_input != null and data.has("name"):
		name_input.text = data["name"]
