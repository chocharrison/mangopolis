extends Node3D

var camera_controller: Node3D
var main_player: CharacterBody3D
var sub_player: CharacterBody3D
@onready var is_cutscene = false

signal set_cutscene_signal(name: String)

signal collectible_signal(collectible: Node3D)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera_controller = get_node("camera_controller")
	main_player = get_node("Players/main_player")
	sub_player = get_node("Players/sub_player")
	for collectible in get_tree().get_nodes_in_group("Collectibles"):
		collectible.connect("collectible_signal", Callable(self, "collected")) 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !is_cutscene:
		var camera_position = camera_controller.position
		camera_position.x = lerp(camera_position.x, main_player.position.x, 0.1)
		camera_position.y = lerp(camera_position.y, main_player.position.y, 0.1)
		camera_position.z = lerp(camera_position.z, main_player.position.z, 0.1)
		camera_controller.position = camera_position

func set_cutscene(scene: bool):
	is_cutscene = scene

func collected(collectible: Node3D):
	print(collectible.name)


func _on_button_pressed() -> void:
	emit_signal("math_signal",0)
