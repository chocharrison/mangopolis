extends Panel


@onready var health_potion = get_node("TextureRect/Label")
@onready var health_animation = get_node("health_potion_animation")
@onready var audio = $AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func health_set(val: int):
	health_potion.text = str(val)
	if val == 0:
		health_animation.play("health_exhaust")

func health_picked(val: int):
	health_potion.text = str(val)
	health_animation.play("health_picked")
	audio.stream = load("res://assets/ui/player_ui/sounds/increase.mp3")
	audio.play()

# Update the health potion text and play the animation for exhausting health.
func health_exhaust(val: int):
	health_potion.text = str(val)
	health_animation.play("health_exhaust")

# Update the health potion text and play the animation for using health.
func health_used(val: int):
	health_potion.text = str(val)
	health_animation.play("health_used")
	audio.stream = load("res://assets/ui/player_ui/sounds/drain.mp3")
	audio.play()
