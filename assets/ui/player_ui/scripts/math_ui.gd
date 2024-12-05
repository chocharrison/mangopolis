extends Control

##################################### node assignments
@onready var math = get_node("math")
@onready var first = get_node("math/h/first")
@onready var second = get_node("math/h/second")
@onready var equation = get_node("math/h/operand")
@onready var answer = get_node("math/h/answer")
@onready var math_anime = get_node("math_animation")
@onready var timer_bar = get_node("math/timer")

##################################### default functions

func _ready() -> void:
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
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
	#print("start")
	answer.clear()
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
	SignalManager.submitted_math_answer.emit(new_text)
