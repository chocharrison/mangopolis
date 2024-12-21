extends Node3D

@export var watermelon: PackedScene

@onready var timer = $cool_down
@onready var player_timer = $player_timer
@onready var player = get_tree().get_nodes_in_group("players")[0]

const offset = Vector3(4,0.4,4)
const maximum = Vector3(24,0,24)
const multiplier = 4
const SPEED = 1

var array2D = []
var original2D = []
var move2D = []
var follow = [false]
var flagi = true
var follows_player_throughout = false
var flag = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(maximum.x):
		var row = []
		var move_row = []
		var original_row = []
		for j in range(maximum.z):
			var setup_watermelon = watermelon.instantiate()
			setup_watermelon.name = "watermelon_"+str(i)+"_"+str(j)
			setup_watermelon.position = offset+Vector3(multiplier*i,0,multiplier*j)
			original_row.append(offset+Vector3(multiplier*i,0,multiplier*j))
			setup_watermelon.set_hide()
			add_child(setup_watermelon)
			row.append(setup_watermelon)  # or any default value like 0, "", etc.
			move_row.append(Vector2(0,0))
		original2D.append(original_row)
		array2D.append(row)
		move2D.append(move_row)
		var setup_watermelon = watermelon.instantiate()
		setup_watermelon.set_hide()
		setup_watermelon.position = offset+Vector3(multiplier*0,0,multiplier*0)
		add_child(setup_watermelon)
		follow.append(setup_watermelon)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if flag:
		watermelon_movement()
		if follows_player_throughout and flagi:
			follow_player_throughout_func()
		

func set_follow_player(val: bool):
	follows_player_throughout = val

func watermelon_phase(i: int):
	if i == 3:
		phase_3()
	if i == 5:
		phase_5()
	if i == 8:
		phase_8()
	if i == 10:
		phase_10()
	
func set_follow_watermelon():
	follow[0] = true
	follow[1].set_spawn(false,10)
	follow[1].global_position.x = player.global_position.x
	follow[1].global_position.z = player.global_position.z

func drop_follow_watermelon(val: int):
	follow[1].set_fall(val)
	follow[0] = false

func set_watermelon(x: int,z: int,is_fast_fall: bool,damage: int,move: Vector2 = Vector2(0,0)):
	if x <= array2D.size():
		if z < array2D[x].size():
			array2D[x][z].set_spawn(is_fast_fall,damage)
			array2D[x][z].position = original2D[x][z]
			move2D[x][z] = move

func drop_watermelon( x:int, z:int,fall:int = 1):
	if x < array2D.size():
		if z < array2D[x].size():
			move2D[x][z] = Vector2(0,0)
			array2D[x][z].set_fall(fall)

func wait(seconds: float) -> void:
	timer.start(seconds)
	await timer.timeout

func wait_player(seconds: float) -> void:
	player_timer.start(seconds)
	await player_timer.timeout

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
	if(follow[0]):
		follow[1].global_position.x = player.global_position.x
		follow[1].global_position.z = player.global_position.z

func clear_watermelons():
	for i in range(array2D.size()):
		for j in range(array2D[i].size()):
			array2D[i][j].queue_free()
		for j in range(maximum.z):
			array2D[i].pop_back()
	for i in range(maximum.x):
		array2D.pop_back()

func follow_player_throughout_func():
	flagi = 0
	set_follow_watermelon()
	await wait_player(0.1)
	drop_follow_watermelon(2)
	await wait_player(1)
	flagi = 1

func phase_3():
	for i in range(maximum.x):
		for j in [12,13]:
			set_watermelon(i,j,false,10)
		await wait(0.1)

	for i in range(maximum.x):
		for j in [12,13]:
			drop_watermelon(i,j)
	await wait(0.5)

	for j in range(maximum.z):
		for i in [12,13]:
			set_watermelon(i,j,false,10)
		await wait(0.1)

	for j in range(maximum.z):
		for i in [12,13]:
			drop_watermelon(i,j)
	await wait(0.5)
	
	
	for j in range(maximum.z):
		set_watermelon(j,j,false,10)
		await wait(0.1)

	for j in range(maximum.z):
		drop_watermelon(j,j)
	await wait(0.5)
	
	
	
	for j in range(maximum.z):
		set_watermelon(j,24-j-1,false,10)
		await wait(0.1)

	for j in range(maximum.z):
		drop_watermelon(j,24-j-1)
	await wait(0.5)
	
	SignalManager.finish_watermelon.emit()


func phase_5():
	for k in range(3):
		for i in range(maximum.x):
			for j in range(5):
				set_watermelon(i,j,false,10,Vector2(randf_range(-1,1),randf_range(-1,1)))
		await wait(5)
		for i in range(maximum.x):
			for j in range(5):
				drop_watermelon(i,j)
		await wait(2)
	SignalManager.finish_watermelon.emit()


func phase_final():
	for i in range(12):
		if i < array2D.size():
			for j in range(maximum.z):
					set_watermelon(i,j,false,10)
					set_watermelon(24-i-1,j,false,10)
			await wait(0.1)
		await wait(1)
		for j in range(maximum.z):
			if i < array2D.size():
				drop_watermelon(i,j)
				drop_watermelon(24-i-1,j)
			await wait(0.1)
		
func phase_8():
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
		if i > 20:
			await wait(0.6)
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
		if i > 20:
			await wait(0.6)
		else:
			await wait(0.2)
		i+=1
	SignalManager.finish_watermelon.emit()

func phase_10():
	for k in range(12):
		for i in range(maximum.x):
			if i%2 == 0:
				for j in range(maximum.z):
					if j%4==k%4:
						set_watermelon(i,j,false,10)
		await wait(0.5)

		for i in range(maximum.x):
			if i%2 == 0:
				for j in range(maximum.z):
					if j%4==k%4:
						drop_watermelon(i,j)
		
		await wait(0.5)
	wait(2)
	
	SignalManager.finish_watermelon.emit()


func phase_11():
	for i in range(maximum.x):
		set_watermelon(i,10,false,10,Vector2(randf_range(-1,1),randf_range(-1,1)))
	await wait(5)
	for i in range(maximum.x):
		drop_watermelon(i,10)
	await wait(2)
	
func phase_12():
	for i in range(maximum.x):
		for j in [12,13]:
			set_watermelon(i,j,false,10)
		await wait(0.1)

	for i in range(maximum.x):
		for j in [12,13]:
			drop_watermelon(i,j)
	await wait(0.2)

	for j in range(maximum.z):
		for i in [12,13]:
			set_watermelon(i,j,false,10)
		await wait(0.1)

	for j in range(maximum.z):
		for i in [12,13]:
			drop_watermelon(i,j)
	await wait(0.2)
	
	
	for j in range(maximum.z):
		set_watermelon(j,j,false,10)
		await wait(0.1)

	for j in range(maximum.z):
		drop_watermelon(j,j)
	await wait(0.2)
	
	
	
	for j in range(maximum.z):
		set_watermelon(j,24-j-1,false,10)
		await wait(0.1)

	for j in range(maximum.z):
		drop_watermelon(j,24-j-1)
	await wait(0.2)
	
