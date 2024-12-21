extends Node3D

@onready var anim = $AnimationPlayer
@onready var not_entered = true
@export var scene: String


func open_door():
	anim.play("unlock")

func change():
	get_tree().change_scene_to_file(scene)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "main_player":
		if not_entered:
			not_entered = false
			anim.play("change")
			SignalManager.grunt_inactive.emit()
