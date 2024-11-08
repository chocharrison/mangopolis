extends Node3D

signal coco_in_range
signal found_dig
signal dig_notebook_or_health

@export var is_notebook: bool = false
@export var id_or_quantity: int = 1

@onready var is_interactive = false
@onready var is_near_coco = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and is_interactive and is_near_coco:
		print("digged")
		emit_signal("found_dig",false)
		emit_signal("coco_in_range",false)
		emit_signal("dig_notebook_or_health",is_notebook,id_or_quantity,position)
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_collect_body_entered(body: Node3D) -> void:
	if body.name == "main_player" and is_near_coco:
		print("interact")
		emit_signal("found_dig",true)
		is_interactive = true

func _on_collect_body_exited(body: Node3D) -> void:
	if body.name == "main_player":
		print("not interact")
		emit_signal("found_dig",false)
		is_interactive = false

func _on_detect_body_entered(body: Node3D) -> void:
	if(body.name=="sub_player"):
		print("coco is in")
		emit_signal("coco_in_range",true)
		is_near_coco = true

func _on_detect_body_exited(body: Node3D) -> void:
	if(body.name=="sub_player"):
		print("coco is out")
		emit_signal("coco_in_range",false)
		is_near_coco = false
