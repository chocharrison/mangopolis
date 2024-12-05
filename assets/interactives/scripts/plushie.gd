extends Node3D

@onready var anim = $AnimationPlayer
@onready var plush_offset = $StaticBody3D/AnimatedSprite3D
@onready var notebook_found = false
@export var plush_num = 1

@export var notebook_number = 6


var is_interactive = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if notebook_number in SaveStates.notebooks:
		notebook_found = true
	
	plush_offset.frame = plush_num
	SignalManager.interracted.connect(_on_interact)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_interact(panicked):
	if is_interactive:
		anim.play("boop")
		if !notebook_found and plush_num == 12:
			notebook_found = true
			SaveStates.get_notebook(notebook_number)
			SignalManager.collected_notebooks_signal.emit()
		
		

func _on_static_body_3d_body_entered(body: Node3D) -> void:
	if body.name == "main_player":
		SignalManager.show_interact_button_signal.emit(true)
		is_interactive = true




func _on_static_body_3d_body_exited(body: Node3D) -> void:
	if body.name == "main_player":
		SignalManager.show_interact_button_signal.emit(false)
		is_interactive = false
