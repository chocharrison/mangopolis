extends CharacterBody3D

##################################### constants
const SPEED = 15
const SPRINT = 30
const JUMP_VELOCITY = 4.5

const BREAD_CRUMB_INTERVAL = 0.05
const ARRAY_SIZE = 2

const DISTANCE = 2

const VERTICAL_DISTANCE = 2

const PET_DISTANCE = 5

const MAX_SPRINT = 100


##################################### node assignments
@onready var sub: CharacterBody3D = get_parent().get_node_or_null("sub_player")
@onready var anime: AnimationTree = get_node_or_null("AnimationTree")
@onready var UI: Control = get_parent().get_node_or_null("Ui")
@onready var Sprint_timer: Timer = get_node("sprint_cooldown")
@onready var collision = get_node("CollisionShape3D")

##################################### flags
@onready var is_cooldown = false
@onready var is_sprint_timer_active = false

@onready var is_sprinted = false

@onready var is_petting = false

@onready var is_interacting = false

##################################### variables

@onready var sprint_meter = MAX_SPRINT
@onready var bread_crumbs_array = [global_position]
@onready var direction = Vector3(0,0,0)
@onready var speed = SPEED
@onready var save_state = null

##################################### States
enum STATE {IDLE,JUMP,WALK,SPRINT,TIRED, PET, DISABLED, ENABLED, DED}
@onready var state = STATE.IDLE

##################################### state functions start
func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:

	handle_state_transitions(delta)
	perform_state_actions(delta)
	move_and_slide()

func perform_state_actions(_delta):
	match state:
		STATE.DISABLED:
			anime.get("parameters/playback").travel("idle")
		STATE.TIRED:
			state_tired()
		STATE.PET:
			state_pet()
		STATE.IDLE:
			state_idle()
		STATE.WALK:
			state_walk()
		STATE.SPRINT:
			state_sprint()
		STATE.JUMP:
			state_jump()
		
	if state != STATE.SPRINT:
		if sprint_meter < MAX_SPRINT:
			if !is_sprint_timer_active:
				Sprint_timer.start(1)  # Start cooldown timer if not active
				is_sprint_timer_active = true
				is_cooldown = true
			elif !is_cooldown:
				UI.set_stamina(sprint_meter)
				sprint_meter += 1
				Sprint_timer.stop()
		else:
			is_sprinted = false
			is_sprint_timer_active = false
	
	if state != STATE.PET:
		is_petting = false
		sub.set_pet(false)
		SignalManager.petting_signal.emit(false)
		


func handle_state_transitions(delta):
	if state == STATE.DISABLED or state == STATE.DED:
		return
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	
	bread_crumbing()
	if state == STATE.TIRED or state == STATE.JUMP:
		return
	
#	if Input.is_action_just_pressed("jump_1") and is_on_floor():
#		print("here")
#		velocity.y = JUMP_VELOCITY
#		state = STATE.JUMP
#		return
	
	if !is_interacting and Input.is_action_just_pressed("interact") and is_on_floor() and check_sub_distance():
		var facing_pet = (Vector3(sub.global_position.x,0,sub.global_position.z)-Vector3(global_position.x,0,global_position.z)).normalized()
		anime.set("parameters/pet/BlendSpace2D/blend_position",Vector2(facing_pet.x,-facing_pet.z))
		state = STATE.PET
		is_petting = true
		return
		

	if direction != Vector3.ZERO:
		if Input.is_action_pressed("sprint") and is_on_floor() and !is_sprinted and sprint_meter > 0:
			set_sprite_direction()
			state = STATE.SPRINT
			return
		else:
			set_sprite_direction()
			state = STATE.WALK
			return
	else:
		if !is_petting:
			state = STATE.IDLE

	if Input.is_action_just_released("sprint"):
		is_sprinted = true
	
##################################### state functions
func state_idle():
	anime.get("parameters/playback").travel("idle")
	velocity.x = move_toward(velocity.x, 0, SPEED)
	velocity.z = move_toward(velocity.z, 0, SPEED)

func state_pet():
	anime.get("parameters/playback").travel("pet")
	sub.set_pet(true)
	SignalManager.petting_signal.emit(true)

func state_tired():
	anime.get("parameters/playback").travel("tired")
	velocity.x = move_toward(velocity.x, 0, SPEED)
	velocity.z = move_toward(velocity.z, 0, SPEED)
	if(sprint_meter == MAX_SPRINT):
		state = STATE.IDLE

func state_jump():
	var jump_norm = velocity.normalized()
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	if(jump_norm.y > 0):
		anime.get("parameters/playback").travel("jump")
	elif(jump_norm.y < 0):
		anime.get("parameters/playback").travel("fall")
	else:
		state = STATE.IDLE

func state_walk():
	speed = SPEED
	anime.get("parameters/playback").travel("walk")
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED

func state_sprint():
	speed = SPRINT
	anime.get("parameters/playback").travel("sprint")
	velocity.x = direction.x * SPRINT
	velocity.z = direction.z * SPRINT
	
	sprint_meter -= 1
	sprint_meter = max(sprint_meter, 0)
	UI.set_stamina(sprint_meter)
	
	if sprint_meter == 0:
		state = STATE.TIRED


##################################### support functions

func set_sprite_direction():
		anime.set("parameters/idle/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
		anime.set("parameters/jump/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
		anime.set("parameters/walk/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
		anime.set("parameters/fall/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
		anime.set("parameters/sprint/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
		anime.set("parameters/tired/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))


func check_sub_distance() -> bool:
	var dis = abs(Vector3(global_position.x,0,global_position.z) - Vector3(sub.global_position.x,0,sub.global_position.z))
	if sub and dis.x <= PET_DISTANCE and dis.z <= PET_DISTANCE:
		return true
	return false

func bread_crumbing():
	var temp = bread_crumbs_array.back()
	var distance_moved = global_position.distance_to(Vector3(temp.x,0,temp.z))
	if distance_moved - BREAD_CRUMB_INTERVAL:
		if bread_crumbs_array.size() == 0 or bread_crumbs_array.back() != global_position:
			bread_crumbs_array.append(global_position)
			if bread_crumbs_array.size() > ARRAY_SIZE:
				bread_crumbs_array.pop_front()
				
##################################### set functions
# Disable player controls and pause timers when needed.
func disable_controls():
	state = STATE.DISABLED
	collision.set_deferred("disabled",true)
	velocity = Vector3(0,0,0)
	
func enable_controls():
	collision.set_deferred("disabled",false)
	state = STATE.ENABLED
	
	
func pause_controls():
	if save_state != STATE.DISABLED:
		save_state = state
	state = STATE.DISABLED
	velocity = Vector3(0,0,0)
	
func unpause_controls():
	if save_state == STATE.DISABLED:
		save_state = STATE.ENABLED
	state = save_state
	print(state)
# Set the player to dead and stop all timers.
func kill_player():
	state = STATE.DED
	collision.set_deferred("disabled",true)
	anime.get("parameters/playback").travel("ded")

# Set the player petting.
func set_pet(val: bool):
	is_petting = val
	
func set_interact(val: bool):
	is_interacting = val
##################################### get functions
# Return the array of breadcrumbs.
func get_bread_crumbs() -> Array:
	return bread_crumbs_array

# Return the current sprint speed.
func get_sprint() -> float:
	return speed

func _on_sprint_cooldown_timeout() -> void:
	is_cooldown = false
	Sprint_timer.stop()
