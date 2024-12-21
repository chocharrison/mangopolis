extends Node3D

@export var notebook_number = 15


@onready var wall = $MeshInstance3D/StaticBody3D/CollisionShape3D
@onready var trigger = $Area3D
@onready var richard = $Richard
@onready var anim = $AnimationPlayer
@onready var music = $AudioStreamPlayer
@onready var fsm_player = $"../FSM_Players"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if notebook_number in SaveStates.notebooks:
		queue_free()
	else:
		wall.set_deferred("disabled",true)
		SignalManager.hit_kitty.connect(_on_hit)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_cutscene():
	fsm_player.disable()
	#anim.play("intro_1")
	wall.set_deferred("disabled",false)
	richard.set_intro()
	intro_2()

func intro_2():
	#anim.play("intro_2")
	music.stream = load("res://assets/interactives/sound effects/richard_music.mp3")
	music.play()
	intro_done()
	
func intro_done():
	#anim.play("intro_done")
	fsm_player.enable()
	richard.set_walk()

func _on_hit():
	#anim.play("finish")
	Engine.time_scale = 0.25
	await get_tree().create_timer(1).timeout
	Engine.time_scale = 1
	wall.set_deferred("disabled",true)
	SaveStates.get_notebook(notebook_number)
	SignalManager.collected_notebooks_signal.emit()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "main_player":
		set_cutscene()
		trigger.queue_free()
