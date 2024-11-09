extends Node3D

# Called when the node enters the scene tree for the first time.
@export var quantity = 1

var health: AnimatedSprite3D

func _ready() -> void:
	health = get_node("collect/health")
	if(quantity == 2):
		var health2 = health.duplicate()
		health.position = Vector3(health.position.x + 0.07,health.position.y,health.position.z)
		health2.position = Vector3(health.position.x - 0.07,health.position.y,health.position.z)
		health.get_parent().add_child(health2)

	if(quantity == 3):
		var health2 = health.duplicate()
		var health3 = health.duplicate()
		health2.position = Vector3(health.position.x + 0.1,health.position.y,health.position.z)
		health3.position = Vector3(health.position.x - 0.1,health.position.y,health.position.z)
		health.get_parent().add_child(health2)
		health.get_parent().add_child(health3)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_collect_body_entered(body: Node) -> void:
	if(body.name=="main_player"):
		SignalManager.collected_healthpotions_signal.emit(quantity)
		queue_free()
