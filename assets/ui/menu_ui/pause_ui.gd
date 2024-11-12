extends Control

@onready var anime = get_node("AnimationPlayer")
@onready var is_math = false
@onready var pause = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.math_in_session.connect(_is_math_in_session)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("esc") and !is_math:
		if !pause:
			paused()
		else:
			unpaused()

func _is_math_in_session(val: bool):
	is_math = val

func paused():
	get_tree().paused = true
	anime.play("enable")
	pause = true

func unpaused():
	anime.play("resume")
	pause = false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"resume":
			get_tree().paused = false 
		"quit":
			SaveStates.set_scene()
			get_tree().change_scene_to_file("res://main_scenes/main_menu.tscn")


func _on_resume_pressed() -> void:
	unpaused()


func _on_settings_pressed() -> void:
	print("boo")


func _on_quit_pressed() -> void:
	anime.play("quit")
