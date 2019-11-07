extends KinematicBody2D


signal direction_changed(new_direction)
signal collided(collision, actor)

var look_direction = 1 setget set_look_direction


func set_look_direction(value):
	look_direction = value
	emit_signal("direction_changed", value)

func check_for_contact_damage():
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision:
			emit_signal("collided", collision, self)

