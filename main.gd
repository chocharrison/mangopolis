extends Node3D


var player1 : Player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player1 = get_node("player_2")
	if player1:
		print("player1 is assigned correctly")
	else:
		print("player1 assignment failed")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	print("ouch")
	if player1:
		print("yes")
		player1.emit_signal("hurt", 30) # Emit the "hurt" signal with a damage value of 30
	else:
		print("player1 not found")
