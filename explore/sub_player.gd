extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const DISTANCE = 1.5

var master: CharacterBody3D = null
var bread_crumbs_index = 0

func _ready() -> void:
	master = get_parent().get_node("main_player")
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump_2") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var bread_crumbs_array = master.get_bread_crumbs()
	#print("sub "+str(bread_crumbs_array.size()))
	
	if bread_crumbs_index < bread_crumbs_array.size():
		var target_position = bread_crumbs_array[bread_crumbs_index]
		var distance_to_target = position.distance_to(Vector3(target_position.x,0,target_position.z))
		
		if distance_to_target > DISTANCE:
			var direction = (target_position - position).normalized()
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			bread_crumbs_index += 1
	
	else:
		bread_crumbs_index -= 1
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
