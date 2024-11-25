extends Node3D

var is_hurt = false
var is_fast_fall = false
@export var damage = 10
@onready var anim = $AnimationPlayer
@onready var detect = $detect/detect
@onready var audio = $AudioStreamPlayer3D

func _ready() -> void:
	anim.play("spawn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setup(fast_fall: bool,index: int):
	index = damage
	is_fast_fall = fast_fall
	
func set_fast_fall():
	anim.play("fast_fall")

func set_fall(speed: float = 1.0):
	anim.play("fall",-1,speed)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fall" or anim_name == "fast_fall":
		queue_free()
	elif anim_name == "spawn":
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
