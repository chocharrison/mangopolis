extends CharacterBody3D

class_name Enemy

var JUMP_VELOCITY: float
var health: float = 100
var enemy_name: String = "Despacito"
var is_banned = false

signal hurt_signal(amount:float)
signal banned_signal

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta


	move_and_slide()


func hurt(amount: float):
	health -= amount
	print(enemy_name+" is hart and has "+str(health))
	if(health <= 0):
		banned_signal.emit()

func banned():
	print(enemy_name+" ded")
	is_banned = true
