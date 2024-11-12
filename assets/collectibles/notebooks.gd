extends Node3D

@export var message_id: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if SaveStates.notebooks.has(message_id):
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

#collected notebook if player
func _on_collect_body_entered(body: Node) -> void:
	if(body.name=="main_player"):
		print(name)
		SaveStates.get_notebook(message_id)
		print(self)
		SignalManager.collected_notebooks_signal.emit()
		
		queue_free()
