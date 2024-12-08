extends Node3D

var is_hurt = false
var is_fast_fall = false
@export var damage = 10
@onready var anim = $AnimationPlayer
@onready var detect = $detect/detect
@onready var collision = $watermelon/CollisionShape3D

@onready var audio = $AudioStreamPlayer3D

func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_hide():
	visible = false

func set_spawn(fast_fall: bool,index: int):
	index = damage
	is_fast_fall = fast_fall
	visible = true
	anim.play("spawn")
	
func set_fast_fall():
	anim.play("fast_fall")

func set_fall(speed: float = 1.0):
	anim.play("fall",-1,speed)

func set_disable():
	visible = false
	collision.set_deferred("disabled",true)
	detect.set_deferred("disabled",true)

func set_wait():
	detect.disabled = !is_fast_fall
	anim.play("wait")


func _on_watermelon_body_entered(body: Node) -> void:
	if body.name == "main_player" and !is_hurt:
		SignalManager.hurt_signal.emit(damage)
		is_hurt = true
	elif body.name == "Melonkitty":
		print("yes")
		print(body.state)
		if body.state == 1:
			body.set_tired()

func _on_detect_body_entered(body: Node3D) -> void:
	if body.name == "main_player":
		set_fall()

func play_smash():
	var rand = randi_range(1,5)
	#print(rand)
	audio.stream = load("res://assets/boss/sound_effects/smash_"+str(rand)+".mp3")
	audio.play()
