extends CharacterBody3D


const SPEED = 1.0

const waiter = 10

@onready var anime = get_node("AnimationTree")
@onready var cooldown = get_node("cooldown")
@onready var remover = get_node("remover")
@onready var soundeffects = get_node("AudioStreamPlayer")



@onready var direction = Vector3(0,0,0)
 
##################################### States
enum STATE {IDLE, CHASE, DISABLED, ENABLED}
@onready var state = STATE.ENABLED
@onready var player = get_tree().get_nodes_in_group("players")[0]
@onready var player_in_range = false
@onready var is_not_timer = false


func _ready() -> void:
	set_enter()
	SignalManager.math_in_session.connect(_in_math)

func _physics_process(_delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * _delta

	handle_state_transitions()
	perform_state_actions(_delta)
	move_and_slide()

func perform_state_actions(_delta):
	match state:
		STATE.IDLE:
			state_idle()
		STATE.CHASE:
			state_chase(_delta)

func handle_state_transitions():
	if state == STATE.DISABLED:
		return
	set_sprite_direction(player.global_position)
	if player_in_range and is_not_timer:
		SignalManager.hurt_signal.emit(10)
		is_not_timer = false
		cooldown.wait_time = 0.5
		cooldown.start()

func state_idle():
	anime.get("parameters/playback").travel("idle")

func state_chase(_delta):
	anime.get("parameters/playback").travel("chase")
	global_position = global_position.lerp(player.global_position, SPEED * _delta)
	if soundeffects.playing == false:
		soundeffects.stream = load("res://assets/enemies/sound/stab.mp3")
		soundeffects.play()

func set_enter():
	anime.get("parameters/playback").travel("enter")
	remover.wait_time = waiter
	remover.start()
	soundeffects.stop()
	soundeffects.stream = load("res://assets/enemies/sound/smoke.mp3")
	soundeffects.play()
	
func set_exit():
	state = STATE.DISABLED
	anime.get("parameters/playback").travel("exit")
	soundeffects.stop()
	soundeffects.stream = load("res://assets/enemies/sound/smoke.mp3")
	soundeffects.play()

func _in_math(val: bool):
	if(val):
		set_exit()

func set_idle():
	state = STATE.IDLE

func set_chase():
	state = STATE.CHASE

func set_sprite_direction(target_position: Vector3):
	direction = (Vector3(target_position.x,0,target_position.z) - Vector3(position.x,0,position.z)).normalized()
	anime.set("parameters/idle/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
	anime.set("parameters/chase/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))


func _on_detect_body_entered(body: Node3D) -> void:
	if body.name == "main_player" and state ==STATE.IDLE:
		set_chase()


func _on_cooldown_timeout() -> void:
	cooldown.stop()
	is_not_timer = true


func _on_stab_body_entered(body: Node3D) -> void:
	if body.name == "main_player":
		player_in_range = true
		cooldown.wait_time = 0.5
		cooldown.start()


func _on_stab_body_exited(body: Node3D) -> void:
	if body.name == "main_player":
		player_in_range = false


func _on_remover_timeout() -> void:
	print("removed")
	set_exit()
