extends Node3D

############################################## constants
const MATH_TIMER = 30
const MIN_MATH_TIMER = 6
const MAX_HEALTH = 100
const MAX_PAGE = 10

const PANIC_DISTANCE = 100
const FAR_TIME = 5
const PANIC_TIME = 20# 20

############################################## nodes
@onready var main_player = $main_player
@onready var sub_player = $sub_player

@onready var ui = $Ui
@onready var camera = $camera_controller

@onready var health_timer = $health
@onready var math_timer = $math
@onready var panic_timer = $panic

##################################### flags
@onready var save_timer_state = null

##################################### variables
@onready var iterations = 0
@onready var answer = 0

@onready var health = MAX_HEALTH
@onready var health_potion = 3
@onready var health_damage = 20

@onready var coco_ui = ["default","happy","scared","glad"]
@onready var coco_index = 0

##################################### States
enum STATE {ENABLE,DISABLED,MATH,NOTE,PEACEFUL}
var state = STATE.ENABLE

enum TIMER_STATE {ACTIVE,PAUSED,INACTIVE,DISABLED,PANIC}
var health_timer_state = TIMER_STATE.INACTIVE
var panic_timer_state = TIMER_STATE.INACTIVE

##################################### State functions and setup
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	SignalManager.collected_notebooks_signal.connect(_on_collected_notebooks_signal)
	
	SignalManager.submitted_math_answer.connect(_on_math_ui_submitted_math_answer)	
	SignalManager.signal_math.connect(_on_signal_math)
	SignalManager.hurt_signal.connect(_on_health_lost_signal)
	
	SignalManager.coco_in_dig_range_signal.connect(_on_coco_in_dig_range_signal)
	SignalManager.dig_result_signal.connect(_on_digresult_signal)
	
	SignalManager.show_interact_button_signal.connect(_on_show_interact_button_signal)
	
	SignalManager.petting_signal.connect(_on_petting_signal)
	
	SignalManager.trigger_panic.connect(_on_trigger_panic)
	
	ui.set_health(health)
	ui.health_picked(health_potion)
	
	if (SaveStates.is_checkpoint()):
		print("setting player")
		var arre = SaveStates.get_player_pos()
		main_player.position = arre[1]
		sub_player.position = arre[2]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	match state:
		STATE.ENABLE:
			state_inputs()
		STATE.MATH:
			state_math()
		STATE.NOTE:
			state_note()
		STATE.PEACEFUL:
			state_peaceful()		
		
	match health_timer_state:
		TIMER_STATE.INACTIVE:
			state_health_timer_inactive()
			
	match panic_timer_state:
		TIMER_STATE.INACTIVE:
			state_panic_timer_inactive()
		TIMER_STATE.ACTIVE:
			state_panic_timer_active()

##################################### TIMER State functions
func state_health_timer_inactive():
	health_timer.wait_time = randi_range(5, 15)
	health_timer.start()
	health_timer_state = TIMER_STATE.ACTIVE
		
func state_health_timer_active():
	if health > 0:
		var health_decrease = randi_range(3, 7)
		health_lost(false,health_decrease)
		print("Health decreased by ", health_decrease, " - Current health: ", health)
		ui.set_health(health)
		health_timer_state = TIMER_STATE.INACTIVE
		
func state_health_timer_paused():
	if health_timer_state != TIMER_STATE.DISABLED:
		health_timer_state = TIMER_STATE.PAUSED
		health_timer.paused = true

func state_health_timer_unpaused():
	if health_timer_state != TIMER_STATE.DISABLED:
		health_timer_state = TIMER_STATE.ACTIVE
		health_timer.paused = false

func state_health_timer_disable():
	health_timer_state = TIMER_STATE.DISABLED
	health_timer.stop()
	
func state_health_timer_enable():
	health_timer_state = TIMER_STATE.INACTIVE

func _on_health_timeout() -> void:
	state_health_timer_active()
	
	
