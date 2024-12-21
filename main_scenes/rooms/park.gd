extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if SaveStates.notebooks.size()-1 >= SaveStates.total_notebooks:
		if !SaveStates.already_shown:
			SaveStates.already_shown = true
			SignalManager.grunt_inactive.emit()
			show_door_open()
		$houses/shed.open_door()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func show_door_open():
	$Camera3D.current = true
	$Timer.start()
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	$Timer.stop()
	$Camera3D.current = false
	SignalManager.math_in_session.emit(false)
