extends Player

# Player 1 uses "jump_1" for jumping
func _ready() -> void:
	jump_key = "jump_2"
	JUMP_VELOCITY = 2.5
	player_name = "coco"
	health = 50
	connect("hurt", Callable(self, "hurt_me"))
	connect("downed", Callable(self, "banned"))
