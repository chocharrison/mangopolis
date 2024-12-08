extends Node3D

@export var is_notebook: bool = false
@export var id_or_quantity: int = 1

@onready var is_interactive = false
@onready var is_near_coco = false
@onready var is_digging = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_notebook and SaveStates.notebooks.has(id_or_quantity):
		queue_free()
	SignalManager.interracted.connect(_on_interact)
	SignalManager.after_dig.connect(_after_dig)
	SignalManager.digging_interrupt.connect(_digging_interupt)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_interact(panicked):
	if is_interactive and is_near_coco and !panicked:
		is_digging = true
		SignalManager.dig_result_signal.emit(global_position)
		SignalManager.show_interact_button_signal.emit(false)

func _digging_interupt():
	is_digging = false
	
func _after_dig():
		print("digged")
		if is_notebook:
			SaveStates.get_notebook(id_or_quantity)
			SignalManager.collected_notebooks_signal.emit()
		else:
			SignalManager.collected_healthpotions_signal.emit(id_or_quantity)
		SignalManager.coco_in_dig_range_signal.emit(false)
		queue_free()

# Detects when the main player enters the collection zone
func _on_collect_body_entered(body: Node3D) -> void:
	if body.name == "main_player" and is_near_coco and !is_digging:
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
