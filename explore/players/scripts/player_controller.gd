extends Node3D

var health = 100
const MAX_HEALTH = 100

var timer: Timer
var main_player:CharacterBody3D
var sub_player:CharacterBody3D
var UI: Control

func _ready() -> void:
	timer = get_node("health_deplete")
	main_player = get_node("main_player")
	sub_player = get_node("sub_player")
	UI = get_node("ExploreUi")
	UI.set_health(health)
	#_set_random_timer_interval()

# Sets a random interval for the timer and starts it
func _set_random_timer_interval() -> void:
	var random_interval = randi_range(1, 5) # Set random time between 1 to 5 seconds
	timer.wait_time = random_interval
	timer.start()

# Function to deplete health and restart the timer

func _on_health_deplete_timeout() -> void:
	if health > 0:
		var health_decrease = randi_range(5, 10) # Randomly decrease health between 5 and 20 points
		health -= health_decrease
		health = max(0, health) # Ensure health doesn't drop below 0
		print("Health decreased by ", health_decrease, " - Current health: ", health)
		UI.set_health(health)
	# Restart the timer with a new random interval
	_set_random_timer_interval()
	
	if(health <= 0):
		main_player.is_ded = true

func _physics_process(delta: float) -> void:
	pass

func pause_health_timer(val: bool):
	timer.paused = val















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
		
