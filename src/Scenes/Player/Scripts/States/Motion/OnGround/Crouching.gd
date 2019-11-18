extends "./OnGround.gd"


func enter():
	owner.get_node("JumpingHitbox").set_disabled(true)
	owner.get_node("StandingHitbox").set_disabled(true)
	owner.get_node("CrouchingHitbox").set_disabled(false)
	animation_flip = "Right" if owner.look_direction == 1 else "Left"
	var animation_name = "Crouch " + animation_flip
	var current_animation = animation_player.get_current_animation()
	var pos = animation_player.get_current_animation_position()
	if current_animation.begins_with("Land") and pos <= 0.3 and pos > 0.06:
		animation_name += " Low"
	if !current_animation.begins_with("Crouch"):
		animation_player.play(animation_name)
	if current_animation.begins_with("Crawl"):
		animation_player.advance(animation_player.get_current_animation_length())
	velocity = enter_velocity
	velocity.y = GRAVITY


func raycast_collision():
	return owner.get_node("CrouchingRayLeft").is_colliding() or \
	owner.get_node("CrouchingRayRight").is_colliding()


func handle_input(event):
	if !raycast_collision() and event.is_action_pressed("jump"):
		emit_signal("finished", "jumping")


func exit():
	var animation_name = "Stand " + animation_flip
	if !animation_player.get_assigned_animation().begins_with("Stand"):
		animation_player.play(animation_name)


func update(delta):
	if !Input.is_action_pressed("down") and !raycast_collision():
		if Input.is_action_pressed("right") or Input.is_action_pressed("left"):
			var animation_name = "Stand " + animation_flip
			animation_player.play(animation_name)
		else:
			emit_signal("finished", "idling")
	var direction = get_input_direction()
	if direction:
		update_look_direction(direction)
		emit_signal("finished", "crawling")
	else:
		if sign(enter_velocity.x) > 0:
			velocity.x = max(velocity.x - HORIZONTAL_DECELERATION, 0)
		elif sign(enter_velocity.x) < 0:
			velocity.x = min(velocity.x + HORIZONTAL_DECELERATION, 0)
		else:
			velocity.x = 0
		velocity = owner.move_and_slide(velocity, FLOOR)
		velocity.y = GRAVITY
		owner.check_for_collision_damage()
		.update(delta)
	

func _on_received_damage():
	emit_signal("finished", "staggering")


func _on_animation_finished(animation):
	if animation.begins_with("Stand"):
		emit_signal("finished", "running")
