extends Node3D

var camera_controller: Node3D
var players: Node3D

signal math_signal(level: int,damage: int,iteration: int)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera_controller = get_node("camera_controller")
	#players = get_node("Players")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	print("no")
	SignalManager.signal_math.emit(5,30,0)
