extends Node3D

const offset = Vector3(4,5,4)
const maximum = Vector3(24,0,24)
const multiplier = 4

@onready var melon_control = $watermelon_manager
@onready var melonkitty = $Melonkitty
@onready var player = get_tree().get_nodes_in_group("players")[0]
@onready var fsm_player = $FSM_Players
@onready var cutscenes = $intro/AnimationPlayer
@onready var BGM = $AudioStreamPlayer
@onready var backwall = $stage/back/CollisionShape3D
@onready var health_bar = $Panel/ProgressBar
@onready var phase_control = $phase_control

enum STATE {PHASE,WAIT,CUTSCENE,INTRO,FINISHED}
@onready var state = STATE.INTRO
@onready var is_follow = false

@onready var phase = 5

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
	health_bar.value = 10


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	match state:
		STATE.INTRO:
			phase_intro()
		STATE.WAIT:
			pass
		STATE.PHASE:
			if phase%2 == 0:
				if phase == 2:
					phase+=1
				else:
					phase_melon(phase)
			else:
				phase_kitty(phase)
				
				
	if state != STATE.INTRO and state != STATE.FINISHED and state != STATE.CUTSCENE:
		if !BGM.playing:
			BGM.stream = load("res://assets/boss/sound_effects/song.mp3")
			BGM.play()
	if is_follow:
		melonkitty.global_position = player.global_position



func phase_intro():
	if !BGM.playing:
		BGM.stream = load("res://assets/boss/sound_effects/intro.mp3")
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
	BGM.stream = load("res://assets/boss/sound_effects/speak_song.mp3")
	BGM.play()

func intro_2():
	cutscenes.play("intro_2")

func intro_3():
	cutscenes.play("intro_3")
	
func intro_4():
	BGM.stream = load("res://assets/boss/sound_effects/song.mp3")
	BGM.play()
	cutscenes.play("intro_4")
	
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
	cutscenes.play("intro_done")
	fsm_player.enable()
	state = STATE.PHASE
	
	
	
func set_pos(x: int,z: int,val: bool):
	if val:
		melonkitty.global_position = offset+Vector3(multiplier*x,0,multiplier*z)

func follow_player(val: bool):
	is_follow = val

func next_phase():
	phase+=1
	state = STATE.PHASE

func _on_hurt_kitty():
	phase_control.stop()
	phase_control.play("hurt")
	health_bar.value -= 1
	
func _on_watermelon_finish():
	phase+=1
	state = STATE.PHASE

func phase_kitty(i: int):
	state = STATE.WAIT
	phase_control.play("phase_"+str(i))
	
func phase_melon(i: int):
	state = STATE.WAIT
	melon_control.watermelon_phase(i)

func _on_trigger_intro_body_entered(body: Node3D) -> void:
	if(body.name == "main_player"):
		set_cutscene()
		$trigger_intro.queue_free()
