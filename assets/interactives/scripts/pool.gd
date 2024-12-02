extends Node3D

@onready var anim = $AnimationPlayer
@onready var notebook1_found = false
@onready var turn_piss = false

@export var notebook1_number = 6
@export var notebook2_number = 7

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if notebook1_number in SaveStates.notebooks:
		notebook1_found = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "main_player":
		if !turn_piss:
			anim.play("piss")
			turn_piss = true
		if !notebook1_found:
			notebook1_found = true
			SaveStates.get_notebook(notebook1_number)
			SignalManager.collected_notebooks_signal.emit()
