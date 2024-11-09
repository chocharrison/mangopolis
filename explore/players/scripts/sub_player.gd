extends CharacterBody3D

##################################### constants
const SPEED = 5.0
const SPRINT = 7.0
const JUMP_VELOCITY = 4.5
const DISTANCE = 1.5
const VERTICAL_DISTANCE = 2
const DIG_DISTANCE = 1

##################################### node assignments
var master: CharacterBody3D = null
var anime: AnimationTree = null

##################################### flags
var is_panic = false
var is_dig = false

##################################### variables
var speed = SPEED
var dig_position: Vector3 = Vector3(0,0,0)
var bread_crumbs_index = 0

##################################### default functions
#Initializes the master player node and animation tree.
#Sets the initial speed to the default movement speed.
func _ready() -> void:
	master = get_parent().get_node("main_player")
	anime = get_node("AnimationTree")
	
	speed = SPEED

#Main loop for handling sub-player movement based on current state (digging, panic, or normal following).
#Calls functions depending on the active state
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	if is_dig:
		dig_sub_player(delta)
	elif is_panic:
		panic_sub_player(delta)
	else:
		default_sub_player(delta)
		
	animation_sub_player()
	move_and_slide()
	

##################################### custom functions	
#Normal movement behavior: The sub-player follows the main player by moving toward breadcrumb positions.
#Adjusts the speed based on whether the master is sprinting.
#Handles jumping and calculates the distance to the next breadcrumb.
func default_sub_player(delta: float):
	speed = max(SPEED,master.get_sprint())
	if Input.is_action_just_pressed("jump_2") and is_on_floor():
		velocity.y = JUMP_VELOCITY

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
	#print(bread_crumbs_index)

#Stops all movement during panic mode.
func panic_sub_player(delta: float):
	velocity = Vector3(0,0,0)

#Moves the sub-player towards the dig_position until they reach it. Once there, it exits the digging state.
func dig_sub_player(delta: float):
	position = position.lerp(dig_position, SPEED * delta)
	if position.distance_to(dig_position) <= DIG_DISTANCE:
		is_dig = false
	
#Controls animations based on the sub-player's movement.
#Determines whether to play idle, walk, jump, or fall animations depending on the velocity.
#Updates blend space based on the direction relative to the master player.
func animation_sub_player():
	if(velocity == Vector3(0,0,0)):
		anime.get("parameters/playback").travel("idle")
	else:
		anime.get("parameters/playback").travel("walk")
	var direction = (Vector3(master.position.x,0,master.position.z) - Vector3(position.x,0,position.z)).normalized()
	anime.set("parameters/idle/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
	anime.set("parameters/jump/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
	anime.set("parameters/walk/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
	anime.set("parameters/fall/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
	
	var jump_norm = velocity.normalized()
	if(jump_norm.y > 0):
		anime.get("parameters/playback").travel("jump")
	if(jump_norm.y < 0):
		anime.get("parameters/playback").travel("fall")

##################################### set functions
#Sets the target dig position and enables the digging state.
func set_dig_position(val: Vector3):
	dig_position = val
	is_dig = true

#Toggles panic mode for the sub-player, stopping movement when activated.
func set_panic(val: bool):
	is_panic = val
