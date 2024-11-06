extends Node3D

signal collectible_signal(collectible_node: Node)

@export var message_id: String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("collectible_signal", Callable(self, "collectible"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_collect_body_entered(body: Node) -> void:
	if(body.name=="main_player"):
		collectible_signal.emit(self)
		print(message_id)
		queue_free()
