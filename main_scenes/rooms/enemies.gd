extends Node3D

@onready var notebook_number = 22
@onready var collision_wall = $wall3/side/CollisionShape3D
@onready var collision_wall2 = $wall4/side/CollisionShape3D

@onready var grunts = $enemies
@export var grunts_number = 4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if notebook_number in SaveStates.notebooks:
		queue_free()
	else:
		collision_wall.set_deferred("disabled",true)
		collision_wall2.set_deferred("disabled",true)
		SignalManager.grunt_dead.connect(check_done)
		for i in grunts.get_children():
			i.set_inactive()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func check_done():
	grunts_number-=1
	if grunts_number <= 0:
		Engine.time_scale = 0.25
		await get_tree().create_timer(1).timeout
		Engine.time_scale = 1
		$Timer.start(2)



func _on_timer_timeout() -> void:
	$Timer.stop()
	queue_free()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "main_player":
		$Area3D.queue_free()
		collision_wall.set_deferred("disabled",false)
		collision_wall2.set_deferred("disabled",false)		
		for i in grunts.get_children():
			i.set_walk()
