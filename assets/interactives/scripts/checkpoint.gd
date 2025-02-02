extends Node3D


@onready var is_interactive = false
@onready var is_near_coco = false
@onready var is_near_enemy = false

@onready var anime = $AnimatedSprite3D
@onready var player_pos = null
@onready var sub_player_pos = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.interracted.connect(_on_interact)
	if name == SaveStates.check_point_name():
		anime.play("lit")
	else:
		anime.play("unlit")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self.name != SaveStates.check_point_name():
		anime.play("unlit")


func _on_interact(panicked):
	if is_interactive and is_near_coco and !panicked and !is_near_enemy and self.name != SaveStates.check_point_name():
		print("checkpoint!")
		SignalManager.show_interact_button_signal.emit(false)
		anime.play("lit")
		SaveStates.set_checkpoint(self.name,player_pos.position,sub_player_pos.position)

func _on_clickable_body_entered(body: Node3D) -> void:
	if body.name == "main_player" and is_near_coco and !is_near_enemy and self.name != SaveStates.check_point_name():
		print("interact")
		SignalManager.show_interact_button_signal.emit(true)
		is_interactive = true
		player_pos = body

	


func _on_clickable_body_exited(body: Node3D) -> void:
	if body.name == "main_player":
		SignalManager.show_interact_button_signal.emit(false)
		is_interactive = false


func _on_enemy_aware_body_entered(body: Node3D) -> void:
	if body.name=="sub_player":
		is_near_coco = true
		sub_player_pos = body

	if body.name == "enemy":
		is_near_enemy = true
func _on_enemy_aware_body_exited(body: Node3D) -> void:
	if body.name=="sub_player":
		is_near_coco = false

	if body.name == "enemy":
		is_near_enemy = false
