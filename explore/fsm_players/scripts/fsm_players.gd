extends Node3D

############################################## exports
@export var page_array = [0,1,2,3]

############################################## constants
const MAX_PAGE = 10

############################################## nodes
@onready var main_player = $main_player
@onready var sub_player = $sub_player

@onready var notebookui = $Explore_ui/NotebookUi

############################################## flags
@onready var is_note = false

##################################### States
enum STATE {ENABLE,DISABLED}
var state = STATE.ENABLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.collected_notebooks_signal.connect(_on_collected_notebooks_signal)
	notebookui.set_notebook_array(page_array.size()-1,MAX_PAGE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state == STATE.ENABLE:
		inputs()

func inputs():
	if Input.is_action_just_pressed("notebook"):
		if !is_note:
			notebookui.open_book(page_array)
			main_player.disable_controls()
			sub_player.disable_controls()
			is_note = true
			#pause_health_timer(is_note)
			#panic_timer.set_paused(is_note)
			#far_timer.set_paused(is_note)
		else:
			is_note = false
			notebookui.close_book()
			main_player.enable_controls()
			sub_player.enable_controls()


func interruption():
	state = STATE.DISABLED
	notebookui.interrupted()
	main_player.disable_controls()
	sub_player.disable_controls()
	#pause_health_timer(is_note)
	#panic_timer.set_paused(is_note)
	#far_timer.set_paused(is_note)
	

func update_array(val: int):
	page_array.append(val)
	notebookui.set_notebook_array(page_array.size()-1,MAX_PAGE)

func give_main_player_position():
	return main_player.position


func _on_collected_notebooks_signal(val:int) -> void:
	update_array(val)
