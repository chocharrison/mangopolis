extends Node3D

signal math_signal(level: int,damage: int,iteration: int)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	print("no")
	SignalManager.signal_math.emit(5,30,0)
