extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.start(10)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_timer_timeout() -> void:
	$Timer.stop()
	OS.shell_open("https://recocards.com/board/happy-birthday-mango-99341455809")
