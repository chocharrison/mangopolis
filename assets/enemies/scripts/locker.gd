extends Node3D

const SPEED = 2

var is_majima = false
var is_health = false
var is_notebook = false
var is_lobster = false
var id_or_quantity = 1

@onready var stab = $stab/collide
@onready var detect = $detect/detect
@onready var anime = $AnimationPlayer
@onready var majima = $AudioStreamPlayer
@onready var soundeffects = $AudioStreamPlayer3D

enum STATE {IDLE, CHASE, MATH, DISABLED, ENABLED, OPEN}

@onready var state = STATE.ENABLED
@onready var player = get_tree().get_nodes_in_group("players")[0]
@onready var player_found = false
@onready var player_contact = false
@onready var is_interactive = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.math_success.connect(_on_result)
	SignalManager.interracted.connect(_on_interact)
	stab.disabled = true


func _physics_process(_delta: float) -> void:

	handle_state_transitions()
	perform_state_actions(_delta)


func perform_state_actions(_delta):
	match state:
		STATE.IDLE:
			state_idle()
		STATE.CHASE:
			state_chase(_delta)
		STATE.OPEN:
			state_opened()
		
func make_locker(val1: int,val2: int):
	match val1:
		1:
			is_majima = true
			is_notebook = false
			is_health = false
			is_lobster = false
		2:
			is_majima = false
			is_notebook = true
			is_health = false
			is_lobster = false
			id_or_quantity = val2
		3:
			is_majima = false
			is_notebook = false
			is_health = true
			is_lobster = false
			id_or_quantity = val2
		4:
			is_majima = false
			is_notebook = false
			is_health = false
			is_lobster = true
	

func handle_state_transitions():
	if state == STATE.DISABLED:
		return


func _on_interact(panicked):
	if is_interactive and !panicked:
		detect.disabled = true
		if is_majima:
			set_found()
		else:
			set_open()

func state_opened():
	anime.play("opened")

func state_idle():
	anime.play("default")
	stab.disabled = true

func state_chase(_delta):
	if !anime.is_playing():
		anime.play("chase")
	print(global_position)
	print(player.name)
	global_position = global_position.lerp(player.global_position, SPEED * _delta)
	if soundeffects.playing == false:
		soundeffects.stream = load("res://assets/enemies/sound/metal.mp3")
		soundeffects.play()
		
		
func set_open():
	anime.play("open")
	detect.disabled = true
	soundeffects.stream = load("res://assets/enemies/sound/locker.mp3")
	soundeffects.play()
	
func set_opened_result():
		if is_notebook:
			SaveStates.get_notebook(id_or_quantity)
			SignalManager.collected_notebooks_signal.emit()
		elif is_health:
			print("here")
			SignalManager.collected_healthpotions_signal.emit(id_or_quantity)
		elif is_lobster:
			SignalManager.do_lobster.emit()
		state = STATE.OPEN

func set_chase():
	majima.stream = load("res://assets/enemies/sound/majima.mp3")
	majima.play()
	await wait(1)
	stab.disabled = false
	state = STATE.CHASE
	anime.play("chase")

func set_disabled():
	state = STATE.DISABLED
	anime.play("default")
	stab.disabled = true
	detect.disable = true

func set_found():
	state = STATE.DISABLED
	anime.play("majima")
	soundeffects.stream = load("res://assets/enemies/sound/locker.mp3")
	soundeffects.play()

	
func set_math():
	state = STATE.MATH
	SignalManager.signal_math.emit(3, 60,0)


func _on_result(val: bool):
	if player_contact:
		if val:
			anime.play("hurt")
		else:
			anime.play("exit")


func _on_stab_body_entered(body: Node3D) -> void:
	if body.name == "main_player" and !player_contact:
		player_contact = true
		set_math()


func _on_detect_body_entered(body: Node3D) -> void:
	if body.name == "main_player":
		SignalManager.show_interact_button_signal.emit(true)
		is_interactive = true


func _on_detect_body_exited(body: Node3D) -> void:
	if body.name == "main_player":
		SignalManager.show_interact_button_signal.emit(false)
		is_interactive = false

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
