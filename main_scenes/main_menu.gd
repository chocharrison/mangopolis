extends Control


@onready var reset = $"settings/TextureRect/reset"
@onready var settings = $"settings"
@onready var anime = $"AnimationPlayer"
@onready var menu = $"ui"
@onready var label = $"settings/TextureRect/baby_mode/Label"
@onready var notebook = $"settings/TextureRect/notebooks"
@onready var text_start = $ui/start/Label


@onready var is_baby = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = false
	settings.set_process(false)
	anime.play("enter")
	if !SaveStates.is_new_game:
		not_new_game()
	else:
		new_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func not_new_game():
	reset.disabled = false
	notebook.disabled = false
	notebook.visible = true
	text_start.text = "continue"
	
func new_game():
	reset.disabled= true
	notebook.disabled = true
	notebook.visible = false
	text_start.text = "start"
	SaveStates.game_reset()
	SaveStates.is_new_game = true

func resume_game():
	reset.disabled = false
	notebook.disabled = false
	notebook.visible = true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	print(anim_name)
	match anim_name:
		"quit":
			get_tree().quit()
		"start":
			if SaveStates.get_scene() == null:
				get_tree().change_scene_to_file("res://main_scenes/rooms/bedroom.tscn")
			else:
				get_tree().change_scene_to_file(SaveStates.get_scene())
			SaveStates.is_new_game = false
			
			
func _on_settings_pressed() -> void:
	settings.set_process(true)
	menu.set_process(false)
	anime.play("settings_in")

func _on_quit_pressed() -> void:
	print("quit")
	menu.set_process(false)
	anime.play("quit")

func _on_back_pressed() -> void:
	menu.set_process(true)
	settings.set_process(false)
	anime.play("settings_out")

func _on_notebooks_pressed() -> void:
	OS.shell_open("https://recocards.com/board/happy-birthday-mango-99341455809")


func _on_reset_pressed() -> void:
	print("game reset")
	new_game()

func _on_baby_mode_pressed() -> void:
	if !is_baby:
		label.text = "baby mode on"
		is_baby = true
	else:
		label.text = "baby mode off"
		is_baby = false


func _on_start_pressed() -> void:
	print("press")
	anime.play("start")
