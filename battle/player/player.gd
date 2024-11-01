extends CharacterBody3D

class_name Player

################################# Variables to be assigned by objects 
var jump_key: String = "ui_accept"
var attack_key: String = "ui_accept"
var upper_key: String = "ui_accept"

var player_name: String = "Despacito"
var health: float = 100
var MAX_HEALTH: float = 100
var JUMP_VELOCITY: float = 4

var anim_player: AnimationPlayer
var animated: AnimatedSprite3D


################################# Variables inclass

var is_banned = false
var is_hurt = false
var is_attack = false
var is_upper = false
var is_jump = false
var is_stunned = false

var is_select = false
var is_menu = false

enum PHASE {ATTACK , DEFEND, DED, MISC}

var phase: PHASE = PHASE.ATTACK 

enum ACTION { JUMP, PUNCH, ITEMS, SPECIAL, RUN }
var current_action: ACTION = ACTION.JUMP

################################# Signals

signal hurt_signal(change:float)
signal banned_signal
signal animation_over_signal
signal phase_switch_signal(phase:int)
signal health_change
################################# main functions

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		is_jump = true

	match phase:
		PHASE.DEFEND:
			defend()
		PHASE.ATTACK:
			attack()
		PHASE.MISC:
			is_hurt = false
			is_upper = false
			is_attack = false

	move_and_slide()


################################# controls functions
func attack():
	if can_perform_action() and !is_attack and !is_upper:
		if !is_select:
			selecting_action()
			if anim_player.current_animation != "select":  # Go back to idle if landed
				anim_player.play("select")
		
		else:
			executing_action()
			if is_on_floor():
				is_jump = false
				if anim_player.current_animation != "idle":  # Go back to idle if landed
					anim_player.play("idle")
			else:
				if anim_player.current_animation != "jump":  # Play jump if in the air
					anim_player.play("jump")



func selecting_action():
	if Input.is_action_just_pressed("ui_left"):
		current_action = int(fposmod((current_action - 1), ACTION.size()))
		print(current_action)
		
	if Input.is_action_just_pressed("ui_right"):
		current_action = int(fposmod((current_action + 1), ACTION.size()))
		print(current_action)
		
	if Input.is_action_just_pressed(jump_key):
		print(current_action)
		jump()
		is_select = true

func executing_action():
	if !is_menu:
		match current_action:
			ACTION.JUMP:
				jumping_qte()
			ACTION.PUNCH:
				jumping_qte()
			ACTION.ITEMS:
				jumping_qte()
			ACTION.SPECIAL:
				jumping_qte()
			ACTION.RUN:
				jumping_qte()
	if Input.is_action_just_pressed(attack_key):
		is_select = false
		is_menu = false

func jumping_qte():
	is_menu = true
	print(player_name+ " selected jump")
		

############################################## defense moves
func defend():
	if can_perform_action():
		handle_actions()
		if !is_attack and !is_upper:
			if is_on_floor():
				is_jump = false
				if anim_player.current_animation != "idle":  # Go back to idle if landed
					anim_player.play("idle")
			else:
				if anim_player.current_animation != "jump":  # Play jump if in the air
					anim_player.play("jump")


func handle_actions():
	if check_action(jump_key):
		jump()
	elif check_action(attack_key):
		punch()
	elif check_action(upper_key):
		uppercut()
	

func jump():
	is_jump = true
	print(str(health) + " " + player_name)
	velocity.y = JUMP_VELOCITY
	anim_player.play("jump")

func punch():
	is_attack = true
	print("attacks " + player_name)
	anim_player.play("attack")
		
func uppercut():
	is_upper = true
	print("uppercut " + player_name)
	anim_player.play("uppercut")


func check_action(key):
	return (!is_upper and !is_attack and !is_jump and Input.is_action_just_pressed(key))

func can_perform_action() -> bool:
	return not (is_banned or is_hurt or is_stunned)


################################# signal functions
func hurt(amount: float):
	if(phase != PHASE.DED):
		health -= amount
		print(player_name+" is hart and has "+str(health))
		is_hurt = true
		anim_player.play("hurt")
	
		if(health <= 0):
			health = 0
			emit_signal("banned_signal", self)
		else:
			emit_signal("health_change", self)

func banned():
	print(player_name+" ded")
	is_banned = true
	phase = PHASE.DED	

func animationOver():
	match animated.animation:
		"hurt":
			is_hurt = false
		"attack":
			is_attack = false
		"uppercut":
			is_upper = false

func phase_switch(change: int):
	phase = change

########################### ui changes
func cancel_menu():
	is_select = false
	is_menu = false
	
func get_health_info():
	return [health , MAX_HEALTH]
