extends CharacterBody3D

class_name Player

var JUMP_VELOCITY: float
var jump_key: String = "ui_accept"
var attack_key: String = "ui_accept"
var health: float = 100
var player_name: String = "Despacito"

var is_banned = false
var is_hurt = false
var is_attack = false

signal hurt(amount:float)
signal downed
signal animationover

var anim_player: AnimationPlayer
var animated: AnimatedSprite3D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	jump(jump_key)
	attack(attack_key)
	
	if anim_player and !is_hurt and !is_attack:
		if is_on_floor():
			if anim_player.current_animation != "idle":  # Go back to idle if landed
				anim_player.play("idle")
		else:
			if anim_player.current_animation != "jump":  # Play jump if in the air
				anim_player.play("jump")

	move_and_slide()

func jump(j_key: String):
	if !is_banned and !is_hurt and !is_attack and Input.is_action_just_pressed(j_key) and is_on_floor():
		print(str(health) + " " + player_name)
		velocity.y = JUMP_VELOCITY
		anim_player.play("jump")

func attack(a_key: String):
	if !is_banned and !is_hurt and Input.is_action_just_pressed(a_key) and is_on_floor():
		print("attacks " + player_name)
		anim_player.play("attack")
		is_attack = true

func hurt_me(amount: float):
	health -= amount
	print(player_name+" is hart and has "+str(health))
	if anim_player:
		is_hurt = true  # Set hurt state
		anim_player.play("hurt")

	if(health <= 0):
		downed.emit()

func banned():
	print(player_name+" ded")
	is_banned = true
	
func animationOver():
	if animated.animation == "hurt":
		is_hurt = false
	if animated.animation == "attack":
		is_attack = false
