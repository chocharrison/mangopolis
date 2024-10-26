extends Player

# Player 1 uses "jump_1" for jumping
func _ready() -> void:
	jump_key = "jump_2"
	attack_key = "attack_2"
	upper_key = "upper_2"
	
	JUMP_VELOCITY = 7
	player_name = "coco"
	health = 50
	anim_player = get_node("AnimationPlayer")
	animated = get_node("AnimatedSprite3D")
	
	
	connect("hurt", Callable(self, "hurt_me"))
	connect("downed", Callable(self, "banned"))

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	animationOver()
