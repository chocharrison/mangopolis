extends Control

@onready var anim = $AnimationPlayer
@onready var audio = $AudioStreamPlayer
@export var starting_scene: String
var cutscene_index = 0
var end_scene = 8
var can_next = false
var next = true
@onready var start_music = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim.play("disclaimer")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !audio.is_playing() and start_music:
		audio.stream = load("res://main_scenes/main_theme.mp3")
		audio.play()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and start_music:
		if can_next:
			can_next = false
			cutscene_index+=1
			if cutscene_index == end_scene:
				anim.play("story_end")
			else:
				anim.play("story_"+str(cutscene_index))
		else:
			if cutscene_index == 0:
				anim.seek(7)
			else:
				anim.seek(6)

func disclaimer_done():
	anim.play("story_0")
	start_music = true

func unlock():
	can_next = true

func start_game():
	get_tree().change_scene_to_file(starting_scene)
