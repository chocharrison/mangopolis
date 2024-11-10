extends CharacterBody3D

##################################### constants
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const DISTANCE = 1.5
const VERTICAL_DISTANCE = 2
const DIG_DISTANCE = 1
const PET_DISTANCE = 0.5

##################################### node assignments
@onready var master: CharacterBody3D = get_parent().get_node("main_player")
@onready var anime: AnimationTree = get_node("AnimationTree")
@onready var Animated_sprite: AnimatedSprite3D = get_node("AnimatedSprite3D")


##################################### flags
@onready var is_petting = false
@onready var is_dig = false

##################################### variables
@onready var dig_position: Vector3 = Vector3(0,0,0)
@onready var bread_crumbs_index = 0
@onready var direction = Vector3(0,0,0)

##################################### States
enum STATE {IDLE, FOLLOW, PANIC, PETTED, DIG, DISABLED, ENABLED}
@onready var state = STATE.FOLLOW

##################################### state functions start
#Initializes the master player node and animation tree.
#Sets the initial speed to the default movement speed.
func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	handle_state_transitions()
	perform_state_actions(delta)
	move_and_slide()

func perform_state_actions(delta):
	match state:
		STATE.IDLE:
			state_idle()
		STATE.FOLLOW:
			state_follow(delta)
		STATE.PANIC:
			state_panic(delta)
		STATE.PETTED:
			state_petted()
		STATE.DIG:
			state_dig(delta)
			
func handle_state_transitions():
	
	if state == STATE.DISABLED or state == STATE.DIG or state == STATE.PANIC or state == STATE.IDLE:
		return
	
	if is_petting:
		state = STATE.PETTED
		return
	
	if Input.is_action_just_pressed("jump_2") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	
	state = STATE.FOLLOW

##################################### state functions
func state_idle():
	set_sprite_direction(master.position)
	anime.get("parameters/playback").travel("idle")
	

func state_follow(delta):
	var speed = max(SPEED,master.get_sprint())
	var bread_crumbs_array = master.get_bread_crumbs()
	
	var vertical_distance = position.y - master.position.y
	#print(velocity)
	if vertical_distance < VERTICAL_DISTANCE:
		if bread_crumbs_index < bread_crumbs_array.size():
			var target_position = bread_crumbs_array[bread_crumbs_index]
			var distance_to_target = Vector3(position.x,0,position.z).distance_to(Vector3(target_position.x,0,target_position.z))
		
			if distance_to_target > DISTANCE:
				var bread_direction = (Vector3(target_position.x,0,target_position.z) - Vector3(position.x,0,position.z)).normalized()
				velocity.x = bread_direction.x * speed
				velocity.z = bread_direction.z * speed

			else:
				bread_crumbs_index += 1
	
		else:
			bread_crumbs_index -= 1
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	else:
		position.x = master.position.x
		position.y = master.position.y+2
		position.z = master.position.z
	
	set_sprite_direction(master.position)
	if(velocity == Vector3(0,0,0)):
		anime.get("parameters/playback").travel("idle")
	else:
		anime.get("parameters/playback").travel("walk")
	
func state_panic(delta):
	anime.get("parameters/playback").travel("panic")
	velocity = Vector3(0,0,0)
	position = position
	
func state_petted():
	set_sprite_direction(master.position)
	direction = (Vector3(master.position.x,0,master.position.z) - Vector3(position.x,0,position.z)).normalized()
	var target = master.position - direction * PET_DISTANCE
	position = position.lerp(target, 0.1)
	if position.distance_to(dig_position) >= PET_DISTANCE:
		anime.get("parameters/playback").travel("pet")
	else:
		anime.get("parameters/playback").travel("walk")
	
func state_dig(delta):
	position = position.lerp(dig_position, 0.1)
	set_sprite_direction(dig_position)
	if position.distance_to(dig_position) <= DIG_DISTANCE:
		anime.get("parameters/playback").travel("dig")
		await Animated_sprite.animation_finished
		state = STATE.FOLLOW
	else:
		anime.get("parameters/playback").travel("walk")
	
##################################### custom functions
func set_sprite_direction(target_position: Vector3):
	direction = (Vector3(target_position.x,0,target_position.z) - Vector3(position.x,0,position.z)).normalized()
	anime.set("parameters/idle/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
	anime.set("parameters/panic/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
	anime.set("parameters/walk/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
	anime.set("parameters/dig/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
	anime.set("parameters/pet/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))


##################################### set functions
# Disable player controls and pause timers when needed.
func disable_controls():
	state = STATE.DISABLED

func enable_controls():
	state = STATE.ENABLED
	
func set_dig_position(val: Vector3):
	dig_position = val
	state = STATE.DIG

func set_pet(val:bool):
	is_petting = val

func trigger_panic():
	state = STATE.PANIC
	
func set_idle():
	state = STATE.IDLE

func set_follow():
	state = STATE.FOLLOW
