extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if SaveStates.is_new_game:
		visible = true
		get_tree().paused = true
	else:
		queue_free()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("esc"):
		SaveStates.is_new_game = false
		get_tree().paused = false
		queue_free()
