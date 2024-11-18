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

##################################### States
enum STATE {CLOSE,OPEN}
var state = STATE.CLOSE
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	set_note()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if state == STATE.OPEN:
		notebook_control()

##################################### State functions
func open_book():
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
		if(page != SaveStates.notebooks.size()):
			text.get_v_scroll_bar().value = 0
			page+=1
			if(page <= 1):
				notebook_anime_play.play("open_front")
				print(SaveStates.notebooks[page])
				get_json_data(SaveStates.notebooks[page])
			elif(page >= SaveStates.notebooks.size()):
				notebook_anime_play.play("close_back")
			else:
				notebook_anime_play.play("flip_right")
				print(SaveStates.notebooks[page])	
				get_json_data(SaveStates.notebooks[page])
					
	elif Input.is_action_just_pressed("ui_left"):
		if(page != 0):
			text.get_v_scroll_bar().value = 0
			page-=1
			if(page >= SaveStates.notebooks.size()-1):
				notebook_anime_play.play("open_back")
				print(SaveStates.notebooks[page])
				get_json_data(SaveStates.notebooks[page])
			elif(page <= 0):
				notebook_anime_play.play("close_front")
			else:
				notebook_anime_play.play("flip_left")
				get_json_data(SaveStates.notebooks[page])
				print(SaveStates.notebooks[page])
	
	elif Input.is_action_pressed("ui_down"):
		text.get_v_scroll_bar().value += 10
	elif Input.is_action_pressed("ui_up"):
		text.get_v_scroll_bar().value -= 10

func load_json() -> Dictionary:
	var json_file = FileAccess.open("res://notebooks/_messages.json",FileAccess.READ)
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


func set_notebook():
	notebook_collect.text = str(SaveStates.notebooks.size()-1)+"/"+str(SaveStates.total_notebooks)
	notebook_anime_play.play("update_note")

func set_note():
	notebook_collect.text = str(SaveStates.notebooks.size()-1)+"/"+str(SaveStates.total_notebooks)

func activate_notebook():
	notebook_anime_play.play("first_notebook")

func notebook_empty():
	notebook_anime_play.play("empty")
