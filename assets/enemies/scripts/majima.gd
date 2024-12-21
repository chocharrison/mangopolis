extends Node3D

const SPEED = 10

@onready var anime = get_node("AnimationTree")
@onready var soundeffects = get_node("AudioStreamPlayer")
@onready var stab = $stab/collide
@onready var detect = $detect/detect
@onready var notebook_number = 2

enum STATE {IDLE, CHASE, MATH, DISABLED, ENABLED}

@onready var state = STATE.ENABLED
@onready var player = get_tree().get_nodes_in_group("players")[0]
@onready var player_found = false
@onready var player_contact = false
@onready var direction = Vector3(0,0,0)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if notebook_number in SaveStates.notebooks:
		queue_free()
	SignalManager.math_success.connect(_on_result)


func _physics_process(_delta: float) -> void:

	handle_state_transitions()
	perform_state_actions(_delta)


func perform_state_actions(_delta):
	match state:
		STATE.IDLE:
			state_idle()
		STATE.CHASE:
			state_chase(_delta)


func handle_state_transitions():
	if state == STATE.DISABLED:
		return

func state_idle():
	anime.get("parameters/playback").travel("default")
	stab.disabled = true

func state_chase(_delta):
	anime.get("parameters/playback").travel("chase")
	set_sprite_direction(player.global_position)
	global_position = global_position.lerp(player.global_position, SPEED * _delta)
	if soundeffects.playing == false:
		soundeffects.stream = load("res://assets/enemies/sound/stab.mp3")
		print("no")
		soundeffects.play()

func set_chase():
	#await wait(1)
	state = STATE.CHASE
	anime.get("parameters/playback").travel("chase")
	soundeffects.stream = load("res://assets/enemies/sound/majima.mp3")
	soundeffects.play()

func set_disabled():
	state = STATE.DISABLED
	anime.get("parameters/playback").travel("default")
	stab.disabled = true
	detect.disable = true

func set_found():
	state = STATE.DISABLED
	stab.disabled = false
	anime.get("parameters/playback").travel("found")
	soundeffects.stream = load("res://assets/enemies/sound/majima-sensor.mp3")
	soundeffects.play()

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

func _on_stab_body_entered(body: Node3D) -> void:
	if body.name == "main_player" and !player_contact:
		player_contact = true
		set_math()

func _on_detect_body_entered(body: Node3D) -> void:
	if body.name == "main_player" and !player_found:
		player_found = true
		set_found()

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
