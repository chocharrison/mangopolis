extends Node3D

@onready var is_interactive = false
@export var toilet_number = 0
@onready var pos = Vector3(0,0,0)

@onready var detect = $Area3D/CollisionShape3D
@onready var toilet = $Node3D/seat
@onready var anime = $AnimationPlayer
@onready var majima = $majima
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.interracted.connect(_on_interact)
	majima.visible = false
	majima.set_disabled()
	pos = majima.position 
	detect.set_deferred("disabled",true)

func _on_interact(panicked):
	if is_interactive and !panicked:
		detect.set_deferred("disabled",true)
		anime.play("close")
		SignalManager.closed_majima.emit(toilet_number)

func defeat():
	
	anime.play("defeat")

func interuppted_majima():
	anime.stop()
	detect.set_deferred("disabled",true)
	anime.play("close")
	#SignalManager.closed_majima.emit(toilet_number)

func suspense_majima():
	anime.stop()
	detect.set_deferred("disabled",false)
	anime.play("majima")
	
func play_majima():
	toilet.frame = 0
	detect.set_deferred("disabled",true)
	majima.visible = true
	majima.set_chase()
	majima.position = pos
	SignalManager.Majima_popped.emit()

func intro_majima():
	anime.play("intro")
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "main_player":
		SignalManager.show_interact_button_signal.emit(true)
		is_interactive = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "main_player":
		SignalManager.show_interact_button_signal.emit(false)
		is_interactive = false
