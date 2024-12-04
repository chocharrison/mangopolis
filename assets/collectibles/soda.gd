extends Node3D

@onready var cooldown = true

@onready var sprit = $StaticBody3D/AnimatedSprite3D
@onready var timer = $StaticBody3D/Timer
@onready var body = $StaticBody3D
@onready var anim = $AnimationPlayer
@onready var majima = $Majima2

@onready var x_velo = 0
@onready var z_velo = 0

@export var soda_number = 0
@export var is_majima = false
@onready var not_active = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.done_soda.connect(done_soda)
	x_velo = randf_range(-3,3)
	z_velo = randf_range(10,20)
	majima.visible = false
	majima.set_disabled()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if cooldown:
		body.velocity = Vector3(x_velo,0,z_velo)
		print(body.velocity)
		body.move_and_slide()
	else:
		body.velocity = Vector3(0,0,0)

func setup(i: int,val: bool):
	sprit.frame = i
	soda_number = i
	is_majima = val

func drink():
	if !is_majima:
		if soda_number == 0:
			SignalManager.collected_healthpotions_signal.emit(1)
		elif soda_number == 1:
			SignalManager.heal_signal.emit(10)
		elif soda_number == 2:
			SignalManager.hurt_signal.emit(10)
		queue_free()
	else:
		anim.play("majima")
	print("drink")

func done_soda():
	queue_free()

func play_majima():
	sprit.frame = soda_number
	majima.visible = true
	majima.set_chase()

func _on_timer_timeout() -> void:
	cooldown = false
	timer.stop()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "main_player":
		if !cooldown and not_active:
			not_active = false
			drink()


func _on_static_body_3d_body_entered(body: Node) -> void:
	if body.name == "invisible":
		x_velo = -1 * x_velo
