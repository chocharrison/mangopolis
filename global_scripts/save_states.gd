extends Node


@export var notebooks = [0]
@export var plushies = []

var already_shown = false
var is_new_game = true
var checkpoint = {}
var checkpoint_name = null
var saved_scene = null
var is_start = false
var first_meet = true
var first_death = false
@export var health = 100
@export var health_potion = 5
@export var total_notebooks = 22
@export var baby_mode = false

func _ready() -> void:
	SignalManager.plushie_press.connect(get_plush)

func get_notebook(message_id: int):
	notebooks.insert(1,message_id)

func save_health(val: int):
	health = val

func save_health_potion(val: int):
	health_potion = val

func game_reset():
	notebooks = [0]
	plushies = []
	already_shown = false
	is_new_game = true
	checkpoint = {}
	checkpoint_name = null
	saved_scene = null
	is_start = false
	first_meet = true
	health = 100
	health_potion = 5
	total_notebooks = 22
	baby_mode = false
	first_death = false

func set_checkpoint(val,pos,sub_pos):
	checkpoint[get_tree().current_scene.name] = [val,sub_pos,pos]
	
func get_player_pos():
	return checkpoint[get_tree().current_scene.name]

func is_checkpoint():
	print(get_tree().current_scene.name)
	if checkpoint.has(get_tree().current_scene.name):
		return true
	return false
	
func check_point_name():
	if checkpoint.has(get_tree().current_scene.name):
		return checkpoint[get_tree().current_scene.name][0]
	return null

func get_scene():
	return saved_scene

func set_scene():
	saved_scene = get_tree().current_scene.scene_file_path

func get_plush(i: int):
	if i not in plushies:
		plushies.append(i)
