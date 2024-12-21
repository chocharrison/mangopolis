extends ColorRect

@onready var text = $Label
@onready var is_found = $TextureRect
@export var note_number = 0

# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_text(val: String):
	text.set_text(val)

func found():
	is_found.set_texture(load("res://assets/ui/player_ui/sprites/notebook_check.png"))
	color = Color(Color.BLACK, 0.6)
