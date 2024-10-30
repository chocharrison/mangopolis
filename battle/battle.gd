extends Node3D


signal health_change(player: Player)

var players = [] 
var health_storage = {}

func _ready() -> void:
	var coco = get_node("coco")
	var mango = get_node("mango")
	players = [coco, mango]
	
	for player in players:
		if player:
			setup_player(player)
			player.connect("health_change", Callable(self,"_on_health_change"))  # Connect signal
		else:
			print("Error: Player node not found.")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func check_player(player: Player):
	if player:
		return true # Emit the "hurt" signal with a damage value of 30
	else:
		print("player not found")
		return false

func _on_button_pressed() -> void:
	if check_player(players[0]):
		print("ouch")
		players[0].emit_signal("hurt_signal", 30) # Emit the "hurt" signal with a damage value of 30


func _on_phase_toggled(toggled_on: bool) -> void:
	if check_player(players[0]):
		if toggled_on:
			print("switched to attack")
			players[0].emit_signal("phase_switch_signal",1)
		else: 
			print("switched to defend")
			players[0].emit_signal("phase_switch_signal",0)


################ activate when health status has changed
func _on_health_change(player: Player) -> void:
	var player_ui = get_node("ui/" + player.name + "_ui")
	var health_label = player_ui.get_node("health")

	var health_info = player.get_health_info()
	health_label.text = str(health_info[0]) + "/" + str(health_info[1])
	
	health_storage[player.name] = health_info[0]

######################## set up the players
func setup_player(player: Player) -> void:
	var player_ui = get_node("ui/" + player.name + "_ui")

	var health_label = player_ui.get_node("health")
	var name_label = player_ui.get_node("name")

	name_label.text = player.player_name
	var health_info = player.get_health_info()
	health_label.text = str(health_info[0]) + "/" + str(health_info[1])
	
	health_storage[player.name] = health_info[0]
