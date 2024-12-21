extends Control

@onready var content = $Control/ScrollContainer/VBoxContainer
@export var hint: PackedScene
@onready var bday_cards
@onready var hints = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.hint_update.connect(hint_update)
	set_mouse_filter(MouseFilter.MOUSE_FILTER_IGNORE)
	bday_cards = load_json()
	set_hints()
	get_solved()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func appear():
	set_mouse_filter(MouseFilter.MOUSE_FILTER_STOP)
	$AnimationPlayer.play("appear")

func disappear():
	set_mouse_filter(MouseFilter.MOUSE_FILTER_IGNORE)
	$AnimationPlayer.play("disappear")
	
func _on_back_pressed() -> void:
	disappear()

func load_json() -> Dictionary:
	var json_file = FileAccess.open("res://notebooks/_messages.json",FileAccess.READ)
	var content = JSON.parse_string(json_file.get_as_text())
	return content

func set_hints():
	var i = 0
	while i < SaveStates.total_notebooks:
		var setup_hint = hint.instantiate()
		content.add_child(setup_hint)
		if(bday_cards[str(i+1)].has("hint")):
			setup_hint.set_text(bday_cards[str(i+1)]["hint"])
		else:
			setup_hint.set_text("despacito")
		hints.append(setup_hint)
		i+=1
	content.move_child($Control/ScrollContainer/VBoxContainer/Control, i)

func get_solved():
	for i in range(1,SaveStates.notebooks.size()):
		hint_update(SaveStates.notebooks[i])

func hint_update(val: int):
	hints[val-1].found()
