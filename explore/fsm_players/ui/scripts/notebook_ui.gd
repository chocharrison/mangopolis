extends Control

##################################### nodes
@onready var notebook_anime_play = get_node("AnimationPlayer")
@onready var notebook = get_node("Control")

@onready var notebook_collect = get_node("notebooks/Label")

@onready var viewport = get_node("Control/text_x/text_y/SubViewportContainer/SubViewport")
@onready var text = get_node("Control/text_x/text_y/SubViewportContainer/SubViewport/RichTextLabel")
@onready var images = get_node("Control/image_x/image_y/TextureRect")
@onready var text_visible = get_node("Control/text_x")
@onready var images_visible = get_node("Control/image_x")


##################################### variables
@onready var page = 0
@onready var page_array = []

##################################### States
enum STATE {CLOSE,OPEN}
var state = STATE.CLOSE
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if state == STATE.OPEN:
		notebook_control()

##################################### State functions
func open_book(array: Array):
	page_array = array
	state = STATE.OPEN
	notebook_anime_play.play("get_note")
	page = 0

func close_book():
	state = STATE.CLOSE
	notebook_anime_play.play("send_note")
	page = 0

func interrupted():
	print("interrupted")
	if state == STATE.OPEN:
		notebook_anime_play.play("send_note")
		page = 0
	state = STATE.CLOSE
##################################### notebook functions
# Set the notebook open/close state, updating animations and resetting the page number and visibility of elements.
func notebook_control():
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

func load_json() -> Dictionary:
	print(FileAccess.file_exists("res://explore/notebooks/messages.json"))
	var json_file = FileAccess.open("res://explore/notebooks/messages.json",FileAccess.READ)
	print(json_file)
	var content = JSON.parse_string(json_file.get_as_text())
	print(content)
	return content

func get_json_data(index: int):
	var bday_cards = load_json()
	images_visible.visible = false
	text_visible.visible = false
	print(bday_cards[str(index)]["message"])
	if(bday_cards[str(index)].has("message")):
		var temp = FileAccess.open(bday_cards[str(index)]["message"],FileAccess.READ).get_as_text()
		text.text = str(page)+"\n\n"+temp+"\n \t-"+bday_cards[str(index)]["name"]
	else:
		text.txt = ""
	if(bday_cards[str(index)].has("image")):
		images.texture = load(bday_cards[str(index)]["image"])
	else:
		images.texture = null


func set_notebook_array(val:int,maxim:int):
	notebook_collect.text = str(val)+"/"+str(maxim)
	notebook_anime_play.play("update_note")
