extends Node3D

signal collected_healthpotions_signal
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_collect_body_entered(body: Node) -> void:
	if(body.name=="main_player"):
		emit_signal("collected_healthpotions_signal")
		#the player updates collectibles goes here
		queue_free()
