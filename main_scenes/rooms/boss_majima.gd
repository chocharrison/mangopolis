extends Node3D

@export var notebook_number = 2
@export var health = 30
@export var halfway = 15


@onready var trigger = $Area3D
@onready var collision_wall = $MeshInstance3D/StaticBody3D/CollisionShape3D
@onready var toilets = $toilets
@onready var player = $"../FSM_Players"
@onready var anim = $AnimationPlayer
@onready var audio = $AudioStreamPlayer
@onready var cool_down = $cool_down
@onready var burst_timer = $burst

@onready var health_show = $Panel2
@onready var health_bar = $Panel2/ProgressBar

@onready var finished = true
@onready var burst_cooldown = false
@onready var toilet_arrays = []
@onready var temp_arrays = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.done_majima.connect(toilet_start)
	SignalManager.Majima_popped.connect(interrupt_majima)
	SignalManager.closed_majima.connect(closed_door)
	health_show.visible = false
	collision_wall.set_deferred("disabled",true)
	if notebook_number in SaveStates.notebooks:
		trigger.queue_free()
		
	var j = 0
	for i in toilets.get_children():
		toilet_arrays.append(i)
		i.toilet_number = j
		temp_arrays.append(j)
		j+=1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "main_player":
		audio.stream = load("res://assets/enemies/sound/majima-sensor.mp3")
		audio.play()
		intro_start()
		trigger.queue_free()

func intro_start():
	player.disable()
	anim.play("intro_start")

func intro():
	anim.play("intro")

func intro2():
	anim.play("intro2")

func intro3():
	anim.play("intro3")
	audio.stream = load("res://assets/enemies/sound/majima.mp3")
	audio.play()

func intro_down():
	anim.play("intro_done")
	player.enable()
	collision_wall.set_deferred("disabled",false)
	finished = false
	health_show.visible = true
	toilet_start()
	health_bar.max_value = health
	health_bar.value = health


func toilet_start():
	print("toilet_start")
	if !finished:
		cool_down.wait_time = randf_range(1,3)
		cool_down.start()
		if temp_arrays != []:
			var i = randi_range(0,len(temp_arrays)-1)
			print(i)
			toilet_arrays[temp_arrays[i]].suspense_majima()
			temp_arrays.pop_at(i)


func interrupt_majima():
	cool_down.stop()
	temp_arrays = [0,1,2,3,4,5,6,7]
	for i in toilet_arrays:
		i.interuppted_majima()


func closed_door(val: int):
	temp_arrays.append(val)
	if !burst_cooldown:
		health -= 1 
		health_bar.value = health
		if health == halfway:
			interrupt_majima()
			for i in range(len(temp_arrays)):
				toilet_arrays[i].suspense_majima()
			burst_timer.start()
		elif health <= 0:
			finished_boss(val)


func finished_boss(val: int):
	interrupt_majima()
	finished = true
	collision_wall.set_deferred("disabled",true)
	anim.play("finish")
	toilet_arrays[val].defeat()
	Engine.time_scale = 0.25
	await get_tree().create_timer(1).timeout
	Engine.time_scale = 1
	audio.stop()
	SaveStates.get_notebook(notebook_number)
	SignalManager.collected_notebooks_signal.emit()
	health_show.visible = false


func _on_cool_down_timeout() -> void:
	cool_down.stop()
	toilet_start()
	
