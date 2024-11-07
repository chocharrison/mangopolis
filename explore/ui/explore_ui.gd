extends Control


# Called when the node enters the scene tree for the first time.

var anime:AnimationPlayer
var notebook_anim: AnimatedSprite2D
var notebook:Control

@onready var page = 0
@onready var is_interrupted = false
@onready var is_note = false
@onready var page_array = []

var health_bar: TextureProgressBar
var stamina_bar: TextureProgressBar
var timer_bar: ProgressBar
var health_potion: Label
var notebook_collect: Label

var main_player: CharacterBody3D
var players: Node3D

var math:Panel
var first:Label
var second:Label
var equation:Label
var answer:LineEdit

var viewport: SubViewport
var text: RichTextLabel
var images: TextureRect


func _ready() -> void:
	anime = get_node("AnimationPlayer")
	notebook_anim = get_node("Control/notebook_inventory")
	math = get_node("math")
	math.set_process(false)
	math.visible = false
	notebook = get_node("Control")
	notebook.set_process(false)
	health_bar = get_node("health")
	stamina_bar = get_node("stamina")
	timer_bar = get_node("math/timer")
	health_potion = get_node("health_potion/Label")
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
	if Input.is_action_just_pressed("notebook") and !is_interrupted:
		if !is_note:
			is_note = true
			notebook.set_process(is_note)
			anime.play("read")
			main_player.disable_control(is_note)
			players.pause_health_timer(is_note)
			page_array = players.get_array()
		else:
			anime.stop()
			if(page == page_array.size()):
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
	
	if is_note:			
		if Input.is_action_just_pressed("ui_right"):
			if(page != page_array.size()):
				text.get_v_scroll_bar().value = 0
				page+=1
				if(page <= 1):
					anime.queue("open_front")
					print(page_array[page])
					get_json_data(page_array[page])
				elif(page >= page_array.size()):
					anime.queue("close_back")
				else:
					anime.queue("flip_right")
					print(page_array[page])
					get_json_data(page_array[page])
					
		elif Input.is_action_just_pressed("ui_left"):
			if(page != 0):
				text.visible = false
				text.get_v_scroll_bar().value = 0
				page-=1
				if(page >= page_array.size()-1):
					anime.queue("open_back")
					print(page_array[page])
					get_json_data(page_array[page])
				elif(page <= 0):
					anime.queue("close_front")
				else:
					anime.queue("flip_left")
					get_json_data(page_array[page])
					print(page_array[page])
		
		elif Input.is_action_pressed("ui_down"):
			text.get_v_scroll_bar().value += 4
		elif Input.is_action_pressed("ui_up"):
			text.get_v_scroll_bar().value -= 4
	
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
		text.text = temp+"\n \t-"+bday_cards[str(index)]["name"]
	else:
		text.txt = ""
	if(bday_cards[str(index)].has("image")):
		images.visible = false
		images.texture = load(bday_cards[str(index)]["image"])
	else:
		images.texture = null
	


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

func set_health_potion(val: int):
	health_potion.text = str(val)
	
func set_notebook_array(val:int,maxim:int):
	notebook_collect.text = str(val)+"/"+str(maxim)
	anime.play("update_notebook")
	
