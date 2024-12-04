extends Node3D

@export var soda: PackedScene

@onready var timer = $Timer
@onready var anim = $AnimationPlayer
@onready var audio = $AudioStreamPlayer3D

@onready var is_interactive = false
@onready var cooldown = false
@onready var drink_number = 0

@onready var rng = RandomNumberGenerator.new()
@onready var my_array = [0,1,2,3]
@onready var majima_array = [false,true]
@onready var weights = PackedFloat32Array([0.25, 0.5, 0.5, 0.25])
@onready var majima_weights = PackedFloat32Array([0.75, 0.25])
@onready var notebook_found = false

@export var notebook_number = 18

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.interracted.connect(_on_interact)
	if notebook_number in SaveStates.notebooks:
		notebook_found = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_interact(panicked):
	if is_interactive and !cooldown and !panicked:
		cooldown = true
		timer.wait_time = 1
		timer.start()
		dispense()
		drink_number+=1
		if !notebook_found and drink_number > 10:
			notebook_found = true
			SaveStates.get_notebook(notebook_number)
			SignalManager.collected_notebooks_signal.emit()

func dispense():
	anim.play("dispense")

func drink():
	var setup_soda = soda.instantiate()
	add_child(setup_soda)
	var i = my_array[rng.rand_weighted(weights)]
	var is_majima = majima_array[rng.rand_weighted(majima_weights)]
	setup_soda.setup(i,is_majima)
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "main_player":
		SignalManager.show_interact_button_signal.emit(true)
		is_interactive = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "main_player":
		SignalManager.show_interact_button_signal.emit(false)
		is_interactive = false


func _on_timer_timeout() -> void:
	cooldown = false
	timer.stop()
