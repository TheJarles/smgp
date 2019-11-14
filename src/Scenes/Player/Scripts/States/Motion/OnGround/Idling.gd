extends "./OnGround.gd"

func enter():
	animation_flip = "Right" if owner.look_direction == 1 else "Left"
	var animation_name = "Idle " + animation_flip if !Input.is_action_pressed("up") else "Idle Up " + animation_flip
	var current_animation = animation_player.get_current_animation()
	if current_animation.begins_with("Turn") or current_animation.begins_with("Land") or current_animation.begins_with("Slam"):
		animation_player.clear_queue()
		animation_player.queue(animation_name)
	else:
		animation_player.play(animation_name)
	velocity = enter_velocity
	velocity.y = GRAVITY
	.enter()

func handle_input(event):
	var animation_name = "Idle "
	var pos = animation_player.get_current_animation_position()

	if event.is_action_pressed("up"):
		animation_name += "Up " + animation_flip
		if animation_player.get_current_animation().find("Up") == -1:
			seamless_transition(animation_name)
	elif event.is_action_released("up"):
		animation_name += animation_flip
		if animation_player.get_current_animation().find("Up") != -1:
			seamless_transition(animation_name)
	else:
		.handle_input(event)


func update(delta):
	var input_direction = get_input_direction()
	if input_direction:
		update_look_direction(input_direction)
		emit_signal("finished", "running")
	else:
		if owner.look_direction == 1:
			velocity.x = max(velocity.x - HORIZONTAL_DECELERATION, 0)
		else:
			velocity.x = min(velocity.x + HORIZONTAL_DECELERATION, 0)
	velocity = owner.move_and_slide(velocity, FLOOR)
	velocity.y = GRAVITY
	owner.check_for_collision_damage()
	.update(delta)


func _on_direction_changed(direction):
	return ._on_direction_changed(direction)


func _on_received_damage():
	emit_signal("finished", "staggering")
