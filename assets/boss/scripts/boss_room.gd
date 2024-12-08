extends Node3D

const offset = Vector3(4,5,4)
const maximum = Vector3(24,0,24)
const multiplier = 4

@export var unknown_1: PackedScene
@export var unknown_2: PackedScene

@onready var melon_control = $watermelon_manager
@onready var melonkitty = $Melonkitty
@onready var player = get_tree().get_nodes_in_group("players")[0]
@onready var fsm_player = $FSM_Players
@onready var cutscenes = $intro/AnimationPlayer
@onready var BGM = $AudioStreamPlayer
@onready var backwall = $stage/MeshInstance3D9/back/CollisionShape3D
@onready var backwall2 = $stage/MeshInstance3D11/back/CollisionShape3D
@onready var remove_wall = $stage/Node3D

@onready var health_bar = $Panel/ProgressBar
@onready var phase_control = $phase_control
@onready var lights = $lights

@onready var spawn = $spawner

enum STATE {PHASE,WAIT,CUTSCENE,INTRO,FINISHED}
@onready var state = STATE.INTRO
@onready var is_follow = false

@onready var phase = 7
const max_phase = 15

@onready var melon_phases = [3,5,8]
@onready var kitty_phases = [1,2,4,6,7]
#1,2,4,6,7

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fsm_player.state_health_timer_disable()
	SignalManager.hit_kitty.connect(_on_hurt_kitty)
	SignalManager.finish_watermelon.connect(_on_watermelon_finish)
	if SaveStates.first_meet:
		melonkitty.set_disabled()
	else:
		melonkitty.set_show_off()
	backwall.disabled = true
	backwall2.disabled = true
	health_bar.value = 7
	lights.turn_switch(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	match state:
		STATE.INTRO:
			phase_intro()
		STATE.WAIT:
			pass
		STATE.PHASE:
			phases(phase)
				
	if state != STATE.INTRO and state != STATE.FINISHED and state != STATE.CUTSCENE:
		if !BGM.playing:
			BGM.stream = load("res://assets/boss/sound_effects/alternate_song.mp3")
			BGM.play()
	if is_follow:
		melonkitty.global_position = player.global_position



func phase_intro():
	if !BGM.playing:
		BGM.stream = load("res://assets/boss/sound_effects/alternate_intro.mp3")
		BGM.play()

func set_cutscene():
	fsm_player.disable()
	state = STATE.CUTSCENE
	if SaveStates.first_meet:
		intro()
		SaveStates.first_meet = false
	else:
		intro_4()
	
func intro():
	cutscenes.play("intro")
	BGM.stream = load("res://assets/boss/sound_effects/alternate_song_speak.mp3")
	BGM.play()

func intro_2():
	cutscenes.play("intro_2")

func intro_3():
	cutscenes.play("intro_3")
	lights.turn_switch(true)
	
func intro_4():
	BGM.stream = load("res://assets/boss/sound_effects/alternate_song.mp3")
	BGM.play()
	cutscenes.play("intro_4")
	lights.turn_switch(true)
	
func intro_5():
	cutscenes.play("intro_5")

func intro_6():
	cutscenes.play("intro_6")

func intro_7():
	cutscenes.play("intro_7")

func intro_8():
	cutscenes.play("intro_8")

func intro_done():
	backwall.disabled = false
	backwall2.disabled = true
	remove_wall.queue_free()
	cutscenes.play("intro_done")
	fsm_player.enable()
	state = STATE.PHASE


func add_unknown_chase(x: int,z: int):
	var setup_unknown = unknown_1.instantiate()
	setup_unknown.position = offset+Vector3(multiplier*x,0,multiplier*z)
	spawn.add_child(setup_unknown)
	setup_unknown.set_chase()

func add_unknown_charge(x: int,z: int):
	var setup_unknown = unknown_2.instantiate()
	setup_unknown.position = offset+Vector3(multiplier*x,0,multiplier*z)
	spawn.add_child(setup_unknown)


func set_pos(x: int,z: int,val: bool):
	if val:
		melonkitty.global_position = offset+Vector3(multiplier*x,0,multiplier*z)

func follow_player(val: bool):
	is_follow = val



func next_phase():
	phase+=1
	state = STATE.PHASE
	phase_control.stop()
	melon_control.set_follow_player(false)



func _on_hurt_kitty():	
	phase_control.stop()
	if max_phase <= phase:
		phase = STATE.FINISHED
	else:
		phase_control.play("hurt")
	health_bar.value -= 1
	
func _on_watermelon_finish():
	next_phase()

func phases(i: int):
	
	state = STATE.WAIT
	
	if i in kitty_phases:
		phase_control.play("phase_"+str(i))
	if i in melon_phases:
		melon_control.watermelon_phase(i)
	



func _on_trigger_intro_body_entered(body: Node3D) -> void:
	if(body.name == "main_player"):
		set_cutscene()
		$trigger_intro.queue_free()
