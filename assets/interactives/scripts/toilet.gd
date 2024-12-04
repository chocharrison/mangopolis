extends Node3D

@onready var is_interactive = false
@onready var detect = $Area3D/CollisionShape3D
@onready var toilet = $Node3D/seat
@onready var anime = $AnimationPlayer
@onready var majima = $Majima2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.interracted.connect(_on_interact)
	majima.visible = false
	majima.set_disabled()

func _on_interact(panicked):
	if is_interactive and !panicked:
		detect.disabled = true
		anime.play("close")

func interuppted_majima():
	anime.stop()

func suspense_majima():
	detect.disabled = false
	anime.play("majima")
	
func play_majima():
	toilet.frame = 0
	var majima_copy = majima
	majima_copy.visible = true
	majima_copy.set_chase()
	SignalManager.Majima_popped.emit(self.name)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "main_player":
		SignalManager.show_interact_button_signal.emit(true)
		is_interactive = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "main_player":
		SignalManager.show_interact_button_signal.emit(false)
		is_interactive = false
