extends "../Motion.gd"

export(float) var TERMINAL_VELOCITY = 48 * 100
export(float) var HIGH_GRAVITY = 1.75

var fall_distance = 0
var buffer_jump = false
var damage = false


func exit():
	owner.get_node("BufferTimer").stop()
	if fall_distance > 96:
		var animation_name = "Land " + animation_flip
		animation_player.play(animation_name)


func _on_received_damage():
	owner.get_node("BufferTimer").stop()
	buffer_jump = false
	damage = true



func _on_timed_out():
	buffer_jump = false
