extends "./OnGround.gd"

func enter():
	velocity = enter_velocity
	velocity.y = GRAVITY
	animation_flip = "Right" if owner.look_direction == 1 else "Left"
	var current_animation = animation_player.get_current_animation()
	var animation_name = "Run " + animation_flip
	if current_animation.begins_with("Turn"):
		animation_player.clear_queue()
		animation_player.queue(animation_name)
	else:
		animation_player.clear_queue()
		animation_player.play(animation_name)


func handle_input(event):
	return .handle_input(event)


func update(delta):
	var direction = get_input_direction()
	if direction:
		update_look_direction(direction)
		velocity.x = clamp(velocity.x + (HORIZONTAL_ACCELERATION * direction), -HORIZONTAL_SPEED, HORIZONTAL_SPEED)
		owner.move_and_slide(velocity, FLOOR)
	else:
		emit_signal("finished", "idling")
	.update(delta)


func _on_animation_finished(animation):
	var animation_name = "Run " + animation_flip
	animation_player.play(animation_name)


func _on_direction_changed(direction):
	return ._on_direction_changed(direction)