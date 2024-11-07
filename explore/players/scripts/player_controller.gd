extends Node3D

@export var page_array = [0,2]

var health = 100
const MAX_HEALTH = 100
var health_potion = 3

var health_timer: Timer
var math_timer: Timer
var main_player:CharacterBody3D
var sub_player:CharacterBody3D
var UI: Control

const MATH_TIMER = 30
const MIN_MATH_TIMER = 6

const MAX_PAGE = 10

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
	UI.set_health_potion(health_potion)
	UI.set_notebook_array(page_array.size(),MAX_PAGE)
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
		if Input.is_action_just_pressed("health") and health_potion > 0:
			health = min(health + 20,MAX_HEALTH)
			health_potion -= 1
			print("healed: "+str(health_potion))
			UI.set_health(health)
			UI.set_health_potion(health_potion)
			
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
			answer = math_operations(first,second,2)
		1:
			first = randi_range(0, 10)
			second = randi_range(0,10)
			answer = math_operations(first,second,0)
		2:
			first = randi_range(0, 10)
			second = randi_range(0,10)
			answer = math_operations(first,second,1)
		3:
			first = randi_range(10, 100)
			second = randi_range(10,100)
			answer = math_operations(first,second,randi_range(0,1))
		4:
			first = randi_range(1, 10)
			second = randi_range(1,10)
			answer = math_operations(first,second,2)
		5:
			first = randi_range(1, 20)
			second = randi_range(1,10)
			answer = math_operations(first,second,2)
		6:
			first = randi_range(50, 100)
			second = randi_range(50,100)
			answer = math_operations(first,second,2)
	print(first,second,answer)
	UI.set_first(first)
	UI.set_second(second)
	UI.math_enter()
	is_math = true
	math_timer.wait_time = max(MIN_MATH_TIMER,MATH_TIMER * pow(0.9,iterations))
	iterations+=1
	math_timer.start()
	
	
func math_operations(first: int, second: int,equation: int) -> int:
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
	
func set_interrupted(val: bool):
	is_interrupted = val
	main_player.disable_control(val)
	

func _on_hub_math_signal(level: int) -> void:
	print("here")
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
	health-=20
	UI.set_health(health)

func add_health_potion(val:int):
	health_potion+=val
	UI.set_health_potion(health_potion)

func update_array(val: int):
	page_array.append(val)
	UI.set_notebook_array(page_array.size(),MAX_PAGE)

func get_array() -> Array:
	return page_array
