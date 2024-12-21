extends Node3D

@export var notebook_number = 9

@onready var fsm_player = $"../FSM_Players"
@onready var anim = $cutscene
@onready var music = $AudioStreamPlayer
@onready var lights = $"../lighting"


@onready var plushies = $"../plushies"
@onready var art = $"../arts"
@onready var health = 9
@onready var health_bar = $Panel2/ProgressBar
@onready var phase = $phase_changer
@onready var cool_down = $Cool_down

@onready var phase_tracker = 0
@onready var dashers_1 = []
@onready var dashers_2 = []
@onready var dasher_index = [0,1,2]
@onready var cool_down_range = [2,3]
@onready var speed = 1
@onready var finished = false
@onready var music_finish = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.math_success.connect(_on_result)
	SignalManager.math_in_session.connect(_math_in_session)
	SignalManager.fred_done.connect(refill_dasher)
	if notebook_number in SaveStates.notebooks:
		queue_free()
	else:
		if SaveStates.first_death:
			fsm_player.global_position = Vector3(456.098,9.674,14.192)
		health_bar.max_value = health
		health_bar.value = health
		for i in $dasher.get_children():
			dashers_1.append(i)
		for i in $dasher2.get_children():
			dashers_2.append(i)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !music_finish and !music.is_playing():
		music.play()

func intro():
	anim.play("intro")
	phase.play("phase_0")

func intro_1():
	anim.play("intro_1")
	$monster_0/math_monster.set_active()
	$monster_0/math_monster.anim.play("appear")

func intro_2():
	anim.play("intro_2")
	music.stream = load("res://assets/interactives/sound effects/math_boss.mp3")
	music.play()

func intro_done():
	anim.play("intro_done")
	fsm_player.enable()
	music_finish = false

func set_cutscene():
	fsm_player.disable()
	fsm_player.state_health_timer_disable()
	plushies.queue_free()
	art.queue_free()
	lights.turn_switch(false)
	intro()


func boss_over():
	
	cool_down.stop()
	finished = true
	anim.play("finish")
	phase.stop()
	phase.play("finish")
	health_bar.visible = false
	$Panel2.visible = false
	Engine.time_scale = 0.25
	await get_tree().create_timer(1).timeout
	Engine.time_scale = 1
	music_finish = true
	music.stop()
	SaveStates.get_notebook(notebook_number)
	SignalManager.collected_notebooks_signal.emit()
	lights.turn_switch(true)

func _on_result(val: bool):
	if val:
		health-=1
		health_bar.value = health
		if health == 8:
			cool_down_range = [2,3]
			speed = 1
			next_phase()
		elif health == 5:
			cool_down_range = [1,1.5]
			speed = 2
			next_phase()
		elif health == 1:
			next_phase()
		elif health <= 0:
			boss_over()


func pick_dasher():
	if !finished:
		cool_down.wait_time = randf_range(cool_down_range[0],cool_down_range[1])
		cool_down.start()
		print(dasher_index)
		if dasher_index.size() != 1:
			var i = randi_range(0,len(dasher_index)-1)
			var j = randi_range(0,1)
			if j:
				dashers_1[dasher_index[i]].start(speed)
			else:
				dashers_2[dasher_index[i]].start(speed)
			dasher_index.pop_at(i)


func _math_in_session(val):
	if val:
		dasher_index = [0,1,2]
		cool_down.set_paused(true)
		for i in range(3):
			dashers_1[i].interrupt()
			dashers_2[i].interrupt()
	else:
		cool_down.set_paused(false)

func refill_dasher(val: int):
	dasher_index.append(val)


func next_phase():
	phase_tracker+=1
	finished = true
	cool_down.stop()
	var monsters = get_node("monster_"+str(phase_tracker))
	for i in monsters.get_children():
		i.set_active()
	phase.stop()
	phase.play("phase_"+str(phase_tracker))
	if phase_tracker == 1 or phase_tracker == 2:
		finished = false
		pick_dasher()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "main_player":
		set_cutscene()
		SaveStates.first_death = true
		visible = true
		$Area3D.queue_free()


func _on_wall_body_entered(body: Node3D) -> void:
	if body.name == "main_player":
		SignalManager.hurt_signal.emit(300)


func _on_cool_down_timeout() -> void:
	cool_down.stop()
	pick_dasher()
