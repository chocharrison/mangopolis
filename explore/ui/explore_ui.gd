extends Control


# Called when the node enters the scene tree for the first time.

var anime:AnimationPlayer
var notebook:Control

@onready var page = 0
@onready var is_interrupted = false
@onready var is_note = false

const MAX_PAGE = 10

var health_bar: TextureProgressBar
var stamina_bar: TextureProgressBar
var timer_bar: ProgressBar

var main_player: CharacterBody3D
var players: Node3D

var math:Panel
var first:Label
var second:Label
var equation:Label
var answer:LineEdit

func _ready() -> void:
	anime = get_node("AnimationPlayer")
	math = get_node("math")
	math.set_process(false)
	math.visible = false
	notebook = get_node("Control")
	notebook.set_process(false)
	health_bar = get_node("health")
	stamina_bar = get_node("stamina")
	timer_bar = get_node("math/timer")
	
	main_player = get_parent().get_node("main_player")
	players = get_parent()
	
	first = get_node("math/h/first")
	second = get_node("math/h/second")
	equation = get_node("math/h/operand")
	answer = get_node("math/h/answer")
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("notebook") and !is_interrupted:
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
	
func _process(delta: float) -> void:
	if is_interrupted:
		is_note = false
		notebook.set_process(false)
		notebook.visible = false
	
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

func set_interrupted(val: bool):
	is_interrupted = val

func set_first(val: int):
	first.text = str(val)

func set_second(val: int):
	second.text = str(val)
	
func set_equation(val: String):
	equation.text = str(val)
	
func math_success():
	answer.release_focus()
	anime.play("math_success")
	is_interrupted = false

func math_failure():
	answer.release_focus()
	anime.play("math_failure")
	is_interrupted = false

func math_enter():
	answer.clear()
	math.set_process(true)
	anime.play("math_enter")
	is_interrupted = true
	answer.grab_focus()

func set_timer(val: int):
	timer_bar.value = val
	
