extends CharacterBody3D

const SPEED = 100.0
const STAB = 1.0

enum STATE {IDLE,LAUGH,GRAB,SMACKED,GRAB_START,WALK,DISABLED,DEFAULT,INTRO}
enum STATE_POWER {ON,OFF,DISABLED}

@onready var state = STATE.DEFAULT
@onready var state_power = STATE_POWER.DISABLED

var direction = Vector2(0,0) 
var player_in_range = false
var is_not_timer = true
var locked_in = false
var is_interactive = false
@onready var target_pos = Vector3(0,0,0)


@onready var anime: AnimationTree = get_node_or_null("AnimationTree")
@onready var particle: AnimationPlayer = get_node_or_null("power_particles")
@onready var soundeffects: AudioStreamPlayer3D = $AudioStreamPlayer3D

@onready var cooldown: Timer = $Timer
@onready var grab_timer: Timer = $grab_timer
@onready var grab_start_timer: Timer = $grab_start_timer

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
		STATE.LAUGH:
			state_laugh()
		STATE.SMACKED:
			state_smacked()
		STATE.GRAB_START:
			state_grab_start()
		STATE.GRAB:
			state_grab(_delta)
		STATE.WALK:
			state_walk(_delta)
		STATE.INTRO:
			state_intro()
		STATE.DEFAULT:
			state_default()
		
func handle_state_transitions(delta):
	if state != STATE.GRAB and state != STATE.WALK:
		velocity = Vector3(0,0,0)
	
	if player_in_range and is_not_timer:
		SignalManager.hurt_signal.emit(10)
		is_not_timer = false
		cooldown.wait_time = 0.5
		cooldown.start()

func state_default():
	anime.get("parameters/playback").travel("default")

func state_intro():
	anime.get("parameters/playback").travel("intro_1")

func state_idle():
	set_sprite_direction(player.global_position)
	anime.get("parameters/playback").travel("idle")


func state_laugh():
	set_sprite_direction(player.global_position)
	anime.get("parameters/playback").travel("laugh")

func state_grab(delta):
	anime.get("parameters/playback").travel("grab")
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	move_and_slide()

func state_grab_start():
	set_sprite_direction(player.global_position)
	anime.get("parameters/playback").travel("laugh")

func state_smacked():
	anime.get("parameters/playback").travel("hurt")
	velocity.x = -direction.x * SPEED
	velocity.z = -direction.z * SPEED
	move_and_slide()

func state_walk(delta):
	set_sprite_direction_walk(target_pos)
	anime.get("parameters/playback").travel("walk")
	#global_position = global_position.lerp(target_pos, STAB * delta)
	if soundeffects.playing == false:
		soundeffects.stream = load("res://assets/freddy_boss/sounds/freddy_walk.mp3")
		soundeffects.play()
	#print(str(global_position.x-target_pos.x)+ " "+ str(global_position.y-target_pos.y)+" "+str(global_position.z-target_pos.z))
	#print(str(global_position)+" "+str(target_pos))
	#if global_position.distance_to(target_pos) < 4:
	#	state = STATE.IDLE
	move_and_slide()

