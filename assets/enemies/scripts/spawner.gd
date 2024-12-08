extends Node3D

@export var unknown: PackedScene

@onready var timer = $Timer
@onready var end_point = $end_point
@export var is_spawnable = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_enemy():
	var y_pos = randi_range(0,end_point.position.y)
	var x_pos = randi_range(0,end_point.position.x)
