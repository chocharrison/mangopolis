extends Node3D

@onready var notebook_number = 9
@onready var collision_wall = $MeshInstance3D/side/CollisionShape3D
@onready var collision_wall2 = $MeshInstance3D2/side/CollisionShape3D
@onready var trigger = $Area3D

@onready var active = false
@onready var grunts = $enemies
@export var grunts_number = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if SaveStates.first_death:
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
	if active:
		grunts_number-=1
		if grunts_number <= 0:
			Engine.time_scale = 0.25
			await get_tree().create_timer(1).timeout
			Engine.time_scale = 1
			$Timer.start(2)



func _on_timer_timeout() -> void:
	if active:
		$Timer.stop()
		SignalManager.enemies_done.emit()
		queue_free()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "main_player":
		print("triggered")
		trigger.queue_free()
		active = true
		collision_wall.set_deferred("disabled",false)
		collision_wall2.set_deferred("disabled",false)
		for i in grunts.get_children():
			print("triggered")
			i.set_walk()
