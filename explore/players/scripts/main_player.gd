extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const BREAD_CRUMB_INTERVAL = 0.05
const ARRAY_SIZE = 2
const DISTANCE = 2
const VERTICAL_DISTANCE = 2

var bread_crumbs_array = []
#var bread_crumbs_timer = 0.0

var input_mappings = [
	["ui_left", "ui_right", "ui_up", "ui_down"],  # Default
	["ui_up", "ui_down", "ui_right", "ui_left"],  # Inverted Y-axis
	["ui_right", "ui_left", "ui_down", "ui_up"],  # Rotated 90 degrees clockwise
	["ui_down", "ui_up", "ui_left", "ui_right"]   # Inverted X-axis
]
var input_index = 0

var sub: CharacterBody3D = null
var anime: AnimationTree = null

func _ready() -> void:
	sub = get_parent().get_node("sub_player")
	anime = get_node("AnimationTree")
	bread_crumbs_array.append(position)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump_1") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var current_mapping = input_mappings[input_index]
	var input_dir := Input.get_vector(current_mapping[0], current_mapping[1], current_mapping[2], current_mapping[3])
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if(direction == Vector3.ZERO):
		anime.get("parameters/playback").travel("idle")
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
	
	var distance_to_sub = Vector3(position.x, 0, position.z).distance_to(Vector3(sub.position.x, 0, sub.position.z))
	var vertical_distance = position.y - sub.position.y
	#print(velocity)
	if vertical_distance >= VERTICAL_DISTANCE:
		position.x = sub.position.x
		position.y = sub.position.y + 2
		position.z = sub.position.z
	elif direction and distance_to_sub < DISTANCE:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	var temp = bread_crumbs_array.back()
	var distance_moved = position.distance_to(Vector3(temp.x,0,temp.z))
	if distance_moved - BREAD_CRUMB_INTERVAL:
		if bread_crumbs_array.size() == 0 or bread_crumbs_array.back() != position:
			bread_crumbs_array.append(position)
			if bread_crumbs_array.size() > ARRAY_SIZE:
				bread_crumbs_array.pop_front()

	#print(bread_crumbs_array.size())
func get_bread_crumbs() -> Array:
	return bread_crumbs_array
func set_disorientation(i: int):
	input_index = i
