extends Node3D

var camera_controller: Node3D
var main_player: CharacterBody3D
var sub_player: CharacterBody3D
# Called when the node enters the scene tree for the first time.
@onready var is_cutscene = false

var angle = 0
var i = 0
signal set_cutscene_signal(scene: bool)
func _ready() -> void:
	camera_controller = get_node("camera_controller")
	main_player = get_node("main_player")
	sub_player = get_node("sub_player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#print(main_player.position.distance_to(sub_player.position))
	var camera_position = camera_controller.position
	camera_position.x = lerp(camera_position.x, main_player.position.x, 0.1)
	camera_position.y = lerp(camera_position.y, main_player.position.y, 0.1)
	camera_position.z = lerp(camera_position.z, main_player.position.z, 0.1)
	camera_controller.position = camera_position
	if !is_cutscene:	
		if Input.is_action_just_pressed("turn_left"):
			angle+=90
			i+=1
			if(i>3):
				i = 0
			main_player.set_disorientation(i)
		elif Input.is_action_just_pressed("turn_right"):
			angle-=90
			i-=1
			if(i<0):
				i = 3
			main_player.set_disorientation(i)
		camera_controller.rotation.y = lerp_angle(camera_controller.rotation.y,deg_to_rad(angle),0.1)
		
		#print(camera_controller.rotation.y)
	
func set_cutscene(scene: bool):
	is_cutscene = scene
	