func state_panic_timer_inactive():
	var distance_to_sub = main_player.global_position.distance_to(sub_player.global_position)
		#Vector3(main_player.position.x, 0, main_player.position.z).distance_to(Vector3(sub_player.position.x, 0, sub_player.position.z))
	if(distance_to_sub > PANIC_DISTANCE):
		panic_timer.wait_time = FAR_TIME
		panic_timer.start()
		print("timer start")
		panic_timer_state = TIMER_STATE.ACTIVE

func state_panic_timer_active():
	var distance_to_sub = main_player.global_position.distance_to(sub_player.global_position)
	#Vector3(main_player.position.x, 0, main_player.position.z).distance_to(Vector3(sub_player.position.x, 0, sub_player.position.z))
	if(distance_to_sub <= PANIC_DISTANCE):
		panic_timer.stop()
		panic_timer_state = TIMER_STATE.INACTIVE
		
func state_panic_timer_paused():
	if panic_timer_state != TIMER_STATE.PAUSED and panic_timer_state != TIMER_STATE.DISABLED: 
		save_timer_state = panic_timer_state
	panic_timer_state = TIMER_STATE.PAUSED
	panic_timer.paused = true
	#print("panic_timer paused")

func state_panic_timer_unpaused():
	if save_timer_state == TIMER_STATE.PAUSED or save_timer_state == TIMER_STATE.DISABLED: 
		save_timer_state = TIMER_STATE.INACTIVE
	panic_timer_state = save_timer_state
	panic_timer.paused = false
	#print("panic_timer unpaused")

func state_panic_timer_disable():
	panic_timer_state = TIMER_STATE.DISABLED
	panic_timer.stop()

func state_panic_timer_enable():
	panic_timer_state = TIMER_STATE.INACTIVE

func trigger_panic():
	panic_timer_state = TIMER_STATE.PANIC
	panic_timer.wait_time = PANIC_TIME
	panic_timer.start()
	sub_player.trigger_panic()
	print("panic_panic start")

func _on_panic_timeout() -> void:
	if panic_timer_state == TIMER_STATE.ACTIVE:
		trigger_panic()
		
	elif panic_timer_state == TIMER_STATE.PANIC:
		print("TOO LATE")
		disable()
		health_lost(true,200)
		
func _on_petting_signal(val: bool):
	if val:
		panic_timer_state = TIMER_STATE.INACTIVE
		panic_timer.stop()
		ui.set_coco(coco_ui[3])
	else:
		if panic_timer_state == TIMER_STATE.PANIC:
			ui.set_coco(coco_ui[2])
		else:
			ui.set_coco(coco_ui[coco_index])
		
func set_coco_range_dig(val:bool):
		if val:
			coco_index = 1
		else:
			coco_index = 0
##################################### State functions

func state_peaceful():
	if Input.is_action_just_pressed("interact"):
		SignalManager.interracted.emit(false)
	state_health_timer_paused()
	state_panic_timer_paused()	
	

func state_inputs():
	if Input.is_action_just_pressed("interact"):
		var panicked = panic_timer_state == TIMER_STATE.PANIC
		SignalManager.interracted.emit(panicked)
		
	if Input.is_action_just_pressed("health") and health_potion > 0:
		health = min(health + 20,MAX_HEALTH)
		health_potion -= 1
		state_health_timer_inactive()
		print("healed: "+str(health_potion))
		ui.set_health(health)
		ui.health_used(health_potion)
		if(health_potion <= 0):
			ui.health_exhaust(health_potion)

	if Input.is_action_just_pressed("notebook"):
		if SaveStates.notebooks.size()-1 <= 0:
			ui.notebook_empty()
		else:
			paused()
			ui.notebook_ui_open_book()
			state = STATE.NOTE

func state_note():
	if Input.is_action_just_pressed("notebook"):
		ui.notebook_ui_close_book()
		unpaused()
		state = STATE.ENABLE

func state_math():
	var percent_time = (math_timer.get_time_left()/math_timer.get_wait_time())*100
	ui.math_ui_set_timer(percent_time)
	
##################################### custom functions
func disable():
	state = STATE.DISABLED
	ui.interrupted()
	main_player.disable_controls()
	sub_player.disable_controls()
	state_health_timer_paused()
	state_panic_timer_paused()

