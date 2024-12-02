extends Node3D

@onready var toilets = $Node3D
@onready var array = [0,0,1,1,1,1,2,2]
@onready var pikmin = 0
@onready var already_found = false
@export var notebook_number = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if notebook_number in SaveStates.notebooks:
		already_found = true
	SignalManager.increase_pikmin_count.connect(_toilet)
	array.shuffle()
	var j = 0
	for i in toilets.get_children():
		print(i)
		i.set_toilet(array[j])
		j+=1

func _toilet():
	pikmin += 1
	if pikmin == 4 and !already_found:
		already_found = true
		SaveStates.get_notebook(notebook_number)
		SignalManager.collected_notebooks_signal.emit()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
