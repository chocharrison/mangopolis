extends Node

##########################collectible signals
#notebook collected
signal collected_notebooks_signal(val: int)

#health_potions_signals
signal collected_healthpotions_signal(val: int)
signal heal_signal(val:int)

#dig signals
signal coco_in_dig_range_signal(val: bool)
signal dig_result_signal(pos: Vector3)

#interact signal
signal show_interact_button_signal(val: bool)
signal interracted()

#player signal
signal petting_signal(val: bool)

signal submitted_math_answer(text: String)
signal signal_math(val: int, val2: int, val3: int)
signal math_success(val: bool)


signal trigger_panic()

signal math_in_session(val: bool)

signal hurt_signal(val: int)

signal do_lobster()

signal increase_pikmin_count()


signal hit_kitty()
signal finish_watermelon()

signal done_soda()