func paused():
	main_player.pause_controls()
	sub_player.pause_controls()
	camera.set_state_paused()
	state_health_timer_paused()
	state_panic_timer_paused()
	ui.interrupted()

func unpaused():
	print("unpasued")
	state = STATE.ENABLE
	main_player.unpause_controls()
	sub_player.unpause_controls()
	camera.set_state_unpaused()
	state_health_timer_unpaused()
	state_panic_timer_unpaused()

func enable():
	state = STATE.ENABLE
	main_player.enable_controls()
	sub_player.enable_controls()
	state_health_timer_unpaused()
	state_panic_timer_unpaused()
	ui.uninterrupted()

func get_notebook():
	ui.notebook_ui_get_notebook()
	
func health_lost(is_not_timer: bool,damage: int):
	health = max(0,health - damage)
	if state == STATE.NOTE:
		ui.notebook_ui_close_book()
		unpaused()
		
	ui.set_health(health)

	if(health <= 0):
		ui.play_ded()
		main_player.kill_player()
	
	else:
		if(is_not_timer):
			ui.health_lost()

func add_health_potion(val:int):
	health_potion+=val
	ui.health_picked(health_potion)

func set_player_interact(val:bool):
	ui.set_interact(val)
	
func digged_up(pos: Vector3):
	sub_player.set_dig_position(pos)

##########################################################math functions
func start_math(level: int,damage: int = 20,iter: int = 0):
	var first = 0
	var second = 0
	health_damage = damage
	state = STATE.MATH
	paused()
	print("start")
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
	math_timer.wait_time = max(MIN_MATH_TIMER,MATH_TIMER * pow(0.9,iterations+iter))
	iterations+=1
	math_timer.start()
	SignalManager.math_in_session.emit(true)
	
# Handle the failure of a math puzzle by decreasing health and updating the UI. If health drops to 0, the main player is killed.
func failed():
		ui.math_ui_failure()
		iterations = max(iterations-5,0)
		health_lost(true,health_damage)
		SignalManager.math_in_session.emit(false)
		SignalManager.math_success.emit(false)
		camera.set_state_player()

# Perform the specified math operation (addition, subtraction, or multiplication) and return the result, updating the UI with the equation symbol.
func math_operations(first: int, second: int,equation: int) -> int:
	var operand = ""
	match equation:
		0:
			answer = first + second
			operand = "+"
		1:
			answer = first - second
			operand = "-"
		2:
			answer = first * second
			operand = "x"
	ui.math_ui_set(first, second, operand)
	camera.set_state_math()
	return answer

func _on_math_ui_submitted_math_answer(text: String) -> void:
	var get_answer = int(text)
	unpaused()
	if(get_answer == answer):
		ui.math_ui_success()
		SignalManager.math_in_session.emit(false)
		SignalManager.math_success.emit(true)
		camera.set_state_player()
	else:
		failed()
	math_timer.stop()

	
func _on_math_timeout() -> void:
	math_timer.stop()
	unpaused()
	failed()
	
##################################### get functions
func give_main_player_position():
	return main_player.position



##################################### signals functions
func _on_collected_notebooks_signal() -> void:
	get_notebook()

# Add health potions when collected.
func _on_collected_healthpotions_signal(val: int) -> void:
	add_health_potion(val)

# Handle the player entering or exiting digging range.
func _on_coco_in_dig_range_signal(val: bool) -> void:
	set_coco_range_dig(val)

# Handle digging interaction, enabling player interaction UI.
func _on_show_interact_button_signal(val: bool) -> void:
	set_player_interact(val)
	main_player.set_interact(val)

# Process the result of digging, either finding a notebook or health potion, and update the sub player's position.
func _on_digresult_signal(pos: Vector3) -> void:
	digged_up(pos)

func _on_health_lost_signal(damage: int):
	health_lost(true,damage)

func _on_signal_math(level: int,damage: int, iter: int = 0):
	print("here")
	start_math(level,damage,iter)

func _on_trigger_panic():
	trigger_panic()

func activate_notebook():
	ui.activate_notebook()
