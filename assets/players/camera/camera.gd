extends Node3D

@onready var players = get_parent()
@onready var camera = $camera_target/Camera3D
@onready var target_camera = $camera_target


@onready var target_position = target_camera.position
@onready var save_state = null
##################################### States
enum STATE {PLAYER, CUTSCENE, MATH, HURT, PAUSED}
@onready var state = STATE.PLAYER
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	match state:
		STATE.PLAYER:
			state_player()
		STATE.MATH:
			state_math()
func state_player():
	var camera_position = position
	var main_player_position = players.give_main_player_position()
	camera_position.x = lerp(camera_position.x, main_player_position.x, 0.1)
	camera_position.y = lerp(camera_position.y, main_player_position.y, 0.1)
	camera_position.z = lerp(camera_position.z, main_player_position.z, 0.1)
	position = camera_position

func state_math():
	var camera_position = target_camera.position
	camera_position = camera_position.lerp(Vector3(0,0,0),0.001)
	target_camera.position = camera_position

func state_cutscenes():
	pass

func set_state_player():
	state = STATE.PLAYER
	target_camera.position = target_camera.position.lerp(target_position,1)
	camera.make_current()

func set_state_custscene():
	state = STATE.CUTSCENE

func set_state_math():
	target_position = target_camera.position 
	state = STATE.MATH

func set_state_paused():
	save_state = state
	state = STATE.PAUSED

func set_state_unpaused():
	state = save_state


func _on_area_3d_body_entered(body: Node3D) -> void:
	print(body.name)
	if(body.is_in_group("items")):
		print("yes")
		var change = body.get_parent().get_node("AnimatedSprite3D")
		change.modulate.a = 0.25


func _on_area_3d_body_exited(body: Node3D) -> void:
	if(body.is_in_group("items")):
		var change = body.get_parent().get_node("AnimatedSprite3D")
		change.modulate.a = 1


func _on_area_3d_area_entered(area: Area3D) -> void:
	if(area.is_in_group("items")):
		var change = area.get_node("AnimatedSprite3D")
		change.modulate.a = 0.25


func _on_area_3d_area_exited(area: Area3D) -> void:
	if(area.is_in_group("items")):
		var change = area.get_node("AnimatedSprite3D")
		change.modulate.a = 1
