
extends PanelContainer

const PLAYER: PackedScene = preload("res://examples/dynamic_multiplayer/scenes/player.tscn")

@onready var title: Label = %Title
@onready var join_button: Button = %JoinButton
@onready var leave_button: Button = %LeaveButton

@export var username: String = "":
	set = set_username

var player: DynamicMultiplayerPlayer

func set_username(new_username: String) -> void:
	username = new_username
	
	if not is_node_ready():
		await ready
	
	title.text = new_username

func instantiate_player() -> void:
	player = PLAYER.instantiate() as DynamicMultiplayerPlayer
	
	if username == "player2":
		player.inputs["up"] = "player2_up"
		player.inputs["right"] = "player2_right"
		player.inputs["down"] = "player2_down"
		player.inputs["left"] = "player2_left"
	
	player.visible = false
	
	get_tree().current_scene.add_child(player)
	
	var player_accessor := player.get_node("StorageAccessor") as LokStorageAccessor
	var player_username := player.get_node("UserName") as Label
	
	player_accessor.id = username
	player_accessor.partition = username
	player_username.text = username
	
	await player_accessor.load_data()
	
	player.visible = true
	
	join_button.visible = false
	leave_button.visible = true

func quit_player() -> void:
	await LokGlobalStorageManager.save_data()
	
	player.queue_free()
	
	join_button.visible = true
	leave_button.visible = false
