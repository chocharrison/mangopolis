extends Control


# Called when the node enters the scene tree for the first time.
@onready var page = 0
@onready var is_interrupted = false
@onready var is_note = false
@onready var page_array = []


var notebook_anime_play:AnimationPlayer
var notebook:Control

var health_bar: TextureProgressBar
var health_label:Label
var health_potion: Label
var health_animation: AnimationPlayer

var stamina_bar: TextureProgressBar
var timer_bar: ProgressBar

var notebook_collect: Label

var main_player: CharacterBody3D
var players: Node3D

var math:Panel
var first:Label
var second:Label
var equation:Label
var answer:LineEdit
var math_anime:AnimationPlayer

var viewport: SubViewport
var text: RichTextLabel
var images: TextureRect


func _ready() -> void:
	notebook_anime_play = get_node("notebook_player")
	notebook = get_node("Control")
	notebook.set_process(false)
	
	math = get_node("math")
	math.set_process(false)
	math.visible = false
	math_anime = get_node("math_animation")
	
	health_bar = get_node("health")
	health_label = get_node("health/Label")
	health_animation = get_node("health_potion_animation")
	
	stamina_bar = get_node("stamina")
	timer_bar = get_node("math/timer")
	health_potion = get_node("health_potion/TextureRect/Label")
	notebook_collect = get_node("notebooks/Label")
	
	main_player = get_parent().get_node("main_player")
	players = get_parent()
	
	first = get_node("math/h/first")
	second = get_node("math/h/second")
	equation = get_node("math/h/operand")
	answer = get_node("math/h/answer")
	
	viewport = get_node("Control/text_x/text_y/SubViewportContainer/SubViewport")
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	
	text = get_node("Control/text_x/text_y/SubViewportContainer/SubViewport/RichTextLabel")
	images = get_node("Control/image_x/image_y/TextureRect")
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _input(event: InputEvent) -> void:

	if is_note:
		if Input.is_action_just_pressed("ui_right"):
			if(page != page_array.size()):
				text.get_v_scroll_bar().value = 0
				page+=1
				if(page <= 1):
					notebook_anime_play.play("open_front")
					print(page_array[page])
					get_json_data(page_array[page])
				elif(page >= page_array.size()):
					notebook_anime_play.play("close_back")
				else:
					notebook_anime_play.play("flip_right")
					print(page_array[page])
					get_json_data(page_array[page])
					
		elif Input.is_action_just_pressed("ui_left"):
			if(page != 0):
				text.visible = false
				text.get_v_scroll_bar().value = 0
				page-=1
				if(page >= page_array.size()-1):
					notebook_anime_play.play("open_back")
					print(page_array[page])
					get_json_data(page_array[page])
				elif(page <= 0):
					notebook_anime_play.play("close_front")
				else:
					notebook_anime_play.play("flip_left")
					get_json_data(page_array[page])
					print(page_array[page])
		
		elif Input.is_action_pressed("ui_down"):
			text.get_v_scroll_bar().value += 10
		elif Input.is_action_pressed("ui_up"):
			text.get_v_scroll_bar().value -= 10
			
			
func _process(delta: float) -> void:
	if is_interrupted:
		is_note = false
		notebook.set_process(false)
	
	
func set_note(val: bool):
	is_note = val
	if is_note:
		notebook.set_process(is_note)
		notebook_anime_play.play("read")
	else:
		notebook_anime_play.stop()
		if(page != 0):
			if(page == page_array.size()):
				notebook_anime_play.play("open_back")
			notebook_anime_play.queue("close_front")
		notebook_anime_play.queue("unread")
	page = 0
	text.visible = false
	images.visible = false
	
func load_json() -> Dictionary:
	print(FileAccess.file_exists("res://explore/notebooks/messages.json"))
	var json_file = FileAccess.open("res://explore/notebooks/messages.json",FileAccess.READ)
	print(json_file)
	var content = JSON.parse_string(json_file.get_as_text())
	print(content)
	return content

func get_json_data(index: int):
	var bday_cards = load_json()
	print(bday_cards[str(index)]["message"])
	if(bday_cards[str(index)].has("message")):
		text.visible = false
		var temp = FileAccess.open(bday_cards[str(index)]["message"],FileAccess.READ).get_as_text()
		text.text = str(page)+"\n\n"+temp+"\n \t-"+bday_cards[str(index)]["name"]
	else:
		text.txt = ""
	if(bday_cards[str(index)].has("image")):
		images.visible = false
		images.texture = load(bday_cards[str(index)]["image"])
	else:
		images.texture = null
	


func set_health(val: int):
	health_bar.value = val
	health_label.text = str(val)

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
	math_anime.play("math_success")
	is_interrupted = false

func math_failure():
	answer.release_focus()
	math_anime.play("math_failure")
	is_interrupted = false

func math_enter():
	answer.clear()
	math.set_process(true)
	math_anime.play("math_enter")
	is_interrupted = true
	answer.grab_focus()

func set_timer(val: int):
	timer_bar.value = val
	
func set_notebook_array(val:int,maxim:int):
	notebook_collect.text = str(val)+"/"+str(maxim)
	notebook_anime_play.play("update_notebook")

func set_array(array: Array):
	page_array = array
	
func health_picked(val: int):
	health_potion.text = str(val)
	health_animation.play("health_picked")

func health_exhaust(val: int):
	health_potion.text = str(val)
	health_animation.play("health_exhaust")

func health_used(val: int):
	health_potion.text = str(val)
	health_animation.play("health_used")	
