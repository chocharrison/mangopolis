extends CharacterBody3D

const SPEED = 20.0

const waiter = 10

@onready var anime = get_node("AnimationPlayer")
@onready var cooldown = get_node("cooldown")
@onready var remover = get_node("remover")
@onready var soundeffects = get_node("AudioStreamPlayer")
@onready var line: Marker3D = get_node_or_null("line")
@onready var direction = Vector3(0,0,0)

enum STATE {CHARGE, CHARGE_START, DISABLED, ENABLED}
@onready var state = STATE.ENABLED
@onready var player = get_tree().get_nodes_in_group("players")[0]
@onready var player_in_range = false
@onready var is_not_timer = false
@onready var locked_in = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_enter()
	SignalManager.math_in_session.connect(_in_math)


func _physics_process(_delta: float) -> void:

	handle_state_transitions()
	perform_state_actions(_delta)
	move_and_slide()

func perform_state_actions(_delta):
	match state:
		STATE.CHARGE:
			state_charge(_delta)
		STATE.CHARGE_START:
			state_charge_start()

func handle_state_transitions():
	if state == STATE.DISABLED:
		return
	if player_in_range and is_not_timer:
		SignalManager.hurt_signal.emit(10)
		is_not_timer = false
		cooldown.wait_time = 0.5
		cooldown.start()

func state_charge(delta):
	anime.play("charge")
	print(velocity)
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	
func state_charge_start():
	if !locked_in:
		direction = (Vector3(player.global_position.x,0,player.global_position.z) - Vector3(global_position.x,0,global_position.z)).normalized()
		line.look_at(player.global_position+direction, Vector3.UP)

func set_locked_in():
	locked_in = true

func set_exit():
	state = STATE.DISABLED
	anime.play("exit")
	soundeffects.stop()
	soundeffects.stream = load("res://assets/enemies/sound/smoke.mp3")
	soundeffects.play()

func set_enter():
	anime.play("enter")
	remover.wait_time = waiter
	remover.start()
	soundeffects.stop()
	soundeffects.stream = load("res://assets/enemies/sound/smoke.mp3")
	soundeffects.play()

func set_charge_start():
	locked_in = false
	anime.play("charge_start")
	state = STATE.CHARGE_START

func set_charge():
	state = STATE.CHARGE


func _in_math(val: bool):
	if(val):
		set_exit()


func _on_cooldown_timeout() -> void:
	cooldown.stop()
	is_not_timer = true


func _on_stab_body_entered(body: Node3D) -> void:
	if body.name == "main_player":
		player_in_range = true
		cooldown.wait_time = 0.5
		cooldown.start()
	elif body.name == "side_wall":
		direction.x = -1*direction.x
	elif body.name == "back_wall":
		direction.z = -1*direction.z


func _on_stab_body_exited(body: Node3D) -> void:
	player_in_range = false


func _on_remover_timeout() -> void:
	set_exit()
