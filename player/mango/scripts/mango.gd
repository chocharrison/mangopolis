extends Player

# Player 1 uses "jump_1" for jumping
func _ready() -> void:
	
	phase = PHASE.DEFEND
	
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
	connect("switch_phase", Callable(self, "phase_switch"))

func _process(delta: float) -> void:
	pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	animationOver()