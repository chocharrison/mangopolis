extends Control

@onready var health_potion_ui = $health_potion
@onready var math_ui = $math_ui
@onready var notebook_ui = $NotebookUi
@onready var coco_ui = $coco
@onready var interact_ui = $interact_master
@onready var stamina_ui = $stamina
@onready var health_ui = $health
@onready var health_text_ui = $health/Label
@onready var soundeffects = $AudioStreamPlayer
@onready var anime = $ui
@onready var hurt = $hurt
#misc ui

func _ready() -> void:
	interact_ui.visible = false
	
	
func set_health(val: int):
	health_ui.value = val
	health_text_ui.text = str(val)
	
func set_stamina(val: int):
	stamina_ui.value = val 

func set_interact(val: bool):
	interact_ui.visible = val

func set_coco(coco: String):
	coco_ui.play(coco)
	
func health_lost():
	var rand = randi_range(1,4)
	soundeffects.stream = load("res://assets/players/sound effects/mango_hurt_"+str(rand)+".mp3")
	soundeffects.play()
	hurt.play("hurt")

func play_ded():
	anime.play("interrupted")
	hurt.play("death")
	
	
#health potions ui
func health_picked(val: int):
	health_potion_ui.health_picked(val)

func health_exhaust(val: int):
	health_potion_ui.health_exhaust(val)

func health_used(val: int):
	health_potion_ui.health_used(val)

#math ui
func math_ui_set(val: int, val2: int,val3: String):
	math_ui.set_first(val)
	math_ui.set_second(val2)
	math_ui.set_equation(val3)
	math_ui.math_enter()

func math_ui_set_timer(val: int):
	math_ui.set_timer(val)

func math_ui_success():
	math_ui.math_success()
	anime.play("back")
	
func math_ui_failure():
	math_ui.math_failure()
	anime.play("back")
	
func math_ui_enter():
	math_ui.math_enter()
	
#notebook ui
func notebook_ui_get_notebook():
	notebook_ui.set_notebook()

func notebook_ui_open_book():
	anime.play("interrupted_notebook")
	notebook_ui.open_book()

func notebook_ui_close_book():
	anime.play("back_notebook")
	notebook_ui.close_book()

func notebook_empty():
	notebook_ui.notebook_empty()
func interrupted():
	print("inteerupted ui")
	anime.play("interrupted")
	notebook_ui.interrupted()

func activate_notebook():
	notebook_ui.activate_notebook()

func _on_hurt_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"death":
			get_tree().change_scene_to_file("res://main_scenes/hub.tscn")
