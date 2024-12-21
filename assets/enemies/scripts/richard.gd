extends CharacterBody3D


@export var SPEED = 1.0
@export var BOUNCE = 60
@export var punch_cooldown = 10
@export var windup_cooldown = 1
@export var invincible_cooldown = 5
@export var health = 3
@export var damage = 10
@export var idle_cooldown = [4,10]
@export var walk_cooldown = [2,8]

@onready var anime = get_node("AnimationTree")
@onready var soundeffects = get_node("AudioStreamPlayer3D")


@onready var direction = Vector3(0,0,0)
 
##################################### States
enum STATE {WALK, WINDUP, PUNCH, DEATH, IDLE, HURT, INACTIVE, INTRO}
@onready var state = STATE.INACTIVE
@onready var player = get_tree().get_nodes_in_group("players")[0]
@onready var player_in_range = false
@onready var is_not_timer = false
@onready var death = false
@onready var is_interactive = false
@onready var can_hurt = true


@onready var windup_timer = $windup
@onready var invincible_timer = $invincible
@onready var hurtbox = $Area3D/CollisionShape3D
@onready var invincible_player = $AnimationPlayer2
@onready var punch_anim = $AnimationPlayer3
@onready var bounce_timer = $bounce
@onready var idle_timer = $Timer
@onready var walk_timer = $walk

func _ready() -> void:
	SignalManager.interracted.connect(_on_interact)
	SignalManager.math_in_session.connect(_is_math)
	SignalManager.grunt_inactive.connect(set_inactive)
	set_walk()
	

func _physics_process(_delta: float) -> void:
	#print("idle:"+str(idle_timer.time_left))
	#print("walk:"+str(walk_timer.time_left))
	#print("windup:"+str(windup_timer.time_left))

	if not is_on_floor():
		velocity += get_gravity() * _delta

	handle_state_transitions()
	perform_state_actions(_delta)
	handle_animation_state()
	move_and_slide()

func perform_state_actions(_delta):
	match state:
		STATE.WALK:
			state_chase(_delta)
		STATE.HURT:
			state_hurt(_delta)
		STATE.WINDUP:
			state_windup()
		STATE.IDLE:
			state_idle()

func handle_state_transitions():
	if state == STATE.DEATH:
		return

func state_chase(_delta):
	global_position = global_position.lerp(player.global_position, SPEED * _delta)
	set_sprite_direction(player.global_position)

func state_hurt(_delta):
	velocity.x = -direction.x * BOUNCE
	velocity.z = -direction.z * BOUNCE

func state_windup():
	set_sprite_direction(player.global_position)

func state_idle():
	set_sprite_direction(player.global_position)

func _is_math(val: bool):
	if val:
		set_inactive()
	else:
		set_walk()

func set_inactive():
	state = STATE.INACTIVE
	bounce_timer.stop()
	windup_timer.stop()
	invincible_timer.stop()
	walk_timer.stop()
	idle_timer.stop()
	print("inactive")

func set_idle():
	print("idle")
	state = STATE.IDLE
	walk_timer.stop()
	idle_timer.start(randf_range(idle_cooldown[0],idle_cooldown[1]))
	punch_anim.play("interupt")
	

func set_windup():
	state = STATE.WINDUP
	velocity = Vector3(0,0,0)
	walk_timer.stop()
	idle_timer.stop()
	windup_timer.start(windup_cooldown)
	punch_anim.play("interupt")

func set_walk():
	state = STATE.WALK
	print("walk")
	velocity = Vector3(0,0,0)
	walk_timer.start(randf_range(walk_cooldown[0],walk_cooldown[1]))
	idle_timer.stop()
	punch_anim.play("interupt")

func set_punch():
	state = STATE.PUNCH
	punch_anim.play("punch")
	print("punch")
	

func set_hurt():
	invincible_player.play("invincible")
	soundeffects.stream = load("res://assets/boss/sound_effects/punch.mp3")
	soundeffects.play()
	set_sprite_direction(player.global_position)
	state = STATE.HURT
	bounce_timer.start(4)
	windup_timer.stop()
	invincible_timer.start(invincible_cooldown)
	can_hurt = false
	walk_timer.stop()
	idle_timer.stop()
	punch_anim.play("interupt")

func set_death():
	print("dead")
	state = STATE.DEATH
	SignalManager.hit_kitty.emit()
	velocity = Vector3(0,0,0)
	anime.get("parameters/playback").travel("death")
	soundeffects.stream = load("res://assets/enemies/sound/death.mp3")
	soundeffects.play()
	bounce_timer.stop()
	windup_timer.stop()
	invincible_timer.stop()
	walk_timer.stop()
	idle_timer.stop()
	can_hurt = false
	$death.start(3)
	SignalManager.grunt_dead.emit()
	punch_anim.play("interupt")

func set_sprite_direction(target_position: Vector3):
	direction = (Vector3(target_position.x,0,target_position.z) - Vector3(global_position.x,0,global_position.z)).normalized()
	anime.set("parameters/idle/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
	anime.set("parameters/walk/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
	anime.set("parameters/windup/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
	anime.set("parameters/punch/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))


func handle_animation_state():
	match state:
		STATE.WALK:
			anime.get("parameters/playback").travel("walk")
		STATE.WINDUP:
			anime.get("parameters/playback").travel("windup")
		STATE.PUNCH:
			anime.get("parameters/playback").travel("punch")
		STATE.HURT:
			anime.get("parameters/playback").travel("hurt")
		STATE.DEATH:
			anime.get("parameters/playback").travel("death")
		STATE.INACTIVE:
			anime.get("parameters/playback").travel("inactive")
		STATE.IDLE:
			anime.get("parameters/playback").travel("idle")

func _on_interact(panicked):
	if is_interactive and !panicked and state != STATE.DEATH and can_hurt:
		print("hit")
		is_interactive = false
		health -= 1
		if health <= 0:
			set_death()
		else:
			set_hurt()
		SignalManager.show_interact_button_signal.emit(false)



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "main_player" and state != STATE.HURT and state != STATE.DEATH and state != STATE.INACTIVE:
		SignalManager.show_interact_button_signal.emit(true)
		is_interactive = true
		if state != STATE.WINDUP and state != STATE.PUNCH:
			set_windup()
		

	elif state == STATE.HURT:
		if body.name == "side" and body.name == "side2":
			direction.x = -1*direction.x
			soundeffects.stream = load("res://assets/boss/sound_effects/collide.mp3")
			soundeffects.play()
		elif body.name == "back" or body.name == "back2":
			direction.z = -1*direction.z
			soundeffects.stream = load("res://assets/boss/sound_effects/collide.mp3")
			soundeffects.play()
		elif body.name == "main_player":
			set_sprite_direction(player.global_position)
			soundeffects.stream = load("res://assets/boss/sound_effects/collide.mp3")
			soundeffects.play()

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "main_player":
		SignalManager.show_interact_button_signal.emit(false)
		is_interactive = false


func _on_windup_timeout() -> void:
	windup_timer.stop()
	set_punch()


func _on_punch_body_entered(body: Node3D) -> void:
	if body.name == "main_player":
		SignalManager.hurt_signal.emit(damage)


func _on_invincible_timeout() -> void:
	invincible_timer.stop()
	can_hurt = true
	invincible_player.stop()


func _on_bounce_timeout() -> void:
	bounce_timer.stop()
	print("here")
	set_walk()


func _on_walk_timeout() -> void:
	print("walk timeout")
	set_idle()


func _on_idle_timeout() -> void:
	print("idle timeout")
	set_walk()


func _on_death_timeout() -> void:
	queue_free()
