extends Node3D

@onready var anim = $AnimationPlayer
@onready var notebook_found = false

@export var notebook_number = 6
@onready var audio = $AudioStreamPlayer

var is_interactive = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if notebook_number in SaveStates.notebooks:
		notebook_found = true
	audio.stream = load("res://assets/interactives/sound effects/tree.mp3")
	SignalManager.interracted.connect(_on_interact)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_interact(panicked):
	if is_interactive:
		audio.play()
		anim.play("shake")
		if !notebook_found:
			notebook_found = true
			SaveStates.get_notebook(notebook_number)
			SignalManager.collected_notebooks_signal.emit()
		

func _on_static_body_3d_body_entered(body: Node3D) -> void:
	if body.name == "main_player":
		print("interact")
		SignalManager.show_interact_button_signal.emit(true)
		is_interactive = true




func _on_static_body_3d_body_exited(body: Node3D) -> void:
	if body.name == "main_player":
		print("uninteract")
		SignalManager.show_interact_button_signal.emit(false)
		is_interactive = false
