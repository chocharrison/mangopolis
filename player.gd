extends CharacterBody3D

class_name Player

var JUMP_VELOCITY: float
var jump_key: String = "ui_accept"
var health: float = 100
var player_name: String = "Despacito"
var is_banned = false

signal hurt(amount:float)
signal downed

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	jump(jump_key)

	move_and_slide()

func jump(j_key: String):
	if !is_banned and Input.is_action_just_pressed(j_key) and is_on_floor():
		print(str(health) + " " + player_name)
		velocity.y = JUMP_VELOCITY

func hurt_me(amount: float):
	health -= amount
	print(player_name+" is hart and has "+str(health))
	if(health <= 0):
		downed.emit()

func banned():
	print(player_name+" ded")
	is_banned = true
