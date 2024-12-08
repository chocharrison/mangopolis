extends CharacterBody3D

##################################### constants
const SPEED = 15
const JUMP_VELOCITY = 4.5
const DISTANCE = 10
const VERTICAL_DISTANCE = 20
const DIG_DISTANCE = 4
const PET_DISTANCE = 1

##################################### node assignments
@onready var master: CharacterBody3D = get_parent().get_node("main_player")
@onready var anime: AnimationTree = get_node("AnimationTree")
@onready var navi: NavigationAgent3D = get_node("NavigationAgent3D")

##################################### flags
@onready var is_petting = false
@onready var found_digging = false

##################################### variables
@onready var dig_position: Vector3 = Vector3(0,0,0)
@onready var bread_crumbs_index = 0
@onready var direction = Vector3(0,0,0)

##################################### States
enum STATE {IDLE, FOLLOW, PANIC, PETTED, DIG, DISABLED, ENABLED}
@onready var state = STATE.FOLLOW
@onready var save_state = null

##################################### state functions start
#Initializes the master player node and animation tree.
#Sets the initial speed to the default movement speed.
func _ready() -> void:
	pass
	
func _physics_process(_delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += get_gravity().y * _delta

	handle_state_transitions()
	perform_state_actions(_delta)
	move_and_slide()

func perform_state_actions(_delta):
	match state:
		STATE.IDLE:
			state_idle()
		STATE.FOLLOW:
			state_follow(_delta)
		STATE.PANIC:
			state_panic(_delta)
		STATE.PETTED:
			state_petted()
		STATE.DIG:
			state_dig(_delta)
			
func handle_state_transitions():
	if state == STATE.DISABLED:
		return
	
	if is_petting:
		state = STATE.PETTED
		return
	
	if state == STATE.PANIC or state == STATE.IDLE or state == STATE.DIG:
		return
	
#	if Input.is_action_just_pressed("jump_2") and is_on_floor():
#		velocity.y = JUMP_VELOCITY
	
	
	state = STATE.FOLLOW

##################################### state functions
func state_idle():
	set_sprite_direction(master.global_position)
	anime.get("parameters/playback").travel("idle")
	

func state_follow(_delta):
	
#	follow_function_new()
	follow_function_old()
		
	set_sprite_direction(master.global_position)
	if(velocity == Vector3(0,0,0)):
		anime.get("parameters/playback").travel("idle")
	else:
		anime.get("parameters/playback").travel("walk")
	
func state_panic(_delta):
	anime.get("parameters/playback").travel("panic")
	velocity = Vector3(0,0,0)
	global_position = global_position
	
func state_petted():
	set_sprite_direction(master.global_position)
	direction = (Vector3(master.global_position.x,0,master.global_position.z) - Vector3(global_position.x,0,global_position.z)).normalized()
	var target = master.global_position - direction * PET_DISTANCE
	print( position.distance_to(target))
	var distance = abs(Vector3(target.x,0,target.z) - Vector3(global_position.x,0,global_position.z))
	if distance.x <= PET_DISTANCE and distance.z <= PET_DISTANCE:
		anime.get("parameters/playback").travel("pet")
	else:
		global_position = global_position.lerp(target, 0.1)
		anime.get("parameters/playback").travel("walk")
	SignalManager.digging_interrupt.emit()
	
func state_dig(delta):
	if !found_digging:
		print(dig_position)
		print(global_position)
		global_position = global_position.lerp(dig_position, 1 * delta)
		set_sprite_direction(dig_position)
		print(dig_position)
		if global_position.distance_to(dig_position) <= DIG_DISTANCE:
			anime.get("parameters/playback").travel("dig")
			found_digging = true
		else:
			anime.get("parameters/playback").travel("walk")
			print("despacito")
	
##################################### custom functions
func set_sprite_direction(target_position: Vector3):
	direction = (Vector3(target_position.x,0,target_position.z) - Vector3(global_position.x,0,global_position.z)).normalized()
	anime.set("parameters/idle/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
	anime.set("parameters/panic/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
	anime.set("parameters/walk/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
	anime.set("parameters/dig/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
	anime.set("parameters/pet/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))

func follow_function_old():
	var speed = max(SPEED,master.get_sprint())
	var bread_crumbs_array = master.get_bread_crumbs()
	
	var vertical_distance = global_position.y - master.global_position.y
	#print(velocity)
	if vertical_distance < VERTICAL_DISTANCE:
		if bread_crumbs_index < bread_crumbs_array.size():
			var target_position = bread_crumbs_array[bread_crumbs_index]
			var distance_to_target = Vector3(global_position.x,0,global_position.z).distance_to(Vector3(target_position.x,0,target_position.z))
		
			if distance_to_target > DISTANCE:
				var bread_direction = (Vector3(target_position.x,0,target_position.z) - Vector3(global_position.x,0,global_position.z)).normalized()
				velocity.x = bread_direction.x * speed
				velocity.z = bread_direction.z * speed

			else:
				bread_crumbs_index += 1
	
		else:
			bread_crumbs_index -= 1
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	else:
		global_position.x = master.global_position.x
		global_position.y = master.global_position.y+2
		global_position.z = master.global_position.z

func digging_done():
	SignalManager.after_dig.emit()


func follow_function_new():
	var speed = max(SPEED,master.get_sprint())
	var current_position = global_position
	navi.target_position = master.global_position
	var target_position = navi.get_next_path_position()
	var new_velocity = (target_position - current_position).normalized() * speed
	velocity = new_velocity
	print(new_velocity)
	print(target_position,current_position)
	
	
##################################### set functions
# Disable player controls and pause timers when needed.
func disable_controls():
	state = STATE.DISABLED
	velocity = Vector3(0,0,0)
	
func enable_controls():
	state = STATE.ENABLED

func pause_controls():
	save_state = state
	state = STATE.DISABLED
	velocity = Vector3(0,0,0)
	
func unpause_controls():
	if save_state == STATE.DISABLED:
		save_state = STATE.ENABLED
	state = save_state
	
func set_dig_position(val: Vector3):
	print(val)
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


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	print(anim_name)
	anim_name = anim_name.split("_")[0]
	match anim_name:
		"dig":
			found_digging = false
			state = STATE.FOLLOW
			


func _on_navigation_agent_3d_target_reached() -> void:
	print("despacito")
