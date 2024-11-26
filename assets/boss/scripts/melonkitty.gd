extends CharacterBody3D


const SPEED = 60.0

enum STATE {IDLE_WAIT,STAB,TIRED,CHARGE,IDLE,SMACKED,DISABLED,DEFAULT,CHARGE_START}
@onready var state = STATE.IDLE

var direction = Vector2(0,0) 
var player_in_range = false
var is_not_timer = true
var locked_in = false

@onready var anime: AnimationTree = get_node_or_null("AnimationTree")
@onready var anime_player: AnimationPlayer = get_node_or_null("AnimationPlayer")
@onready var line: Marker3D = get_node_or_null("line")

@onready var stab: CollisionShape3D = $stab/stab
@onready var cooldown: Timer = $Timer
@onready var player = get_tree().get_nodes_in_group("players")[0]


func _physics_process(delta: float) -> void:

	handle_state_transitions(delta)
	perform_state_actions(delta)
	move_and_slide()

func perform_state_actions(_delta):
	match state:
		STATE.IDLE:
			state_idle()
		STATE.STAB:
			state_stab(_delta)
		STATE.IDLE_WAIT:
			state_idle_wait()
		STATE.CHARGE:
			state_charge(_delta)
		STATE.TIRED:
			state_tired()
		STATE.SMACKED:
			state_smacked()
		STATE.DISABLED:
			state_disabled()
		STATE.CHARGE_START:
			state_charge_start()

func handle_state_transitions(delta):
	if state != STATE.STAB and state != STATE.CHARGE and state != STATE.TIRED:
		stab.disabled = true
	
	if state != STATE.CHARGE:
		velocity = Vector3(0,0,0)
	
	if player_in_range and is_not_timer:
		SignalManager.hurt_signal.emit(10)
		is_not_timer = false
		cooldown.wait_time = 0.5
		cooldown.start()

func state_disabled():
	anime.get("parameters/playback").travel("disabled")

func state_idle():
	set_sprite_direction(player.global_position)
	anime.get("parameters/playback").travel("idle")

func state_idle_wait():
	anime.get("parameters/playback").travel("idle_wait")

func state_stab(delta):
	set_sprite_direction(player.global_position)
	anime.get("parameters/playback").travel("stab")
	global_position = global_position.lerp(player.global_position, 1 * delta)

func state_charge(delta):
	anime.get("parameters/playback").travel("charge")
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	
func state_charge_start():
	if !locked_in:
		set_sprite_direction(player.global_position)
		line.look_at(player.global_position+direction, Vector3.UP)

func state_tired():
	set_sprite_direction_tired(player.global_position)
	anime.get("parameters/playback").travel("tired")
	
func state_smacked():
	pass

func set_sprite_direction(target_position: Vector3):
	direction = (Vector3(target_position.x,0,target_position.z) - Vector3(global_position.x,0,global_position.z)).normalized()
	print(direction)
	anime.set("parameters/idle/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))
	anime.set("parameters/stab/BlendSpace2D/blend_position",Vector2(direction.x,-direction.z))

func set_sprite_direction_tired(target_position: Vector3):
	direction = (Vector3(target_position.x,0,target_position.z) - Vector3(global_position.x,0,global_position.z)).normalized()
	anime.set("parameters/tired/BlendSpace1D/blend_position",direction.z)


func play_intro():
	anime.get("parameters/playback").travel("intro")
	state = STATE.DEFAULT

func set_tired():
	stab.disabled = false
	state = STATE.TIRED
	
func set_stab():
	stab.disabled = false
	state = STATE.STAB


func set_charge():
	stab.disabled = false
	state = STATE.CHARGE

func set_charge_start():
	locked_in = false
	anime.get("parameters/playback").travel("charge_start")
	state = STATE.CHARGE_START

func set_locked_in():
	locked_in = true
	
func _on_stab_body_entered(body: Node3D) -> void:
	if body.name == "main_player":
		if state == STATE.TIRED:
			state = STATE.SMACKED
		else:
			player_in_range = true
			cooldown.wait_time = 0.5
			cooldown.start()
	if state == STATE.CHARGE:
		pass
		


func _on_timer_timeout() -> void:
	cooldown.stop()
	is_not_timer = true

func _on_stab_body_exited(body: Node3D) -> void:
	player_in_range = false


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if(anim_name=="intro"):
		anime.get("parameters/playback").travel("idle_down")
