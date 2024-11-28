extends Node2D

@onready var texture = $Node2D/TextureRect
@onready var anim = $AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture.visible = false
	SignalManager.do_lobster.connect(_on_lobster)

func _on_lobster():
	var ran = randi_range(1,4)
	anim.play("lobster_"+str(ran))
