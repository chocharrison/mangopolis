extends CanvasLayer

signal health_change

var coco : Player
var mango : Player
var mango_health : Label
var coco_health : Label

var current_health_mango = 0
var max_health_mango = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	coco = get_node("coco")
	mango = get_node("mango")
	coco_ui = get_node("ui/coco")
	mango_ui = get_node("ui/mango")
	
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
