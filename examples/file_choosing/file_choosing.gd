
extends Node2D

@onready var accessor_group: LokAccessorGroup = %AccessorGroup

func _ready() -> void:
	LokGlobalStorageManager.set_saves_directory("res://examples/file_choosing/saves/")
	LokGlobalStorageManager.set_access_strategy(LokJSONAccessStrategy.new())
	accessor_group.load_accessor_group()
