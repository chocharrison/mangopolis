extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


#if Input.is_action_just_pressed("turn_left"):
#			angle+=90
#			i+=1
#			if(i>3):
#				i = 0
#			main_player.set_disorientation(i)
#		elif Input.is_action_just_pressed("turn_right"):
#			angle-=90
#			i-=1
#			if(i<0):
#				i = 3
#			main_player.set_disorientation(i)
#		camera_controller.rotation.y = lerp_angle(camera_controller.rotation.y,deg_to_rad(angle),0.1)


#var input_mappings = [
#	["ui_left", "ui_right", "ui_up", "ui_down"],  # Default
#	["ui_up", "ui_down", "ui_right", "ui_left"],  # Inverted Y-axis
#	["ui_right", "ui_left", "ui_down", "ui_up"],  # Rotated 90 degrees clockwise
#	["ui_down", "ui_up", "ui_left", "ui_right"]   # Inverted X-axis
#]
#var input_index = 0
#func set_disorientation(i: int):
#	input_index = i
#	var current_mapping = input_mappings[input_index]
