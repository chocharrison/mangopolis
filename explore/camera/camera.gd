extends Node3D

var players: Node3D

@onready var is_cutscene = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	players = get_parent().get_node("FSM_Players")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !is_cutscene:
		var camera_position = position
		var main_player_position = players.give_main_player_position()
		camera_position.x = lerp(camera_position.x, main_player_position.x, 0.1)
		camera_position.y = lerp(camera_position.y, main_player_position.y, 0.1)
		camera_position.z = lerp(camera_position.z, main_player_position.z, 0.1)
		position = camera_position

func set_cutscene(scene: bool):
	is_cutscene = scene
