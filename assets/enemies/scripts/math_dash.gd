extends Node3D

@export var math_num = 0
@onready var anim = $AnimationPlayer
@onready var audio = $Node3D/AudioStreamPlayer3D
@onready var player_hurt = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func start(val: int):
	visible = true
	anim.speed_scale = val
	anim.play("enter")
	player_hurt = false

func chase():
	anim.speed_scale = 1
	player_hurt = false
	anim.play("activate")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "main_player":
		print("detect")
		hurt_player()

func done():
	visible = false
	print(math_num)
	SignalManager.fred_done.emit(math_num)
	player_hurt = false

func interrupt():
	visible = false
	anim.stop()
	anim.play("interrupt")
	player_hurt = true
	

func hurt_player():
	if !player_hurt:
		SignalManager.hurt_signal.emit(10)
		player_hurt = true
