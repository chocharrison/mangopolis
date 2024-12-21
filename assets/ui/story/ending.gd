extends Control

@onready var anim = $AnimationPlayer
@onready var audio = $AudioStreamPlayer
@export var starting_scene: String
var cutscene_index = 0
var end_scene = 6
var can_next = false
var next = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim.play("story_0")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
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

func unlock():
	can_next = true

func end_game():
	get_tree().change_scene_to_file(starting_scene)
