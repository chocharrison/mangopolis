extends CharacterBody3D


const SPEED = 5.0
const SPRINT = 7.0
const JUMP_VELOCITY = 4.5

const BREAD_CRUMB_INTERVAL = 0.05
const ARRAY_SIZE = 2

const DISTANCE = 2

const VERTICAL_DISTANCE = 2

const PETTING_DISTANCE = 1
const PANIC_DISTANCE = 6
const FAR_TIME = 5
const PANIC_TIME = 20

var sprint_meter = 100
const MAX_SPRINT = 100

var bread_crumbs_array = []
#var bread_crumbs_timer = 0.0

var sub: CharacterBody3D = null
var anime: AnimationTree = null
var UI: Control = null
var Sprint_timer: Timer = null

var panic_timer: Timer = null
var far_timer: Timer = null

@onready var is_ded = false
@onready var is_disable = false
@onready var is_cooldown = false
@onready var is_sprint_timer_active = false

@onready var is_tired = false
@onready var is_sprinted = false

@onready var is_petting = false
@onready var is_far_timer = false
@onready var is_panic = false

@onready var speed = SPEED

@onready var coco_ui = ["default","happy","scared","glad"]
@onready var coco_set = 0

func _ready() -> void:
	sprint_meter = MAX_SPRINT
	sub = get_parent().get_node("sub_player")
	anime = get_node("AnimationTree")
	UI = get_parent().get_node("ExploreUi")
	bread_crumbs_array.append(position)
	Sprint_timer = get_node("sprint_cooldown")
	far_timer = get_node("far_timer")
	panic_timer = get_node("panic_timer")
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	if is_ded:
		anime.get("parameters/playback").travel("idle")
		print("dead")
	elif is_disable:
		anime.get("parameters/playback").travel("idle")
	else:
		player_move(delta)


func player_move(delta: float) -> void:
	var distance_to_sub = Vector3(position.x, 0, position.z).distance_to(Vector3(sub.position.x, 0, sub.position.z))
	if !is_panic:
		if(distance_to_sub > PANIC_DISTANCE):
			if !is_far_timer:
				far_timer.wait_time = FAR_TIME
				far_timer.start()
				is_far_timer = true
				print("timer start")
		else:
			far_timer.stop()
			is_far_timer = false
	
	if Input.is_action_just_pressed("jump_1") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		set_pet(false)
	
	if Input.is_action_just_pressed("pet") and is_on_floor() and position.distance_to(sub.position) <= PETTING_DISTANCE:
		var facing_pet = (Vector3(sub.position.x,0,sub.position.z)-Vector3(position.x,0,position.z)).normalized()
		anime.set("parameters/walk/BlendSpace2D/blend_position",Vector2(facing_pet.x,-facing_pet.z))
		set_pet(true)
		sub.set_panic(false)
		panic_timer.stop()
		is_panic = false
		coco_set = 0
		
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	
	if sprint_meter == 0:
		speed = 0
		is_tired = true
	elif !is_tired:
		speed = SPEED
	
	if Input.is_action_pressed("sprint") and is_on_floor() and !is_tired and !is_sprinted and direction != Vector3.ZERO:
	# Sprinting: reduce the sprint meter, set sprint speed, stop cooldown timer
		set_pet(false)
		sprint_meter -= 1
		sprint_meter = max(sprint_meter, 0)
		speed = SPRINT
		Sprint_timer.stop()
		is_sprint_timer_active = false
	else:
	# Not sprinting: handle sprint meter recharge and cooldown
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
	
	
	
	if(direction == Vector3.ZERO):
		if is_petting:
			anime.get("parameters/playback").travel("walk")
		else:
			anime.get("parameters/playback").travel("idle")
	else:
		set_pet(false)
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
	
	
	
	var vertical_distance = position.y - sub.position.y
	#print(velocity)
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
	
	
func bread_crumbing():

	var temp = bread_crumbs_array.back()
	var distance_moved = position.distance_to(Vector3(temp.x,0,temp.z))
	if distance_moved - BREAD_CRUMB_INTERVAL:
		if bread_crumbs_array.size() == 0 or bread_crumbs_array.back() != position:
			bread_crumbs_array.append(position)
			if bread_crumbs_array.size() > ARRAY_SIZE:
				bread_crumbs_array.pop_front()

func disable_control(val: bool):
	is_disable = val
	panic_timer.set_paused(val)
	far_timer.set_paused(val)
		
func set_ded():
	is_ded = true
	far_timer.stop()
	panic_timer.stop()

func set_pet(val: bool):
	is_petting = val
	if !is_petting:
		UI.set_coco(coco_ui[coco_set])
	else:
		UI.set_coco(coco_ui[3])

func set_coco_dig(val: int):
	coco_set = val
		
func set_panic():
	far_timer.stop()
	panic_timer.wait_time = PANIC_TIME
	panic_timer.start()
	print("panic!!!!")
	sub.set_panic(true)
	is_far_timer = false
	is_panic = true
	coco_set = 2

func get_bread_crumbs() -> Array:
	return bread_crumbs_array

func get_sprint() -> float:
	return speed
	
func get_panic_status() -> bool:
	return is_panic

func _on_sprint_cooldown_timeout() -> void:
	is_cooldown = false


func _on_panic_timer_timeout() -> void:
	print("TOO LATE")
	set_ded()


func _on_far_timer_timeout() -> void:
	set_panic()
