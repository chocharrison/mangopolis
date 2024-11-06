extends Node3D

var health = 100
const MAX_HEALTH = 100

var health_timer: Timer
var main_player:CharacterBody3D
var sub_player:CharacterBody3D
var UI: Control

@onready var is_health_timer = false
@onready var is_interrupted = false
@onready var iterations = 1

signal math_signal(int)

func _ready() -> void:
	health_timer = get_node("health_deplete")
	main_player = get_node("main_player")
	sub_player = get_node("sub_player")
	UI = get_node("ExploreUi")
	UI.set_health(health)
	connect("math_signal", Callable(self, "start_math"))
	#_set_random_timer_interval()
	
func _on_health_deplete_timeout() -> void:
	if health > 0:
		var health_decrease = randi_range(5, 10) # Randomly decrease health between 5 and 20 points
		health -= health_decrease
		health = max(0, health) # Ensure health doesn't drop below 0
		print("Health decreased by ", health_decrease, " - Current health: ", health)
		UI.set_health(health)
		is_health_timer = false

func _physics_process(delta: float) -> void:
	if is_interrupted:
		health_timer.stop()
		is_health_timer = false
		
	else:
		if !is_health_timer:
			health_timer.wait_time = randi_range(1, 5)
			health_timer.start()
			is_health_timer = true
	
	if(health <= 0):
		main_player.ded()

func pause_health_timer(val: bool):
	health_timer.paused = val

func start_math(level: int):
	var first = 0
	var second = 0
	var answer = 0
	main_player.disable_control(true)
	match level:
		0:
			first = 0
			second = randi_range(0,10)
			answer = equation(first,second,2)
		1:
			first = randi_range(0, 10)
			second = randi_range(0,10)
			answer = equation(first,second,0)
		2:
			first = randi_range(0, 10)
			second = randi_range(0,10)
			answer = equation(first,second,randi_range(0,1))
		3:
			first = randi_range(10, 100)
			second = randi_range(10,100)
			answer = equation(first,second,randi_range(0,1))
		4:
			first = randi_range(1, 10)
			second = randi_range(1,10)
			answer = equation(first,second,2)
		5:
			first = randi_range(1, 20)
			second = randi_range(1,10)
			answer = equation(first,second,2)
		6:
			first = randi_range(50, 100)
			second = randi_range(50,100)
			answer = equation(first,second,2)
	
	UI.set_first(first)
	UI.set_second(second)
	UI.set_equation(equation)
	UI.set_answer("")
	UI.math_enter()
	is_interrupted = true
		
	
func equation(first: int, second: int,equation: int) -> int:
	var answer = 0
	match equation:
		0:
			answer = first + second
		1:
			answer = first - second
		2:
			answer = first * second
	return answer
	












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
		
