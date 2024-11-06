extends Node3D

var health = 100
const MAX_HEALTH = 100

var health_timer: Timer
var math_timer: Timer
var main_player:CharacterBody3D
var sub_player:CharacterBody3D
var UI: Control

const MATH_TIMER = 30
const MIN_MATH_TIMER = 6

@onready var answer = 0

@onready var is_health_timer = false
@onready var is_interrupted = false
@onready var is_math = false

@onready var iterations = 0

func _ready() -> void:
	health_timer = get_node("health_deplete")
	math_timer = get_node("math_timer")
	main_player = get_node("main_player")
	sub_player = get_node("sub_player")
	UI = get_node("ExploreUi")
	UI.set_health(health)
	#_set_random_timer_interval()
	
func _on_health_deplete_timeout() -> void:
	if health > 0:
		var health_decrease = randi_range(3, 7) # Randomly decrease health between 5 and 20 points
		health -= health_decrease
		health = max(0, health) # Ensure health doesn't drop below 0
		print("Health decreased by ", health_decrease, " - Current health: ", health)
		UI.set_health(health)
		is_health_timer = false

func _physics_process(delta: float) -> void:
	if is_interrupted:
		health_timer.stop()
		is_health_timer = false
		if is_math:
			var percent_time = (math_timer.get_time_left()/math_timer.get_wait_time())*100
			UI.set_timer(percent_time)
		
	else:
		if !is_health_timer:
			health_timer.wait_time = randi_range(5, 15)
			health_timer.start()
			is_health_timer = true
	
	if(health <= 0):
		main_player.ded()

func pause_health_timer(val: bool):
	health_timer.paused = val

func start_math(level: int):
	var first = 0
	var second = 0
	set_interrupted(true)
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
			answer = equation(first,second,1)
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
	print(first,second,answer)
	UI.set_first(first)
	UI.set_second(second)
	UI.math_enter()
	is_math = true
	math_timer.wait_time = max(MIN_MATH_TIMER,MATH_TIMER * pow(0.9,iterations))
	iterations+=1
	math_timer.start()
	
	
		
	
func equation(first: int, second: int,equation: int) -> int:
	var answer = 0
	match equation:
		0:
			answer = first + second
			UI.set_equation("+")
		1:
			answer = first - second
			UI.set_equation("-")
		2:
			answer = first * second
			UI.set_equation("x")
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
		
func set_interrupted(val: bool):
	is_interrupted = val
	main_player.disable_control(val)
	

func _on_hub_math_signal(level: int) -> void:
	start_math(level)


func _on_answer_text_submitted(new_text: String) -> void:
	var get_answer = int(new_text)
	if(get_answer == answer):
		UI.math_success()
	else:
		UI.math_failure()
		iterations = max(iterations-5,0)
		health-=20
		UI.set_health(health)
	set_interrupted(false)
		


func _on_math_timer_timeout() -> void:
	UI.math_failure()
	is_interrupted = false
	main_player.disable_control(false)
	iterations = max(iterations-5,0)