func set_sprite_direction(target_position: Vector3):
	direction = (Vector3(target_position.x,0,target_position.z) - Vector3(global_position.x,0,global_position.z)).normalized()
	anime.set("parameters/idle/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
	anime.set("parameters/laugh/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
	anime.set("parameters/grab/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))

func set_sprite_direction_walk(target_position: Vector3):
	var z_direction = -(target_position.z - global_position.z)/abs((target_position.z - global_position.z))
	anime.set("parameters/walk/BlendSpace1D/blend_position",z_direction)

func set_intro():
	state = STATE.INTRO

func set_intro_2():
	state = STATE.DISABLED
	anime.get("parameters/playback").travel("intro_2")
	
func set_idle():
	state = STATE.IDLE

func set_laugh():
	state = STATE.LAUGH
	soundeffects.stop()
	soundeffects.stream = load("res://assets/freddy_boss/sounds/freddy_laugh.mp3")
	soundeffects.play()

func set_smacked():
	state = STATE.SMACKED
	soundeffects.stop()
	soundeffects.stream = load("res://assets/freddy_boss/sounds/freddy_hurt.mp3")
	soundeffects.play()
	set_sprite_direction(player.global_position)
	SignalManager.hit_kitty.emit()
	
func set_grab():
	state = STATE.GRAB
	soundeffects.stop()
	soundeffects.stream = load("res://assets/freddy_boss/sounds/grab.mp3")
	soundeffects.play()
	grab_start_timer.stop()
	grab_timer.wait_time = 0.7
	grab_timer.start()
		

func set_grab_start():
	state = STATE.GRAB_START
	soundeffects.stop()
	soundeffects.stream = load("res://assets/freddy_boss/sounds/freddy_laugh.mp3")
	soundeffects.play()
	grab_timer.stop()
	grab_start_timer.wait_time = 2
	grab_start_timer.start()

func set_walk(val: Vector3):
	target_pos = val
	state = STATE.WALK

func set_power_up():
	particle.play("particle_power_up")
	state = STATE.DISABLED
	state_power = STATE_POWER.ON
	anime.get("parameters/playback").travel("power_up")
	soundeffects.stop()
	soundeffects.stream = load("res://assets/freddy_boss/sounds/power_up.mp3")
	soundeffects.play()	

func set_power_down():
	particle.play("particle_power_down")
	state_power = STATE_POWER.OFF
	grab_start_timer.stop()

func set_vuln():
	state_power = STATE_POWER.OFF
	particle.play("vuln")


func set_invuln():
	state_power = STATE_POWER.DISABLED
	particle.play("invuln")

func set_dead():
	state_power = STATE_POWER.DISABLED
	state = STATE.DISABLED
	anime.get("parameters/playback").travel("dead")
	soundeffects.stop()
	soundeffects.stream = load("res://assets/freddy_boss/sounds/freddy_death.mp3")
	soundeffects.play()	

func _on_interact(panicked):
	if is_interactive and !panicked:
		is_interactive = false
		set_smacked()
		SignalManager.show_interact_button_signal.emit(false)


func _on_stab_or_hit_body_entered(body: Node3D) -> void:
	if body.name == "main_player" and state != STATE.SMACKED:
		if state_power == STATE_POWER.OFF:
			SignalManager.show_interact_button_signal.emit(true)
			is_interactive = true
		elif state_power == STATE_POWER.ON:
			player_in_range = true
			cooldown.wait_time = 0.5
			cooldown.start()
	
	if state == STATE.SMACKED:
		if body.name == "side":
			direction.x = -1*direction.x
			soundeffects.stream = load("res://assets/boss/sound_effects/collide.mp3")
			soundeffects.play()
		elif body.name == "back":
			direction.z = -1*direction.z
			soundeffects.stream = load("res://assets/boss/sound_effects/collide.mp3")
			soundeffects.play()
		elif body.name == "main_player":
			set_sprite_direction(player.global_position)
			soundeffects.stream = load("res://assets/boss/sound_effects/collide.mp3")
			soundeffects.play()
			
func _on_stab_or_hit_body_exited(body: Node3D) -> void:
	player_in_range = false
	is_interactive = false
	SignalManager.show_interact_button_signal.emit(false)


func _on_timer_timeout() -> void:
	cooldown.stop()
	is_not_timer = true
	is_interactive = false


func _on_grab_timer_timeout() -> void:
	if state == STATE.GRAB:
		if state_power == STATE_POWER.ON:
			set_grab_start()
		else:
			grab_timer.stop()
			set_idle()
			print("here")


func _on_grab_start_timer_timeout() -> void:
	if state == STATE.GRAB_START:
		set_grab()
