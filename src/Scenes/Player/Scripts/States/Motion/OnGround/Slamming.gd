extends "./OnGround.gd"

onready var buffer_timer = owner.get_node("BufferTimer")

var buffer_jump = false


func enter():
	buffer_jump = false
	velocity = enter_velocity
	velocity.y = GRAVITY
	animation_flip = "Right" if owner.look_direction == 1 else "Left"
	var animation_variant = "" if sign(enter_velocity.x) == sign(owner.look_direction) else " Stationary"
	var animation_name = "Slam " + animation_flip + animation_variant
	animation_player.play(animation_name)


func handle_input(event):
	if event.is_action_pressed("jump"):
		buffer_jump = true
		buffer_timer.start()


func exit():
	buffer_timer.stop()


func update(delta):
	if sign(enter_velocity.x) > 0:
		velocity.x = max(velocity.x - (HORIZONTAL_ACCELERATION / 3), 0)
	elif sign(enter_velocity.x) < 0:
		velocity.x = min(velocity.x + (HORIZONTAL_ACCELERATION / 3), 0)
	velocity = owner.move_and_slide(velocity, FLOOR)
	velocity.y = GRAVITY
	owner.check_for_collision_damage()
	.update(delta)


func _on_animation_finished(animation):
	if animation.begins_with("Slam"):
		if buffer_jump:
			emit_signal("finished", "jumping")
		elif Input.is_action_pressed("down") and (Input.is_action_pressed("right") or Input.is_action_pressed("left")):
			emit_signal("finished", "crawling")
		elif Input.is_action_pressed("down"):
			var animation_name = "Crouch " + animation_flip + " Low"
			animation_player.play(animation_name)
			emit_signal("finished", "crouching")
		elif Input.is_action_pressed("right") or Input.is_action_pressed("left"):
			var animation_name = "Stand " + animation_flip
			animation_player.play(animation_name)
		else:
			var animation_name = "Stand " + animation_flip
			animation_player.play(animation_name)
			emit_signal("finished", "idling")
	else:
		emit_signal("finished", "running")


func _on_received_damage():
	emit_signal("finished", "staggering")


func _on_timed_out():
	buffer_jump = false
