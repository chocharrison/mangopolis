extends Player

# Player 1 uses "jump_1" for jumping
func _ready() -> void:
	jump_key = "jump_1"
	JUMP_VELOCITY = 4.5
	health = 80
	player_name = "mango"
	connect("hurt", Callable(self, "hurt_me"))
	connect("downed", Callable(self, "banned"))
