
extends HBoxContainer

func _ready() -> void:
	var counter: int = 0
	
	for child: Node in get_children():
		if child is not FileCard:
			continue
		
		var file_card := child as FileCard
		
		counter += 1
		
		file_card.set_file_id(str(counter))
