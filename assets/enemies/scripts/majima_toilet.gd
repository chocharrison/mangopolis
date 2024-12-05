extends Node3D

const SPEED = 4.0

@onready var anime = get_node("AnimationTree")
@onready var stab = $stab/collide


enum STATE {CHASE, MATH, DISABLED, ENABLED}

@onready var state = STATE.ENABLED
@onready var player = get_tree().get_nodes_in_group("players")[0]
@onready var player_found = false
@onready var player_contact = false
@onready var direction = Vector3(0,0,0)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.math_success.connect(_on_result)


func _physics_process(_delta: float) -> void:

	handle_state_transitions()
	perform_state_actions(_delta)


func perform_state_actions(_delta):
	match state:
		STATE.CHASE:
			state_chase(_delta)


func handle_state_transitions():
	if state == STATE.DISABLED:
		return


func state_chase(_delta):
	anime.get("parameters/playback").travel("chase")
	set_sprite_direction(player.global_position)
	global_position = global_position.lerp(player.global_position, SPEED * _delta)

func set_chase():
	state = STATE.CHASE
	anime.get("parameters/playback").travel("chase")
	stab.set_deferred("disabled",false)
	player_contact = false
		
func set_disabled():
	state = STATE.DISABLED
	stab.set_deferred("disabled",true)
	player_contact = false

func set_math():
	state = STATE.MATH
	SignalManager.signal_math.emit(1, 20,0)

func set_sprite_direction(target_position: Vector3):
	direction = (Vector3(target_position.x,0,target_position.z) - Vector3(position.x,0,position.z)).normalized()
	anime.set("parameters/chase/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))


func _on_result(val: bool):
	if player_contact:
		if val:
			anime.get("parameters/playback").travel("hurt")
		else:
			anime.get("parameters/playback").travel("leave")
		SignalManager.done_majima.emit()
	player_contact = false
	
func _on_stab_body_entered(body: Node3D) -> void:
	if body.name == "main_player" and !player_contact:
		player_contact = true
		set_math()
		stab.set_deferred("disabled",true)
