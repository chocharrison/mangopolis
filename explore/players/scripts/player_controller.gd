extends Node3D

func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#print(main_player.position.distance_to(sub_player.position))
	pass		
		
		#print(camera_controller.rotation.y)
		



















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
		
