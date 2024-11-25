extends Node3D

@onready var melonkitty = $Melonkitty

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_trigger_intro_area_entered(area: Area3D) -> void:
	melonkitty.play_intro()
	$trigger_intro.queue_free()
