extends CharacterBody3D

##################################### constants
const SPEED = 5.0
const SPRINT = 7.0
const JUMP_VELOCITY = 4.5

const BREAD_CRUMB_INTERVAL = 0.05
const ARRAY_SIZE = 2

const DISTANCE = 2

const VERTICAL_DISTANCE = 2

const PETTING_DISTANCE = 1

const MAX_SPRINT = 100


##################################### node assignments
var sub: CharacterBody3D = null
var anime: AnimationTree = null
var UI: Control = null
var Sprint_timer: Timer = null



##################################### flags
@onready var is_ded = false
@onready var is_disable = false
@onready var is_cooldown = false
@onready var is_sprint_timer_active = false

@onready var is_tired = false
@onready var is_sprinted = false
@onready var is_sprinting = false

@onready var is_petting = false

##################################### variables
@onready var speed = SPEED

@onready var sprint_meter = MAX_SPRINT
@onready var bread_crumbs_array = []

##################################### default functions
func _input(event):
	pass

func _ready() -> void:
	sprint_meter = MAX_SPRINT
	sub = get_parent().get_node("sub_player")
	anime = get_node("AnimationTree")
	UI = get_parent().get_node("ExploreUi")
	bread_crumbs_array.append(position)
	Sprint_timer = get_node("sprint_cooldown")
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	if is_ded:
		dead_player(delta)
	elif is_disable:
		disabled_player(delta)
	else:
		default_player(delta)

##################################### custom functions


# Measure distance to the sub player and start/stop far timer based on distance.
# Handle jumping action if on the ground.
# Handle petting interaction if within petting distance of the sub player.
# Manage sprinting, including sprint meter depletion and recharge, setting sprint speed, and cooldown timer management.
# Update stamina UI and handle player movement, adjusting position and velocity.
# Call function to manage breadcrumbs for movement tracking.
func default_player(delta: float) -> void:
	
	if Input.is_action_just_pressed("jump_1") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		set_pet(false)
	
	if Input.is_action_just_pressed("pet") and is_on_floor() and position.distance_to(sub.position) <= PETTING_DISTANCE:
		SignalManager.petting_signal.emit()
		var facing_pet = (Vector3(sub.position.x,0,sub.position.z)-Vector3(position.x,0,position.z)).normalized()
		anime.set("parameters/walk/BlendSpace2D/blend_position",Vector2(facing_pet.x,-facing_pet.z))
		set_pet(true)
		
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Sprinting: if tired, set speed to zero and be tired
	if sprint_meter == 0:
		speed = 0
		is_tired = true
	elif !is_tired:
		speed = SPEED
	
	# Sprinting: reduce the sprint meter, set sprint speed, stop cooldown timer
	if Input.is_action_pressed("sprint") and is_on_floor() and !is_tired and !is_sprinted and direction != Vector3.ZERO:
		set_pet(false)
		sprint_meter -= 1
		sprint_meter = max(sprint_meter, 0)
		speed = SPRINT
		Sprint_timer.stop()
		is_sprint_timer_active = false
		is_sprinting = true
		
	# Not sprinting: handle sprint meter recharge and cooldown
	else:
		is_sprinting = false
		if sprint_meter < MAX_SPRINT:
			if !is_sprint_timer_active:
				Sprint_timer.start(1)  # Start cooldown timer if not active
				is_sprint_timer_active = true
				is_cooldown = true
			if !is_cooldown:
				sprint_meter += 1
		else:
			is_tired = false
			is_sprinted = false
	
	if Input.is_action_just_released("sprint"):
		is_sprinted = true
			
	UI.set_stamina(sprint_meter)
	
	
	animated_player(direction)
	
	
	var vertical_distance = position.y - sub.position.y
	if vertical_distance >= VERTICAL_DISTANCE:
		position.x = sub.position.x
		position.y = sub.position.y + 2
		position.z = sub.position.z
	elif direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	
	bread_crumbing()
	move_and_slide()


# Set animation to idle when the player is dead.
func dead_player(delta):
	anime.get("parameters/playback").travel("idle")
	print("dead")

# Set animation to idle when the player is disabled.
func disabled_player(delta):
	anime.get("parameters/playback").travel("idle")

# Set animations based on movement, sprinting, and interaction flags.
# Handle idle, walking, sprinting, and jumping/falling animations based on player direction and velocity.
func animated_player(direction: Vector3):
	if(direction == Vector3.ZERO):
		if is_petting:
			anime.get("parameters/playback").travel("walk")
		elif is_tired:
			anime.get("parameters/playback").travel("jump")
		else:
			anime.get("parameters/playback").travel("idle")
	else:
		set_pet(false)
		if is_sprinting:
			anime.get("parameters/playback").travel("fall")
		else:
			anime.get("parameters/playback").travel("walk")
		anime.set("parameters/idle/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
		anime.set("parameters/jump/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
		anime.set("parameters/walk/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
		anime.set("parameters/fall/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
	
	var jump_norm = velocity.normalized()
	if(jump_norm.y > 0):
		anime.get("parameters/playback").travel("jump")
	if(jump_norm.y < 0):
		anime.get("parameters/playback").travel("fall")
	
# Track the player's position, create breadcrumbs at regular intervals, and limit the size of the breadcrumb array.
func bread_crumbing():
	var temp = bread_crumbs_array.back()
	var distance_moved = position.distance_to(Vector3(temp.x,0,temp.z))
	if distance_moved - BREAD_CRUMB_INTERVAL:
		if bread_crumbs_array.size() == 0 or bread_crumbs_array.back() != position:
			bread_crumbs_array.append(position)
			if bread_crumbs_array.size() > ARRAY_SIZE:
				bread_crumbs_array.pop_front()


##################################### set functions
# Disable player controls and pause timers when needed.
func disable_control(val: bool):
	is_disable = val


# Set the player to dead and stop all timers.
func set_ded():
	is_ded = true

# Set the player petting.
func set_pet(val: bool):
	is_petting = val
##################################### get functions
# Return the array of breadcrumbs.
func get_bread_crumbs() -> Array:
	return bread_crumbs_array

# Return the current sprint speed.
func get_sprint() -> float:
	return speed

##################################### signal triggered functions
# Reset the cooldown flag when the sprint cooldown timer expires.
func _on_sprint_cooldown_timeout() -> void:
	is_cooldown = false
	Sprint_timer.stop()
