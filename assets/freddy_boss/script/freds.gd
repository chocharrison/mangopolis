extends Node3D

var freds = []
var temp_arrays = []
@onready var cool_down = $Timer
@export var cool_down_range = [2,3]
@export var speed = 1

@onready var fred_node = $Node3D

@onready var finished = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.fred_done.connect(_refill_fred)
	var j = 0
	for i in fred_node.get_children():
		freds.append(i)
		i.fred_num = j
		temp_arrays.append(j)
		j+=1

func set_speed(val1: int,val2: int, val3: int):
	cool_down_range = [val1,val2]
	speed = val3
	fred_dark_start()

func fred_dark_start():
	if !finished:
		print(temp_arrays)
		cool_down.wait_time = randf_range(cool_down_range[0],cool_down_range[1])
		cool_down.start()
		if temp_arrays != []:
			var i = randi_range(0,len(temp_arrays)-1)
			freds[temp_arrays[i]].start(speed)
			temp_arrays.pop_at(i)

func interrupted():
	print("run")
	temp_arrays = [0,1,2,3,4,5,6]
	cool_down.stop()
	for i in freds:
		i.interupt()
	

func _refill_fred(val: int):
	print(val)
	temp_arrays.append(val)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	cool_down.stop()
	fred_dark_start()
