extends Area3D

@export var notebook_number = 21
var is_interactive = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if notebook_number in SaveStates.notebooks:
		queue_free()
	SignalManager.interracted.connect(_on_interact)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_interact(panicked):
	if is_interactive and !panicked:
		SaveStates.get_notebook(notebook_number)
		SignalManager.collected_notebooks_signal.emit()
		queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body.name == "main_player":
		SignalManager.show_interact_button_signal.emit(true)
		is_interactive = true
