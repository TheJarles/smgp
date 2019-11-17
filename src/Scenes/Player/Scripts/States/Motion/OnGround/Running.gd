extends "./OnGround.gd"

var acceleration = HORIZONTAL_ACCELERATION

func enter():
	print(enter_velocity.x)
	acceleration = HORIZONTAL_ACCELERATION
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
	.enter()


func handle_input(event):
	if event.is_action_pressed("down"):
		emit_signal("finished", "crawling")
	.handle_input(event)


func update(delta):
	var direction = get_input_direction()
	if direction != 0:
		update_look_direction(direction)
		acceleration = HORIZONTAL_DECELERATION if sign(velocity.x) != owner.look_direction else HORIZONTAL_ACCELERATION
		velocity.x = clamp(velocity.x + (acceleration * direction), -HORIZONTAL_SPEED, HORIZONTAL_SPEED)
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
