extends Node3D

@onready var is_on = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func turn_switch(val: bool):
	is_on = val
	$AudioStreamPlayer.stream = load("res://assets/interactives/sound effects/switch.mp3")
	$AudioStreamPlayer.play()
	for i in get_children():
		if i is OmniLight3D:
			i.visible = val