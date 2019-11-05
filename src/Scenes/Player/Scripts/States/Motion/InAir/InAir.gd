extends "../Motion.gd"

export(float) var TERMINAL_VELOCITY = 48 * 100
export(float) var ACCELERATION_MULTIPLIER = 2
export(float) var LOW_GRAVITY = 1.25
export(float) var HIGH_GRAVITY = 1.75
export(float) var MINIMUM_HEIGHT = 96

var fall_distance = 0

func handle_input(event):
	.handle_input(event)

func exit():
	owner.get_node("Timer").stop()
	var animation_name = "Land " + animation_flip
	animation_player.play(animation_name)