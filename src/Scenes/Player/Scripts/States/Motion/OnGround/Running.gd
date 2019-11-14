extends "./OnGround.gd"


func enter():
	velocity = enter_velocity
	velocity.y = GRAVITY
	animation_flip = "Right" if owner.look_direction == 1 else "Left"
	var current_animation = animation_player.get_current_animation()
	var animation_name = "Run " + animation_flip
	if current_animation.begins_with("Turn") or current_animation.begins_with("Slam"):
		animation_player.clear_queue()
		animation_player.queue(animation_name)
	elif current_animation:
		animation_player.clear_queue()
		animation_player.play(animation_name)
	.enter()


func update(delta):
	var direction = get_input_direction()
	if direction != 0:
		if !animation_player.get_current_animation().begins_with("Slam"):
			update_look_direction(direction)
			velocity.x = clamp(velocity.x + (HORIZONTAL_ACCELERATION * direction), -HORIZONTAL_SPEED, HORIZONTAL_SPEED)
		else:
			if direction == 1:
				velocity.x = max(velocity.x - (HORIZONTAL_ACCELERATION / 3), 0)
			else:
				velocity.x = min(velocity.x + (HORIZONTAL_ACCELERATION / 3), 0)
		velocity = owner.move_and_slide(velocity, FLOOR)
		velocity.y = GRAVITY
		owner.check_for_collision_damage()
		.update(delta)
	else:
		emit_signal("finished", "idling")


func _on_animation_finished(animation):
	var animation_name = "Run " + animation_flip
	animation_player.play(animation_name)


func _on_received_damage():
	emit_signal("finished", "staggering")
