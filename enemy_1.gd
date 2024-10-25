extends Enemy

# Player 1 uses "jump_1" for jumping
func _ready() -> void:
	JUMP_VELOCITY = 4.5
	health = 80
	enemy_name = "witch"
	connect("hurt", Callable(self, "hurt_me"))
	connect("downed", Callable(self, "banned"))
