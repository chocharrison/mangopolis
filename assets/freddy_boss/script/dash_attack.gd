extends Node3D

@export var fred_num = 0
var already_hurt = false

@onready var stab_collisions = $Node3D/Area3D/CollisionShape3D
@onready var wall_collisions = $Node3D/MeshInstance3D/StaticBody3D/CollisionShape3D
@onready var anim = $AnimationPlayer
@onready var audio = $Node3D/AudioStreamPlayer3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wall_collisions.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func start(val: int):
	visible = true
	audio.pitch_scale = val
	anim.speed_scale = val
	anim.play("start") 
	already_hurt = false

func chase():
	audio.pitch_scale = 1
	anim.speed_scale = 1
	anim.play("chase")
	
func interupt():
	visible = false
	anim.stop()
	audio.stop()
	stab_collisions.set_deferred("disabled",true)
	wall_collisions.set_deferred("disabled",true)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "main_player":
		hurt_player()

func done():
	SignalManager.fred_done.emit(fred_num)
	anim.speed_scale = 1

func hurt_player():
	if !already_hurt:
		SignalManager.hurt_signal.emit(10)
		already_hurt = true
