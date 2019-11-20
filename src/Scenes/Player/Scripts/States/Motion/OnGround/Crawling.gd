extends "./OnGround.gd"

export(float) var CRAWL_SPEED = HORIZONTAL_SPEED / 3

func enter():
	owner.get_node("JumpingHitbox").set_disabled(true)
	owner.get_node("StandingHitbox").set_disabled(true)
	owner.get_node("CrouchingHitbox").set_disabled(false)
	velocity = enter_velocity
	velocity.y = GRAVITY
	animation_flip = "Right" if owner.look_direction == 1 else "Left"
	var animation_name = "Crawl " + animation_flip
	animation_player.play(animation_name)


func raycast_collision():
	return owner.get_node("CrouchingRayLeft").is_colliding() or \
	owner.get_node("CrouchingRayRight").is_colliding()


func handle_input(event):
	if !raycast_collision():
		if event.is_action_pressed("jump"):
			emit_signal("finished", "jumping")
	if event.is_action_pressed("down"):
		var animation_name = "Crawl Right"
		if !animation_player.get_current_animation().begins_with("Crawl"):
			animation_player.play(animation_name)


func update(delta):
	if !Input.is_action_pressed("down") and !raycast_collision():
		if Input.is_action_pressed("right") or Input.is_action_pressed("left"):
				var animation_name = "Stand " + animation_flip + " Crawl"
				animation_player.play(animation_name)
		else:
			var animation_name = "Stand " + animation_flip + " Crawl"
			animation_player.play(animation_name)
			emit_signal("finished", "idling")
	var direction = get_input_direction()
	update_look_direction(direction)
	if abs(velocity.x) > CRAWL_SPEED:
		if sign(enter_velocity.x) > 0:
			velocity.x = max(velocity.x - HORIZONTAL_DECELERATION, CRAWL_SPEED)
		else:
			velocity.x = min(velocity.x + HORIZONTAL_DECELERATION, CRAWL_SPEED)
	else:
		if direction:
			velocity.x = clamp(velocity.x + (HORIZONTAL_ACCELERATION * owner.look_direction), -CRAWL_SPEED, CRAWL_SPEED)
		elif !animation_player.get_current_animation().begins_with("Stand"):
			emit_signal("finished", "crouching")
		else:
			velocity.x = min(velocity.x + HORIZONTAL_DECELERATION, 0) if velocity.x < 0 else \
			max(velocity.x - HORIZONTAL_DECELERATION, 0)
	velocity = owner.move_and_slide(velocity, FLOOR)
	velocity.y = GRAVITY
	owner.check_for_collision_damage()
	.update(delta)


func _on_direction_changed(direction):
	animation_flip = "Right" if direction == 1 else "Left"
	if animation_player.get_current_animation().begins_with("Stand"):
		var animation_name = "Stand " + animation_flip
		seamless_transition(animation_name)
	else:
		var animation_name = "Crawl " + animation_flip


func _on_received_damage():
	emit_signal("finished", "staggering")


func _on_animation_finished(animation):
	if animation.begins_with("Stand"):
		emit_signal("finished", "running")