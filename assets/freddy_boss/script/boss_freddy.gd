extends Node3D

@export var notebook_number = 6

@onready var fsm_player = $"../FSM_Players"

@onready var trigger = $Area3D
@onready var collision_wall = $back/CollisionShape3D
@onready var lights = $"../lighting"

@onready var fred_dash = $freds
@onready var freddy = $Freddy
@onready var anim = $cutscenes
@onready var battle_anim = $AnimationPlayer


@onready var dash_timer = $freds/dash_timer
@onready var power_timer = $power_timer
@onready var smack_timer = $smack_timer
@onready var vuln_timer = $vuln_timer
@onready var walk_timer = $walk_timer
@onready var power_down_timer = $power_down_timer
@onready var music = $AudioStreamPlayer

@onready var spots = $spots

@onready var health_look = $Panel2
@onready var health_bar = $Panel2/ProgressBar
@onready var health = 20

@onready var dash_speed = 1
@onready var time_gap = [2,3]
@onready var power_time = 5
@onready var power_down_time = 15



enum STATE {PHASE,WAIT,CUTSCENE,INTRO,FINISHED}
@onready var state = STATE.FINISHED

enum DARK_STATE {ON,OFF}
@onready var dark_state = DARK_STATE.OFF


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lights.turn_switch(true)
	collision_wall.set_deferred("disabled",true)
	if notebook_number in SaveStates.notebooks:
		queue_free()
	else:
		fsm_player.state_health_timer_disable()
		music.stream = load("res://assets/freddy_boss/sounds/intro_buildup.mp3")
		music.play()
		state = STATE.INTRO
		health_bar.max_value = health
		health_bar.value = health_bar.max_value
	
	SignalManager.hit_kitty.connect(_on_hit)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		STATE.INTRO:
			phase_intro()
		STATE.PHASE:
			phase_phase()

func _physics_process(delta: float) -> void:
	if freddy.state == freddy.STATE.WALK:
		if freddy.velocity.x < 0.5:
			freddy.velocity.x = freddy.direction.x * freddy.STAB
		if freddy.velocity.z < 0.5:
			freddy.velocity.z = freddy.direction.z * freddy.STAB
		freddy.global_position = freddy.global_position.lerp(freddy.target_pos, freddy.STAB * delta)
		if freddy.global_position.distance_to(freddy.target_pos) < 8:
			freddy.state = freddy.STATE.IDLE
			
func phase_intro():
	if !music.playing:
		music.stream = load("res://assets/freddy_boss/sounds/intro_buildup.mp3")
		music.play()

func phase_phase():
	if !music.playing:
		music.stream = load("res://assets/freddy_boss/sounds/freddy_theme.mp3")
		music.play()	


func set_cutscene():
	fsm_player.disable()
	state = STATE.CUTSCENE
	intro()

func intro():
	anim.play("intro_1")
	music.stream = load("res://assets/freddy_boss/sounds/intro.mp3")
	music.play()
	freddy.set_intro()

func intro_2():
	anim.play("intro_2")

func intro_3():
	anim.play("intro_3")


func intro_4():
	anim.play("intro_4")
	freddy.set_intro_2()
	music.stream = load("res://assets/freddy_boss/sounds/freddy_theme.mp3")
	music.play()

func intro_done():
	anim.play("intro_done")
	fsm_player.enable()
	state = STATE.PHASE
	boss_start()
	

func fred_dash_start():
	fred_dash.set_speed(time_gap[0],time_gap[1],dash_speed)

func freddy_power_up():
	freddy.set_power_up()
	power_timer.wait_time = power_time
	vuln_timer.stop()
	walk_timer.stop()
	smack_timer.stop()
	power_down_timer.stop()
	power_timer.start()

func freddy_power_down():
	freddy.set_power_down()
	power_down_timer.wait_time = power_down_time
	power_down_timer.start()
	freddy_move()

func freddy_move():
	freddy.set_walk(spots.get_pos())
	walk_timer.wait_time = 5
	walk_timer.start()

func freddy_hide():
	vuln_timer.stop()
	walk_timer.stop()
	freddy.set_invuln()
	smack_timer.stop()
	power_timer.stop()
	power_down_timer.stop()
	freddy.set_walk(spots.get_original())
	black_out(15)

func _on_hit():
	health-=1
	health_bar.value = health
	
	if dark_state == DARK_STATE.ON and health > 5:
		print("not working ?")
		dark_state = DARK_STATE.OFF
		fred_dash.interrupted()
		print(fred_dash.temp_arrays)
	if health <= 0:
		state = STATE.FINISHED
		fred_dash.interrupted()
		boss_over()
	elif health == 15:
		time_gap = [1.5,2]
		dash_speed = 1
		power_down_time = 15
		power_time = 8
		freddy_hide()
	elif health == 10:
		time_gap = [1,1.3]
		dash_speed = 1.5
		power_down_time = 8
		power_time = 15
		freddy_hide()
	elif health == 4:
		time_gap = [2,3]
		power_time = 5
		fred_dash_start()
		
	elif health == 5:
		time_gap = [1,1.3]
		power_down_time = 10
		power_time = 8
		dash_speed = 2
		freddy_hide()
	else:
		freddy.set_invuln()
		smack_timer.wait_time = 5
		smack_timer.start()
		vuln_timer.wait_time = 8
		vuln_timer.start()
		smack_timer.start()
		walk_timer.stop()
		
	
func boss_over():
	
	smack_timer.stop()
	vuln_timer.stop()
	walk_timer.stop()
	smack_timer.stop()
	power_timer.stop()
	power_down_timer.stop()
	freddy.set_vuln()
	freddy.set_dead()
	anim.play("finish")
	health_look.visible = false
	Engine.time_scale = 0.25
	await get_tree().create_timer(1).timeout
	Engine.time_scale = 1
	music.stop()
	SaveStates.get_notebook(notebook_number)
	SignalManager.collected_notebooks_signal.emit()

	collision_wall.set_deferred("disabled",true)

func black_out(val: int):
	lights.turn_switch(false)
	dash_timer.wait_time = val
	dash_timer.start()
	battle_anim.play("black_out")
	dark_state = DARK_STATE.ON

func black_out_over():
	lights.turn_switch(true)
	battle_anim.play("black_in")
	freddy.set_vuln()
	power_down_timer.start()
	
func boss_start():
	black_out(15)
	#freddy.set_vuln()
	collision_wall.set_deferred("disabled",false)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "main_player":
		set_cutscene()
		trigger.queue_free()

func _on_dash_timer_timeout() -> void:
	dash_timer.stop()
	black_out_over()

func _on_power_timer_timeout() -> void:
	power_timer.stop()
	freddy_power_down()



func _on_smack_timer_timeout() -> void:
	smack_timer.stop()
	freddy_move()


func _on_walk_timer_timeout() -> void:
	walk_timer.stop()
	freddy_move()


func _on_vuln_timer_timeout() -> void:
	vuln_timer.stop()
	freddy.set_vuln()


func _on_power_down_timer_timeout() -> void:
	power_down_timer.stop()
	freddy_power_up()
