extends Node3D


var player1 : Player
var player2 : Player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player1 = get_node("coco")
	player2 = get_node("mango")
	if player1:
		print("player1 is assigned correctly")
	else:
		print("player1 assignment failed")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func check_player(player: Player):
	if player:
		return true # Emit the "hurt" signal with a damage value of 30
	else:
		print("player1 not found")
		return false

func _on_button_pressed() -> void:
	if check_player(player1):
		print("ouch")
		player1.emit_signal("hurt_signal", 30) # Emit the "hurt" signal with a damage value of 30


func _on_phase_toggled(toggled_on: bool) -> void:
	if check_player(player1):
		if toggled_on:
			print("switched to attack")
			player1.emit_signal("phase_switch_signal",1)
		else: 
			print("switched to defend")
			player1.emit_signal("phase_switch_signal",0)
