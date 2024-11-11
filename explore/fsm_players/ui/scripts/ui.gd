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

#misc ui
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
	soundeffects.stream = load("res://explore/fsm_players/sound effects/mango_hurt_"+str(rand)+".mp3")
	soundeffects.play()

func play_ded():
	soundeffects.stream = load("res://explore/fsm_players/sound effects/mango_ded.mp3")
	soundeffects.play()
	
	
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

func math_ui_failure():
	math_ui.math_failure()

func math_ui_enter():
	math_ui.math_enter()
	
#notebook ui
func notebook_ui_set_array(val:int,maxim:int):
	notebook_ui.set_notebook_array(val,maxim)

func notebook_ui_open_book(array: Array):
	notebook_ui.open_book(array)

func notebook_ui_close_book():
	notebook_ui.close_book()

func interrupted():
	print("inteerupted ui")
	notebook_ui.interrupted()
