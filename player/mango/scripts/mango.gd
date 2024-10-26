extends Player

# Player 1 uses "jump_1" for jumping
func _ready() -> void:
	jump_key = "jump_1"
	attack_key = "attack_1"
	upper_key = "upper_1"
	
	JUMP_VELOCITY = 4.5
	health = 80
	player_name = "mango"
	anim_player = get_node("AnimationPlayer")
	animated = get_node("AnimatedSprite3D")
	
	connect("hurt", Callable(self, "hurt_me"))
	connect("downed", Callable(self, "banned"))
	connect("animationover",Callable(self,"animationOver"))


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	animationOver()
