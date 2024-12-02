extends Node3D

@export var scene: String

@onready var is_interactive = false
@onready var is_near_enemy = false

@onready var anime = $AnimationPlayer
@onready var player_pos = null
@onready var sub_player_pos = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.interracted.connect(_on_interact)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_interact(panicked):
	if is_interactive and !is_near_enemy:
		print("door")
		anime.play("door")
		SaveStates.set_checkpoint(self.name,player_pos.position,sub_player_pos.position)
		SignalManager.show_interact_button_signal.emit(false)
		
func _on_clickable_body_entered(body: Node3D) -> void:
	if body.name == "main_player":
		print("interact")
		SignalManager.show_interact_button_signal.emit(true)
		is_interactive = true
		player_pos = body


func _on_clickable_body_exited(body: Node3D) -> void:
	if body.name == "main_player":
		SignalManager.show_interact_button_signal.emit(false)
		is_interactive = false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"door":
			get_tree().change_scene_to_file(scene)
