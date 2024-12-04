extends CharacterBody3D


const SPEED = 60.0
const STAB = 1.0

enum STATE {IDLE_WAIT,STAB,TIRED,CHARGE,IDLE,SMACKED,DISABLED,DEFAULT,CHARGE_START,ABOVE,STAB_START,ENTER}
@onready var state = STATE.IDLE

var direction = Vector2(0,0) 
var player_in_range = false
var is_not_timer = true
var locked_in = false
var is_interactive = false

@onready var anime: AnimationTree = get_node_or_null("AnimationTree")
@onready var anime_player: AnimationPlayer = get_node_or_null("AnimationPlayer")
@onready var line: Marker3D = get_node_or_null("line")
@onready var soundeffects: AudioStreamPlayer3D = get_node_or_null("AudioStreamPlayer")

@onready var cooldown: Timer = $Timer
@onready var player = get_tree().get_nodes_in_group("players")[0]

func _ready() -> void:
	SignalManager.interracted.connect(_on_interact)

func _physics_process(delta: float) -> void:

	handle_state_transitions(delta)
	perform_state_actions(delta)

func perform_state_actions(_delta):
	match state:
		STATE.IDLE:
			state_idle()
		STATE.STAB:
			state_stab(_delta)
		STATE.IDLE_WAIT:
			state_idle_wait()
		STATE.CHARGE:
			state_charge(_delta)
		STATE.TIRED:
			state_tired()
		STATE.SMACKED:
			state_smacked()
		STATE.DISABLED:
			state_disabled()
		STATE.CHARGE_START:
			state_charge_start()
		STATE.ABOVE:
			state_above()
		STATE.SMACKED:
			state_smacked()

func handle_state_transitions(delta):
	if state != STATE.CHARGE and state != STATE.STAB:
		velocity = Vector3(0,0,0)
	
	if player_in_range and is_not_timer:
		SignalManager.hurt_signal.emit(10)
		is_not_timer = false
		cooldown.wait_time = 0.5
		cooldown.start()

func state_disabled():
	anime.get("parameters/playback").travel("disabled")

func state_above():
	anime.get("parameters/playback").travel("above")
	move_and_slide()

func state_idle():
	set_sprite_direction(player.global_position)
	anime.get("parameters/playback").travel("idle")

func state_idle_wait():
	anime.get("parameters/playback").travel("idle_wait")

func state_stab(delta):
	set_sprite_direction(player.global_position)
	anime.get("parameters/playback").travel("stab")
	global_position = global_position.lerp(player.global_position, STAB * delta)
	if soundeffects.playing == false:
		soundeffects.stream = load("res://assets/boss/sound_effects/stab2.mp3")
		soundeffects.play()
	move_and_slide()

func state_charge(delta):
	anime.get("parameters/playback").travel("charge")
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	move_and_slide()
	
func state_charge_start():
	if !locked_in:
		set_sprite_direction(player.global_position)
		line.look_at(player.global_position+direction, Vector3.UP)

func state_tired():
	set_sprite_direction_tired(player.global_position)
	anime.get("parameters/playback").travel("tired")
	
func state_smacked():
	anime.get("parameters/playback").travel("hurt")
	velocity.x = -direction.x * SPEED
	velocity.z = -direction.z * SPEED
	move_and_slide()


func set_sprite_direction(target_position: Vector3):
	direction = (Vector3(target_position.x,0,target_position.z) - Vector3(global_position.x,0,global_position.z)).normalized()
	anime.set("parameters/idle/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
	anime.set("parameters/stab/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))

func set_sprite_direction_tired(target_position: Vector3):
	direction = (Vector3(target_position.x,0,target_position.z) - Vector3(global_position.x,0,global_position.z)).normalized()
	anime.set("parameters/tired/BlendSpace1D/blend_position",direction.z)


func play_intro():
	anime.get("parameters/playback").travel("intro")
	print("start")
	state = STATE.DEFAULT

func set_show_off():
	state = STATE.DEFAULT
	anime.get("parameters/playback").travel("show_off")
	
func set_stab():
	state = STATE.STAB

func set_disabled():
	state = STATE.DISABLED

func set_idle_wait():
	state = STATE.IDLE_WAIT

func set_charge():
	state = STATE.CHARGE

func set_locked_in():
	locked_in = true

func set_above():
	anime.get("parameters/playback").travel("above")
	state = STATE.ABOVE

func set_tired():
	state = STATE.TIRED

func set_smacked():
	state = STATE.SMACKED
	soundeffects.stop()
	soundeffects.stream = load("res://assets/boss/sound_effects/punch.mp3")
	soundeffects.play()
	set_sprite_direction(player.global_position)
	SignalManager.hit_kitty.emit()
	
func set_stab_start():
	state = STATE.STAB_START
	anime.get("parameters/playback").travel("stab_start")

func set_charge_start():
	locked_in = false
	anime.get("parameters/playback").travel("charge_start")
	state = STATE.CHARGE_START
	soundeffects.stop()
	soundeffects.stream = load("res://assets/boss/sound_effects/charge.mp3")
	soundeffects.play()

func set_exit():
	anime.get("parameters/playback").travel("exit")
	state = STATE.ENTER
	soundeffects.stop()
	soundeffects.stream = load("res://assets/boss/sound_effects/exit.mp3")
	soundeffects.play()

func set_enter():
	anime.get("parameters/playback").travel("entrance")
	state = STATE.ENTER
	soundeffects.stop()
	soundeffects.stream = load("res://assets/boss/sound_effects/enter.mp3")
	soundeffects.play()
		
func set_idle():
	state = STATE.IDLE
	
	
func _on_interact(panicked):
	if is_interactive and !panicked:
		is_interactive = false
		set_smacked()
		SignalManager.show_interact_button_signal.emit(false)

func _on_stab_body_entered(body: Node3D) -> void:
	if body.name == "main_player" and state != STATE.SMACKED:
		if state == STATE.TIRED:
			SignalManager.show_interact_button_signal.emit(true)
			is_interactive = true
		else:
			player_in_range = true
			cooldown.wait_time = 0.5
			cooldown.start()
	if state == STATE.CHARGE or state == STATE.SMACKED:
		if body.name == "side":
			direction.x = -1*direction.x
			soundeffects.stream = load("res://assets/boss/sound_effects/collide.mp3")
			soundeffects.play()
		elif body.name == "back":
			direction.z = -1*direction.z
			soundeffects.stream = load("res://assets/boss/sound_effects/collide.mp3")
			soundeffects.play()

func _on_timer_timeout() -> void:
	cooldown.stop()
	is_not_timer = true
	SignalManager.show_interact_button_signal.emit(false)
	is_interactive = false

func _on_stab_body_exited(body: Node3D) -> void:
	player_in_range = false
