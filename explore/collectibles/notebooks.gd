extends Node3D

@export var message_id: int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_collect_body_entered(body: Node) -> void:
	if(body.name=="main_player"):
		print(message_id)
		#the player updates collectibles goes here
		queue_free()
