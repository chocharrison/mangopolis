extends CharacterBody3D


const SPEED = 7.0
const SLOW = 5.0


@onready var timer = get_node("timer")
@onready var anime = get_node("AnimationPlayer")

@onready var direction = Vector3(0,0,0)
 
##################################### States
enum STATE {IDLE, CHASE, CLOSE, MATH, STUNNED, KILLED, DISABLED, ENABLED}
@onready var state = STATE.IDLE
@onready var save_state = null

func _physics_process(_delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * _delta

	handle_state_transitions()
	perform_state_actions(_delta)
	move_and_slide()

func perform_state_actions(_delta):
	match state:
		STATE.IDLE:
			state_idle()
		STATE.MATH:
			state_math()
		STATE.CHASE:
			state_chase(_delta)
func handle_state_transitions():
	if state != STATE.ENABLED:
		return

func state_idle():
	anime.get("parameters/playback").travel("idle")

func state_math():
	anime.get("parameters/playback").travel("math")

func state_chase(_delta):
	pass
	#set_sprite_direction()
	#anime.get("parameters/playback").travel("chase")
	
func set_sprite_direction(target_position: Vector3):
	direction = (Vector3(target_position.x,0,target_position.z) - Vector3(position.x,0,position.z)).normalized()
	anime.set("parameters/idle/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
	anime.set("parameters/math/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
	anime.set("parameters/chase/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
