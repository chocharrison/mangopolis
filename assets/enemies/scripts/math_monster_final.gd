extends Node3D

@export var math_level = 1

@onready var anim = $AnimationPlayer
@onready var sprite = $AnimatedSprite3D
@onready var music = $AudioStreamPlayer3D

@onready var detect = $detect/CollisionShape3D
@onready var wall = $StaticBody3D/CollisionShape3D
@onready var math = $math/CollisionShape3D

@onready var smoke = $smoke

@onready var player_contact = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.visible = false
	smoke.visible = false
	detect.set_deferred("disabled",true)
	wall.set_deferred("disabled",true)
	math.set_deferred("disabled",true)
	SignalManager.math_success.connect(_on_result)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_active():
	detect.set_deferred("disabled",false)
	wall.set_deferred("disabled",false)
	math.set_deferred("disabled",false)

func set_math():
	SignalManager.signal_math.emit(math_level, 20,0)


func _on_result(val: bool):
	if player_contact:
		if val:
			anim.play("dead")
			music.stream = load("res://assets/enemies/sound/death_math.mp3")
			music.play()
			$math.queue_free()
			$StaticBody3D.queue_free()
		else:
			anim.play("push")
			player_contact = false


func _on_detect_body_entered(body: Node3D) -> void:
	if body.name == "main_player":
		anim.play("appear")
		music.stream = load("res://assets/interactives/sound effects/monster_enter.mp3")
		music.play()
		$detect.queue_free()


func _on_math_body_entered(body: Node3D) -> void:
	if body.name == "main_player" and !player_contact:
		player_contact = true
		set_math()
