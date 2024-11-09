extends Node3D


##################################### exports
@export var page_array = [0,3]

##################################### constants
const MATH_TIMER = 30
const MIN_MATH_TIMER = 6
const MAX_HEALTH = 100
const MAX_PAGE = 10

##################################### nodes
var health_timer: Timer
var math_timer: Timer
var main_player:CharacterBody3D
var sub_player:CharacterBody3D
var UI: Control
var math_ui: Control

##################################### flags
@onready var is_health_timer = false
@onready var is_interrupted = false
@onready var is_math = false
@onready var is_note = false

##################################### variables
@onready var iterations = 0
@onready var answer = 0
@onready var health = MAX_HEALTH
@onready var health_potion = 3
@onready var health_damage = 20

##################################### default functions
# Setup nodes and initialize the UI with health, health potions, and notebook page count.
func _ready() -> void:
	health_timer = get_node("health_deplete")
	math_timer = get_node("math_timer")
	main_player = get_node("main_player")
	sub_player = get_node("sub_player")
	UI = get_node("ExploreUi")
	math_ui = get_node("math_ui")
	
	SignalManager.collected_healthpotions_signal.connect(_on_collected_healthpotions_signal)
	SignalManager.collected_notebooks_signal.connect(_on_collected_notebooks_signal)
	
	SignalManager.coco_in_dig_range_signal.connect(_on_coco_in_dig_range_signal)
	SignalManager.dig_result_signal.connect(_on_digresult_signal)
	
	SignalManager.show_interact_button_signal.connect(_on_show_interact_button_signal)
	
	UI.set_health(health)
	UI.health_picked(health_potion)
	UI.set_notebook_array(page_array.size()-1,MAX_PAGE)

# Handle input for using health potions and interacting with the notebook.
func _input(event: InputEvent) -> void:
	if !is_interrupted:
		Inventory_inputs()

# Control the health timer. If not interrupted, start a random timer to reduce health over time.
func _physics_process(delta: float) -> void:
	if is_interrupted:
		health_timer.stop()
		set_health_timer(false)
		if is_math:
			var percent_time = (math_timer.get_time_left()/math_timer.get_wait_time())*100
			math_ui.set_timer(percent_time)

	else:	
		if !is_health_timer:
			health_timer.wait_time = randi_range(5, 15)
			health_timer.start()
			set_health_timer(true)

##################################### custom functions


# If a health potion is used, update health and UI, and manage potion count.
# Toggle notebook visibility, disabling the main player's controls when the notebook is open.
func Inventory_inputs():
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

# Start a math puzzle based on difficulty level and calculate the correct answer using randomly generated numbers.
# Display the math problem on the UI and set the math timer with decreasing time based on the number of iterations.
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
	math_ui.set_first(first)
	math_ui.set_second(second)
	math_ui.math_enter()
	is_math = true
	math_timer.wait_time = max(MIN_MATH_TIMER,MATH_TIMER * pow(0.9,iterations+iter))
	iterations+=1
	math_timer.start()
	
# Handle the failure of a math puzzle by decreasing health and updating the UI. If health drops to 0, the main player is killed.
func failed():
		math_ui.math_failure()
		iterations = max(iterations-5,0)
		health_lost(true,health_damage)

# Perform the specified math operation (addition, subtraction, or multiplication) and return the result, updating the UI with the equation symbol.
func math_operations(first: int, second: int,equation: int) -> int:
	match equation:
		0:
			answer = first + second
			math_ui.set_equation("+")
		1:
			answer = first - second
			math_ui.set_equation("-")
		2:
			answer = first * second
			math_ui.set_equation("x")
	return answer

func health_lost(is_not_timer: bool,damage: int):
	health= max(0,health - damage)
	UI.set_health(health)
	if(is_not_timer):
		UI.health_lost()

	if(health <= 0):
		UI.play_ded()
		main_player.set_ded()
	
##################################### set functions
# Pause or unpause the health depletion timer.
func pause_health_timer(val: bool):
	health_timer.paused = val
	
# Set the interruption flag, disabling the player's controls and updating the UI.
func set_interrupted(val: bool):
	is_interrupted = val
	main_player.disable_control(val)
	UI.set_interrupted(val)

# Add health potions and update the UI with the new potion count.
func add_health_potion(val:int):
	health_potion+=val
	UI.health_picked(health_potion)

# Set the flag to track if the health timer is active.
func set_health_timer(val: bool):
	is_health_timer = val

# Add a new page to the notebook and update the UI with the updated page count.
func update_array(val: int):
	page_array.append(val)
	UI.set_notebook_array(page_array.size()-1,MAX_PAGE)
	
# If the player is not panicking, control the digging interaction state for "coco."
func set_coco_range_dig(val:bool):
	if !main_player.get_panic_status():
		if val:
			main_player.set_coco_dig(1)
		else:
			main_player.set_coco_dig(0)

# Show or hide the interact icon in the UI.
func set_player_interact(val:bool):
	UI.set_interact(val)
	
# Handle the result of a digging interaction, either updating the notebook or adding a health potion.
func digged_up(val: bool,id: int,pos: Vector3):
	if val:
		update_array(id)
	else:
		add_health_potion(id)
	sub_player.set_dig_position(pos)


##################################### get functions
# Return the main player's current position.
func give_main_player_position() -> Vector3:
	return main_player.position
	

##################################### signals functions internal
# Check if the player's submitted answer is correct and handle success or failure accordingly. Stop the math timer and resume normal gameplay.
func _on_math_ui_submitted_math_answer(text: String) -> void:
	var get_answer = int(text)
	if(get_answer == answer):
		math_ui.math_success()
	else:
		failed()
	math_timer.stop()
	set_interrupted(false)

# Handle the timeout of the math puzzle, treating it as a failure.
func _on_math_timer_timeout() -> void:
	failed()
	set_interrupted(false)
	math_timer.stop()

# Randomly decrease the player's health over time. If health drops to 0, the player is killed.
func _on_health_deplete_timeout() -> void:
	if health > 0:
		var health_decrease = randi_range(3, 7) # Randomly decrease health between 5 and 20 points
		health_lost(false,health_decrease)
		print("Health decreased by ", health_decrease, " - Current health: ", health)
		UI.set_health(health)
		is_health_timer = false


##################################### signals functions external
# Update the notebook array when a new notebook is collected.
func _on_collected_notebooks_signal(val:int) -> void:
	update_array(val)

# Add health potions when collected.
func _on_collected_healthpotions_signal(val: int) -> void:
	add_health_potion(val)

# Handle the player entering or exiting digging range.
func _on_coco_in_dig_range_signal(val: bool) -> void:
	set_coco_range_dig(val)

# Start a new math puzzle with the given difficulty level, damage, and iteration count.
func _on_hub_math_signal(level: int,damage: int, iter: int) -> void:
	print("here")
	start_math(level,damage,iter)

# Handle digging interaction, enabling player interaction UI.
func _on_show_interact_button_signal(val: bool) -> void:
	set_player_interact(val)

# Process the result of digging, either finding a notebook or health potion, and update the sub player's position.
func _on_digresult_signal(val: bool,id: int,pos: Vector3) -> void:
	digged_up(val,id,pos)

func _on_health_lost_signal(damage: int):
	health_lost(true,damage)
