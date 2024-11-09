extends Control


const hurt_audios = 4
##################################### nodes
var notebook_anime_play:AnimationPlayer
var notebook:Control
var soundeffects: AudioStreamPlayer

var health_bar: TextureProgressBar
var health_label:Label
var health_potion: Label
var health_animation: AnimationPlayer

var stamina_bar: TextureProgressBar

var notebook_collect: Label

var main_player: CharacterBody3D
var players: Node3D

var viewport: SubViewport
var text: RichTextLabel
var images: TextureRect

var coco: AnimatedSprite2D
var interact: AnimatedSprite2D

##################################### flags
@onready var is_interrupted = false
@onready var is_note = false

##################################### variables
@onready var page = 0
@onready var page_array = []

##################################### default functions
# Set up references to the notebook's animation player, control, health bars, and other UI elements.
# Set the viewport's default texture filter for rendering.
# Hide the interaction sprite initially and disable notebook processing by default.
func _ready() -> void:
	
	
	notebook_anime_play = get_node("notebook_player")
	notebook = get_node("Control")
	notebook.set_process(false)
	
	health_bar = get_node("health")
	health_label = get_node("health/Label")
	health_animation = get_node("health_potion_animation")
	
	stamina_bar = get_node("stamina")
	health_potion = get_node("health_potion/TextureRect/Label")
	notebook_collect = get_node("notebooks/Label")
	
	main_player = get_parent().get_node("main_player")
	players = get_parent()
	
	viewport = get_node("Control/text_x/text_y/SubViewportContainer/SubViewport")
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	
	text = get_node("Control/text_x/text_y/SubViewportContainer/SubViewport/RichTextLabel")
	images = get_node("Control/image_x/image_y/TextureRect")
	
	soundeffects = get_node("AudioStreamPlayer")
	
	coco = get_node("coco")
	interact = get_node("interact_master")
	
	interact.visible = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.

# Handle input events when the notebook is open, calling a function to control notebook page turning.
func _input(event: InputEvent) -> void:
	if is_note:
		notebook_control()
			
# If interrupted, stop notebook processing and set the notebook to a non-active state.
func _process(delta: float) -> void:
	if is_interrupted:
		is_note = false
		notebook.set_process(false)
	
##################################### custom functions
# Handle input to flip pages in the notebook, checking the current page and updating the display and animations accordingly.
# If the right arrow is pressed, advance to the next page and update the notebook animation.
# If the left arrow is pressed, go back to the previous page and update the notebook animation.
# Handle scrolling through the text with up/down arrow keys.
func notebook_control():
	if Input.is_action_just_pressed("ui_right"):
		if(page != page_array.size()):
			text.get_v_scroll_bar().value = 0
			page+=1
			soundeffects.stream = load("res://explore/sound_effects/flip.mp3")
			soundeffects.play()
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
			soundeffects.stream = load("res://explore/sound_effects/flip.mp3")
			soundeffects.play()
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

# Load JSON data from a file containing notebook messages and return the parsed content as a dictionary.
func load_json() -> Dictionary:
	print(FileAccess.file_exists("res://explore/notebooks/messages.json"))
	var json_file = FileAccess.open("res://explore/notebooks/messages.json",FileAccess.READ)
	print(json_file)
	var content = JSON.parse_string(json_file.get_as_text())
	print(content)
	return content

# Retrieve and display the text and images from the JSON data based on the current page.
# If a message exists, display the text and image; otherwise, clear the fields.
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

##################################### set functions
# Set the notebook open/close state, updating animations and resetting the page number and visibility of elements.
func set_note(val: bool):
	is_note = val
	if is_note:
		notebook.set_process(is_note)
		play_notebook()
		notebook_anime_play.play("read")
	else:
		notebook_anime_play.stop()
		if(page != 0):
			if(page == page_array.size()):
				notebook_anime_play.play("open_back")
				flip_notebook()
			notebook_anime_play.queue("close_front")
			flip_notebook()
		notebook_anime_play.queue("unread")
		play_notebook()
	page = 0
	text.visible = false
	images.visible = false

# Update the health bar and health label with the current health value.
func set_health(val: int):
	health_bar.value = val
	health_label.text = str(val)

# Update the stamina bar with the current stamina value.
func set_stamina(val: int):
	stamina_bar.value = val 

# Set whether the notebook process has been interrupted.
func set_interrupted(val: bool):
	is_interrupted = val
	
# Update the notebook collection label to display the current notebook count out of the maximum number of notebooks.
func set_notebook_array(val:int,maxim:int):
	notebook_collect.text = str(val)+"/"+str(maxim)
	notebook_anime_play.play("update_notebook")

# Set the array of notebook pages.
func set_array(array: Array):
	page_array = array
	
# Play the appropriate animation for the "coco" animated sprite.
func set_coco(coco_ui: String):
	coco.play(coco_ui)

# Show or hide the interaction indicator sprite.
func set_interact(val: bool):
	interact.visible = val

##################################### animation functions
# Update the health potion text and play the animation for picking up health.
func health_picked(val: int):
	health_potion.text = str(val)
	health_animation.play("health_picked")

# Update the health potion text and play the animation for exhausting health.
func health_exhaust(val: int):
	health_potion.text = str(val)
	health_animation.play("health_exhaust")

# Update the health potion text and play the animation for using health.
func health_used(val: int):
	health_potion.text = str(val)
	health_animation.play("health_used")

func health_lost():
	var rand = randi_range(1,4)
	soundeffects.stream = load("res://explore/sound_effects/mango_hurt_"+str(rand)+".mp3")
	soundeffects.play()

func play_ded():
	soundeffects.stream = load("res://explore/sound_effects/mango_ded.mp3")
	soundeffects.play()

func play_notebook():
	soundeffects.stream = load("res://explore/sound_effects/get_note.mp3")
	soundeffects.play()

func flip_notebook():
	soundeffects.stream = load("res://explore/sound_effects/flip.mp3")
	soundeffects.play()
