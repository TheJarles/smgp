extends "./OnGround.gd"

func enter():
	animation_flip = "Right" if owner.look_direction == 1 else "Left"
	var animation_name = "Idle " + animation_flip if !Input.is_action_pressed("up") else "Idle Up " + animation_flip
	var current_animation = animation_player.get_current_animation()
	if current_animation.begins_with("Turn") or current_animation.begins_with("Land"):
		animation_player.clear_queue()
		animation_player.queue(animation_name)
	else:
		animation_player.play(animation_name)
	velocity = enter_velocity
	velocity.y = GRAVITY

func handle_input(event):
	var animation_name = "Idle "
	var pos = animation_player.get_current_animation_position()

	if event.is_action_pressed("up"):
		animation_name += "Up " + animation_flip
		set_animation(animation_name)
	elif event.is_action_released("up"):
		animation_name += animation_flip
		set_animation(animation_name)
	else:
		.handle_input(event)

func set_animation(animation_name):
	var pos = animation_player.get_current_animation_position()
	animation_player.play(animation_name)
	animation_player.advance(pos)

func update(delta):
	var input_direction = get_input_direction()
	if input_direction:
		update_look_direction(input_direction)
		emit_signal("finished", "running")
	else:
		if owner.look_direction == 1:
			velocity.x = max(velocity.x - HORIZONTAL_ACCELERATION, 0)
		else:
			velocity.x = min(velocity.x + HORIZONTAL_ACCELERATION, 0)
	owner.move_and_slide(velocity, FLOOR)
	.update(delta)


func _on_direction_changed(direction):
	return ._on_direction_changed(direction)
