extends CharacterBody3D

class_name Enemy

var enemy_name: String = "Despacito"
var health: float = 100
var MAX_HEALTH: float = 100

var is_banned = false

enum PHASE {ATTACK , DEFEND, DED, MISC}

var phase: PHASE = PHASE.DEFEND

var anim_player: AnimationPlayer
var animated: AnimatedSprite3D

signal hurt_signal(amount:float)
signal banned_signal
signal animation_over_signal
signal phase_switch_signal(phase:int)

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

func phase_switch(change: int):
	phase = change
	
