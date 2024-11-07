extends Node3D

@export var page_array = [0,3]

var health = 100
const MAX_HEALTH = 100
var health_potion = 3
var health_damage = 20

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
@onready var is_note = false

@onready var iterations = 0

func _ready() -> void:
	health_timer = get_node("health_deplete")
	math_timer = get_node("math_timer")
	main_player = get_node("main_player")
	sub_player = get_node("sub_player")
	UI = get_node("ExploreUi")
	UI.set_health(health)
	UI.health_picked(health_potion)
	UI.set_notebook_array(page_array.size()-1,MAX_PAGE)
	#_set_random_timer_interval()
	
func _input(event: InputEvent) -> void:
	if !is_interrupted:
		if Input.is_action_just_pressed("health") and health_potion > 0 and !is_note:
			health = min(health + 20,MAX_HEALTH)
			health_potion -= 1
			is_health_timer = false
			print("healed: "+str(health_potion))
			UI.set_health(health)
			UI.health_used(health_potion)
			if(health_potion <= 0):
				UI.health_exhaust(health_potion)
		
		if Input.is_action_just_pressed("notebook"):
			is_note = !is_note
			UI.set_note(is_note)
			main_player.disable_control(is_note)
			pause_health_timer(is_note)
			if is_note:
				UI.set_array(page_array)
		
func _physics_process(delta: float) -> void:
	if is_interrupted:
		health_timer.stop()
		set_health_timer(false)
		if is_math:
			var percent_time = (math_timer.get_time_left()/math_timer.get_wait_time())*100
			UI.set_timer(percent_time)

	else:	
		if !is_health_timer:
			health_timer.wait_time = randi_range(5, 15)
			health_timer.start()
			set_health_timer(true)

func pause_health_timer(val: bool):
	health_timer.paused = val

func start_math(level: int,damage: int = 20,iter: int = 0):
	var first = 0
	var second = 0
	health_damage = damage
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
			first = randi_range(10, 20)
			second = randi_range(1,10)
			answer = math_operations(first,second,2)
		6:
			first = randi_range(50, 100)
			second = randi_range(50,100)
			answer = math_operations(first,second,2)
	#print(first,second,answer)
	UI.set_first(first)
	UI.set_second(second)
	UI.math_enter()
	is_math = true
	math_timer.wait_time = max(MIN_MATH_TIMER,MATH_TIMER * pow(0.9,iterations+iter))
	iterations+=1
	math_timer.start()
	
func failed():
		UI.math_failure()
		iterations = max(iterations-5,0)
		health= max(0,health - health_damage)
		UI.set_health(health)	
		if(health <= 0):
			main_player.ded()

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

func add_health_potion(val:int):
	health_potion+=val
	UI.health_picked(health_potion)

func set_health_timer(val: bool):
	is_health_timer = val

func update_array(val: int):
	page_array.append(val)
	UI.set_notebook_array(page_array.size()-1,MAX_PAGE)
	
func give_main_player_position() -> Vector3:
	return main_player.position
	
func _on_hub_math_signal(level: int,damage: int, iter: int) -> void:
	print("here")
	start_math(level,damage,iter)


func _on_answer_text_submitted(new_text: String) -> void:
	var get_answer = int(new_text)
	if(get_answer == answer):
		UI.math_success()
	else:
		failed()
	math_timer.stop()
	set_interrupted(false)

func _on_math_timer_timeout() -> void:
	failed()
	set_interrupted(false)

func _on_notebook_collected_notebook_signal(val:int) -> void:
	update_array(val)

func _on_health_potion_collected_healthpotions_signal(val: int) -> void:
	add_health_potion(val)

func _on_health_deplete_timeout() -> void:
	if health > 0:
		var health_decrease = randi_range(3, 7) # Randomly decrease health between 5 and 20 points
		health -= health_decrease
		health = max(0, health) # Ensure health doesn't drop below 0
		if(health <= 0):
			main_player.ded()
		print("Health decreased by ", health_decrease, " - Current health: ", health)
		UI.set_health(health)
		is_health_timer = false
