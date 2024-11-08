extends CharacterBody3D


const SPEED = 5.0
const SPRINT = 7.0
const JUMP_VELOCITY = 4.5
const DISTANCE = 1.5
const VERTICAL_DISTANCE = 2
const DIG_DISTANCE = 1

var bread_crumbs_index = 0

var master: CharacterBody3D = null
var anime: AnimationTree = null

var is_panic = false
var is_dig = false
var speed = SPEED

var dig_position: Vector3 = Vector3(0,0,0)
func _ready() -> void:
	master = get_parent().get_node("main_player")
	anime = get_node("AnimationTree")
	speed = SPEED
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	if is_dig:
		position = position.lerp(dig_position, SPEED * delta)
		if position.distance_to(dig_position) <= DIG_DISTANCE:
			is_dig = false
	elif is_panic:
		velocity == Vector3(0,0,0)
	else:
		move_sub_player()
		
	animation_sub_player()
	move_and_slide()
	
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
	
func move_sub_player():
	speed = max(SPEED,master.get_sprint())
	if Input.is_action_just_pressed("jump_2") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var bread_crumbs_array = master.get_bread_crumbs()
	#print("sub "+str(bread_crumbs_array.size()))
	
	
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

func set_dig_position(val: Vector3):
	dig_position = val
	is_dig = true

func set_panic(val: bool):
	is_panic = val
