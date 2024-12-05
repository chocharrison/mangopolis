extends Node3D

@onready var is_interactive = false
@onready var is_open = false
@onready var obtain_notebook = false
@export var notebook_number = 17

@onready var show_fridge = $Control
@onready var fridge_open = $fridge2/previewRootNode_001
@onready var fridge_close = $fridge2/previewRootNode
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.interracted.connect(_on_interact)
	if notebook_number in SaveStates.notebooks:
		obtain_notebook = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_interact(panicked):
	if is_interactive: 
		if !is_open and !panicked:
			fridge_show()
		else:
			fridge_unshow()
	
func fridge_show():
	fridge_open.visible = true
	fridge_close.visible = false
	is_open = true
	show_fridge.visible = true
	if !obtain_notebook and !SaveStates.is_start:
		obtain_notebook = true
		SaveStates.get_notebook(notebook_number)
		SignalManager.collected_notebooks_signal.emit()

func fridge_unshow():
	fridge_open.visible = false
	fridge_close.visible = true
	is_open = false
	show_fridge.visible = false



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "main_player":
		SignalManager.show_interact_button_signal.emit(true)
		is_interactive = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "main_player":
		SignalManager.show_interact_button_signal.emit(false)
		is_interactive = false
		fridge_unshow()
