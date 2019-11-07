extends KinematicBody2D


signal direction_changed(new_direction)


var look_direction = 1 setget set_look_direction


func set_look_direction(value):
	look_direction = value
	emit_signal("direction_changed", value)
