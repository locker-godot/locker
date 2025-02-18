
extends Node2D

func _enter_tree() -> void:
	LokGlobalStorageManager.set_saves_directory("res://examples/dynamic_multiplayer/saves/")
	LokGlobalStorageManager.set_access_strategy(LokJSONAccessStrategy.new())
