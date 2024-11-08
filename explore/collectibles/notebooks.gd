extends Node3D

@export var message_id: int

signal collected_notebook_signal
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#collected notebook if player
func _on_collect_body_entered(body: Node) -> void:
	if(body.name=="main_player"):
		print(message_id)
		emit_signal("collected_notebook_signal",message_id)
		queue_free()
