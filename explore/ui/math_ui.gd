extends Control

var math:Panel
var first:Label
var second:Label
var equation:Label
var answer:LineEdit
var math_anime:AnimationPlayer
var timer_bar: ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	math = get_node("math")
	math.set_process(false)
	math.visible = false
	math_anime = get_node("math_animation")
	timer_bar = get_node("math/timer")
	
	first = get_node("math/h/first")
	second = get_node("math/h/second")
	equation = get_node("math/h/operand")
	answer = get_node("math/h/answer")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func math_success():
	answer.release_focus()
	math_anime.play("math_success")

func math_failure():
	answer.release_focus()
	math_anime.play("math_failure")

func math_enter():
	answer.clear()
	math.set_process(true)
	math_anime.play("math_enter")
	answer.grab_focus()
	
func set_first(val: int):
	first.text = str(val)

func set_second(val: int):
	second.text = str(val)
	
func set_equation(val: String):
	equation.text = str(val)

func set_timer(val: int):
	timer_bar.value = val
