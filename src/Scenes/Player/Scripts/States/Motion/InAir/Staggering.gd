extends "./InAir.gd"

var start_height = 0

func enter():
	start_height = owner.get_global_position().y
	var look_direction = owner.look_direction
	velocity.x = -HORIZONTAL_SPEED if look_direction == 1 else HORIZONTAL_SPEED
	velocity.y = -750
	animation_flip = "Right" if look_direction == 1 else "Left"
	var animation_name = "Stagger " + animation_flip
	owner.get_node("AnimationPlayer").play(animation_name)

	
func update(delta):
	velocity.y += GRAVITY
	owner.move_and_slide(velocity, FLOOR)
	if owner.get_global_position().y > start_height:
		emit_signal("finished", "falling")
	if(owner.is_on_floor()):
		print(velocity.y)
		emit_signal("finished", "idling")
