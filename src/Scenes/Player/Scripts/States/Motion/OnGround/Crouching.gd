extends "./OnGround.gd"


func enter():
	animation_flip = "Right" if owner.look_direction == 1 else "Left"
	var animation_name = "Crouch " + animation_flip
	var current_animation = animation_player.get_current_animation()
	var pos = animation_player.get_current_animation_position()
	if current_animation.begins_with("Land") and pos <= 0.3 and pos > 0.06:
		animation_name += " Low"
	if !current_animation.begins_with("Crouch"):
		animation_player.play(animation_name)
	velocity = enter_velocity


func handle_input(event):
	if event.is_action_released("down"):
		if Input.is_action_pressed("jump"):
			emit_signal("finished", "jumping")
		elif Input.is_action_pressed("right") or Input.is_action_pressed("left"):
			var animation_name = "Stand " + animation_flip
			animation_player.play(animation_name)
		else:
			emit_signal("finished", "idling")


func exit():
	var animation_name = "Stand " + animation_flip
	if !animation_player.get_assigned_animation().begins_with("Stand"):
		animation_player.play(animation_name)


func update(delta):
	var direction = get_input_direction()
	update_look_direction(direction)
	if sign(enter_velocity.x) > 0:
		velocity.x = max(velocity.x - (HORIZONTAL_ACCELERATION / 3), 0)
	elif sign(enter_velocity.x) < 0:
		velocity.x = min(velocity.x + (HORIZONTAL_ACCELERATION / 3), 0)
	else:
		velocity.x = 0
	velocity = owner.move_and_slide(velocity, FLOOR)
	velocity.y = GRAVITY
	owner.check_for_collision_damage()
	.update(delta)
	

func _on_received_damage():
	emit_signal("finished", "staggering")


func _on_direction_changed(direction):
	animation_flip = "Right" if direction == 1 else "Left"
	if animation_player.get_current_animation() == "":
		if direction == 1:
			animation_player.play("Crouch Right Low")
		else:
			animation_player.play("Crouch Left Low")
	elif !animation_player.get_current_animation().begins_with("Stand"):
		var animation_variant = "" if animation_player.get_current_animation().find("Low") == -1 else " Low"
		var animation_name = "Crouch " + animation_flip + animation_variant
		seamless_transition(animation_name)
	else:
		var animation_name = "Stand " + animation_flip
		seamless_transition(animation_name)


func _on_animation_finished(animation):
	if animation.begins_with("Stand"):
		emit_signal("finished", "running")
