extends Control

var is_note = false
# Called when the node enters the scene tree for the first time.

var anime:AnimationPlayer
var notebook:Control
var page = 0
const MAX_PAGE = 10

var health_bar: TextureProgressBar
var stamina_bar: TextureProgressBar

var main_player: CharacterBody3D
var players: Node3D


func _ready() -> void:
	anime = get_node("AnimationPlayer")
	notebook = get_node("Control")
	notebook.set_process(false)
	health_bar = get_node("health")
	stamina_bar = get_node("stamina")
	main_player = get_parent().get_node("main_player")
	players = get_parent()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("notebook"):
		if !is_note:
			is_note = true
			notebook.set_process(is_note)
			anime.play("read")
			main_player.disable_control(is_note)
			players.pause_health_timer(is_note)
		else:
			anime.stop()
			if(page == MAX_PAGE):
				anime.play("open_back")
			if(page!=0):
				anime.queue("close_front")
			page = 0
			is_note = false
			anime.queue("unread")
			notebook.set_process(is_note)
			main_player.disable_control(is_note)
			players.pause_health_timer(is_note)
	
	if is_note:
		if Input.is_action_just_pressed("ui_right"):
			if(page != MAX_PAGE):
				print(page)
				page+=1
				if(page==1):
					anime.queue("open_front")
				elif(page==MAX_PAGE):
					anime.queue("close_back")
				else:
					anime.queue("flip_right")
		elif Input.is_action_just_pressed("ui_left"):
			if(page != 0):
				print(page)
				page-=1
				if(page==MAX_PAGE-1):
					anime.queue("open_back")
				elif(page==0):
					anime.queue("close_front")
				else:
					anime.queue("flip_left")

func set_health(val: int):
	health_bar.value = val

func set_stamina(val: int):
	stamina_bar.value = val 
