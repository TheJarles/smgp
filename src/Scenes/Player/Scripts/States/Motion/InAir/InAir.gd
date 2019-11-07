extends "../Motion.gd"

export(float) var TERMINAL_VELOCITY = 48 * 100
export(float) var HIGH_GRAVITY = 1.75

var fall_distance = 0

func handle_input(event):
	.handle_input(event)


func exit():
	owner.get_node("BufferTimer").stop()
	if fall_distance > 96:
		var animation_name = "Land " + animation_flip
		animation_player.play(animation_name)
