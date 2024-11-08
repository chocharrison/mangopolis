extends Control

##################################### node assignments
var math:Panel
var first:Label
var second:Label
var equation:Label
var answer:LineEdit
var math_anime:AnimationPlayer
var timer_bar: ProgressBar

##################################### Signals
signal submitted_math_answer(text: String)

##################################### default functions

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

##################################### ui set functions
# Plays success animation when the player submits the correct answer
func math_success():
	answer.release_focus()
	math_anime.play("math_success")

# Plays failure animation when the player submits an incorrect answer
func math_failure():
	answer.release_focus()
	math_anime.play("math_failure")

# Initializes the math puzzle UI, clearing the previous input and preparing for a new math question
func math_enter():
	answer.clear()
	math.set_process(true)
	math_anime.play("math_enter")
	answer.grab_focus()

##################################### set functions
# Sets the first operand in the math puzzle
func set_first(val: int):
	first.text = str(val)

# Sets the second operand in the math puzzle
func set_second(val: int):
	second.text = str(val)

# Sets the operator symbol (e.g., +, -, x) in the math puzzle
func set_equation(val: String):
	equation.text = str(val)

# Updates the timer bar value based on the time left for solving the puzzle
func set_timer(val: int):
	timer_bar.value = val

##################################### signal functions
# Handles the player's input when they submit a math answer, emitting the answer as a signal
func _on_answer_text_submitted(new_text: String) -> void:
	emit_signal("submitted_math_answer",new_text)
