extends Node3D

@onready var music = $AudioStreamPlayer
@onready var fsm_player = $"../FSM_Players"
@onready var anim = $AnimationPlayer
@onready var music_finish = true
@onready var countdown = 3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if SaveStates.first_death:
		queue_free()
	SignalManager.enemies_done.connect(finish)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !music_finish and !music.is_playing():
		music.play()

func intro():
	anim.play("enemy_intro_1")

func intro_2():
	anim.play("enemy_intro_2")
	music.stream = load("res://assets/enemies/sound/enemy_intro.mp3")
	music.play()

func intro_done():
	anim.play("enemy_intro_done")
	fsm_player.enable()
	fsm_player.state_health_timer_enable()

func set_cutscene():
	fsm_player.disable()
	fsm_player.state_health_timer_disable()
	intro()

func finish():
	countdown-=1
	if countdown <= 0:
		music.stop()
		queue_free()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "main_player":
		set_cutscene()
		$Area3D.queue_free()
