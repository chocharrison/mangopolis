extends Node3D

@onready var is_interactive = false
@onready var detect = $Area3D/CollisionShape3D
@onready var toilet = $Node3D/seat
@onready var anime = $AnimationPlayer
@onready var majima = $Majima2
@onready var setup = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.interracted.connect(_on_interact)
	majima.visible = false
	majima.set_disabled()

func _on_interact(panicked):
	if is_interactive and !panicked:
		detect.disabled = true
		if setup == 1:
			anime.play("pikmin")
		elif setup == 2:
			anime.play("majima")
		else:
			anime.play("empty")
	
func set_toilet(val: int):
	setup = val

func play_majima():
	toilet.frame = 0
	majima.visible = true
	majima.set_chase()

func play_pikmin():
	SignalManager.increase_pikmin_count.emit()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "main_player":
		SignalManager.show_interact_button_signal.emit(true)
		is_interactive = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "main_player":
		SignalManager.show_interact_button_signal.emit(false)
		is_interactive = false
