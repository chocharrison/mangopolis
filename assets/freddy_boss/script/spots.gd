extends Node3D

@onready var freddy = $"../Freddy"
@onready var get_spots = $Node3D
@onready var original = $original
@onready var array = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var j = 0
	for i in get_spots.get_children():
		array.append(i)

func get_pos():
	var dis = []
	for i in array:
		var flag = 0
		var k = [i,freddy.global_position.distance_to(i.global_position)]
		for j in dis.size():
			if k[1] < dis[j][1]:
				flag = 1
				dis.insert(j,k)
				break
		if !flag:
			dis.append(k)
	
	return dis[randi_range(1,len(dis)-1)][0].global_position

func get_original():
	return original.global_position
		
		
	
