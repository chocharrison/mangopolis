extends Node3D

@export var watermelon: PackedScene

@onready var timer = $cool_down
@onready var player = get_tree().get_nodes_in_group("players")[0]

const offset = Vector3(4,0,4)
const maximum = Vector3(24,0,24)
const multiplier = 4
const SPEED = 0.1

var array2D = []
var move2D = []
var follow_player = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(maximum.x):
		var row = []
		var move_row = []
		var follow = []
		for j in range(maximum.z):
			row.append(null)  # or any default value like 0, "", etc.
			move_row.append(Vector2(0,0))
			follow.append(false)
		follow_player.append(follow)
		array2D.append(row)
		move2D.append(move_row)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	watermelon_movement()

func watermelon_phase(i: int):
	if i == 4:
		phase_4()
	elif i == 6:
		phase_6()


func set_watermelon(x: int,z: int,is_fast_fall: bool,damage: int,follow: bool = false,move: Vector2 = Vector2(0,0)):
	var setup_watermelon = watermelon.instantiate()
	setup_watermelon.name = "watermelon_"+str(x)+"_"+str(z)
	add_child(setup_watermelon)
	setup_watermelon.setup(is_fast_fall,damage)
	setup_watermelon.position = offset+Vector3(multiplier*x,0,multiplier*z)
	array2D[x][z] = setup_watermelon
	move2D[x][z] = move
	follow_player[x][z] = follow

func drop_watermelon( x:int, z:int,fall:int = 1):
	follow_player[x][z] = false
	move2D[x][z] = Vector2(0,0)
	array2D[x][z].set_fall(fall)

func wait(seconds: float) -> void:
	timer.start(seconds)
	await timer.timeout

func watermelon_movement():
	for i in range(move2D.size()):
		for j in range(move2D[i].size()):
			if(move2D[i][j]!=Vector2.ZERO):
				array2D[i][j].position.x += move2D[i][j].x * SPEED
				array2D[i][j].position.z += move2D[i][j].y * SPEED
				if(array2D[i][j].position.z > multiplier*maximum.z) or array2D[i][j].position.z < 0:
					move2D[i][j].y = move2D[i][j].y * (-1)

				if(array2D[i][j].position.x > multiplier*maximum.x) or array2D[i][j].position.x < 0:
					move2D[i][j].x = move2D[i][j].x * (-1)
			elif(follow_player[i][j]):
				array2D[i][j].global_position.x = player.global_position.x
				array2D[i][j].global_position.z = player.global_position.z

func clear_watermelons():
	for i in range(array2D.size()):
		for j in range(array2D[i].size()):
			if array2D[i][j] != null:
				drop_watermelon(i,j)
				
func phase_4():
	var i = 0
	var j = 0
	while i < maximum.x:
		j = 0
		while j < maximum.z:
			set_watermelon(i,j,false,10)
			j+=1
		await wait(0.1)
		i+=1
	
	await wait(1)
	i = 0
	j = 0
	while i < maximum.x:
		j = 0
		while j < maximum.z:
			drop_watermelon(i,j)
			j+=1
		if i > maximum.x/2:
			await wait(0.7)
		else:
			await wait(0.2)
		i+=1
	i = 0
	while i < maximum.x:
		j = 0
		while j < maximum.z:
			set_watermelon(j,i,false,10)
			j+=1
		await wait(0.1)
		i+=1
	
	await wait(1)
	i = 0
	j = 0
	while i < maximum.x:
		j = 0
		while j < maximum.z:
			drop_watermelon(j,i)
			#await wait(0.1)
			j+=1
		if i > maximum.x/2:
			await wait(0.7)
		else:
			await wait(0.2)
		i+=1
	SignalManager.finish_watermelon.emit()


func phase_6():
	var i = 0
	while i < 10:
		set_watermelon(i,0,false,10,true)
		await wait(2)
		drop_watermelon(i,0)
	SignalManager.finish_watermelon.emit()
