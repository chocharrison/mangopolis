extends Enemy

# Player 1 uses "jump_1" for jumping
func _ready() -> void:
	health = 80
	enemy_name = "witch"
	
	connect("hurt_signal", Callable(self, "hurt"))
	connect("banned_signal", Callable(self, "banned"))
