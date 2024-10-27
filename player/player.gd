extends CharacterBody3D

class_name Player

################################# Variables to be assigned by objects 
var jump_key: String = "ui_accept"
var attack_key: String = "ui_accept"
var upper_key: String = "ui_accept"

var player_name: String = "Despacito"
var health: float = 100
var JUMP_VELOCITY: float = 4

var anim_player: AnimationPlayer
var animated: AnimatedSprite3D


################################# Variables inclass

var is_banned = false
var is_hurt = false
var is_attack = false
var is_upper = false
var is_jump = false
var is_cutscene = false

################################# Signals

signal hurt(amount:float)
signal downed
signal animationover

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


	if !is_banned and !is_hurt and !is_cutscene:
		handle_actions()
		if !is_attack and !is_upper:
			if is_on_floor():
				is_jump = false
				if anim_player.current_animation != "idle":  # Go back to idle if landed
					anim_player.play("idle")
			else:
				if anim_player.current_animation != "jump":  # Play jump if in the air
					anim_player.play("jump")

	move_and_slide()


################################# controls functions

func handle_actions():
	if check_action(jump_key):
		jump()
	elif check_action(attack_key):
		attack()
	elif check_action(upper_key):
		uppercut()
	

func jump():
	is_jump = true
	print(str(health) + " " + player_name)
	velocity.y = JUMP_VELOCITY
	anim_player.play("jump")

func attack():
	is_attack = true
	print("attacks " + player_name)
	anim_player.play("attack")
		
func uppercut():
	is_upper = true
	print("uppercut " + player_name)
	anim_player.play("uppercut")


func check_action(key):
	if !is_upper and !is_attack and !is_jump and Input.is_action_just_pressed(key):
		return true
	return false


################################# signal functions
func hurt_me(amount: float):
	health -= amount
	print(player_name+" is hart and has "+str(health))
	is_hurt = true
	anim_player.play("hurt")

	if(health <= 0):
		downed.emit()

func banned():
	print(player_name+" ded")
	is_banned = true	

func animationOver():
	match animated.animation:
		"hurt":
			is_hurt = false
		"attack":
			is_attack = false
		"uppercut":
			is_upper = false
