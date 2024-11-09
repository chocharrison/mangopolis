extends Node3D

@export var is_notebook: bool = false
@export var id_or_quantity: int = 1

@onready var is_interactive = false
@onready var is_near_coco = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and is_interactive and is_near_coco:
		print("digged")
		SignalManager.show_interact_button_signal.emit(false)
		SignalManager.coco_in_dig_range_signal.emit(false)
		SignalManager.dig_result_signal.emit(is_notebook,id_or_quantity,position)
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Detects when the main player enters the collection zone
func _on_collect_body_entered(body: Node3D) -> void:
	if body.name == "main_player" and is_near_coco:
		print("interact")
		SignalManager.show_interact_button_signal.emit(true)
		is_interactive = true

# Detects when the main player exits the collection zone
func _on_collect_body_exited(body: Node3D) -> void:
	if body.name == "main_player":
		print("not interact")
		SignalManager.show_interact_button_signal.emit(false)
		is_interactive = false

# Detects when the sub-player (Coco) enters the detection zone
func _on_detect_body_entered(body: Node3D) -> void:
	if body.name=="sub_player":
		print("coco is in")
		SignalManager.coco_in_dig_range_signal.emit(true)
		is_near_coco = true

# Detects when the sub-player (Coco) exits the detection zone
func _on_detect_body_exited(body: Node3D) -> void:
	if(body.name=="sub_player"):
		print("coco is out")
		SignalManager.coco_in_dig_range_signal.emit(false)
		is_near_coco = false
