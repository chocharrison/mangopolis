extends Node3D

@export var locker: PackedScene

@export var notebook_arrays = [10,12]

var rng = RandomNumberGenerator.new()
var my_array = [1,2,3]
var weights = PackedFloat32Array([2, 0.5, 0.25])

var majimas = 6
var health = 6
var lobsters = 6
var notebooks = 2

var locker_array = []
const offset = Vector3(-10,10.5,0)
const maximum = Vector3(24,0,24)
const total_lockers = 50

const multiplier_x = 10
const multiplier_z = 15

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(len(notebook_arrays)):
		if notebook_arrays[i] in SaveStates.notebooks:
			notebook_arrays.pop_at(i)
	notebooks = len(notebook_arrays)
	distribute_lockers()
	spawn_lockers()
	SaveStates.set_scene()
	
func set_locker(x: int,z: int,item: int):
	var setup_locker = locker.instantiate()
	setup_locker.name = "watermelon_"+str(x)+"_"+str(z)
	add_child(setup_locker)
	setup_locker.global_position = offset+Vector3(multiplier_x*x,0,multiplier_z*z)
	var id_quantity = 0
	if item == 2:
		id_quantity = notebook_arrays.pop_front()
	elif item == 3:
		id_quantity = my_array[rng.rand_weighted(weights)]
	setup_locker.make_locker(item,id_quantity)

func distribute_lockers():
	for i in range(majimas):
		locker_array.append(1)
	for i in range(notebooks):
		locker_array.append(2)
	for i in range(health):
		locker_array.append(3)
	for i in range(lobsters):
		locker_array.append(4)
	for i in range(majimas+notebooks+health+lobsters,total_lockers):
		locker_array.append(0)
	locker_array.shuffle()
	print(locker_array)
	
	
func spawn_lockers():
	var j = 0
	for i in range(25):
		set_locker(i,0,locker_array[j])
		j+=1
		set_locker(i,1,locker_array[j])
		j+=1
