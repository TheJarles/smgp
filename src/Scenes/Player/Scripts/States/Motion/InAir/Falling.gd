extends "./InAir.gd"

onready var delay_timer = owner.get_node("Timer")

var fall_start = 0
var coyote_time = true
var buffer_jump = false

func enter():
	fall_start = owner.get_global_position().y
	fall_distance = 0
	velocity = enter_velocity
	coyote_time = true
	buffer_jump = false
	animation_player.clear_queue()
	delay_timer.start(delay_timer.get_wait_time())

func handle_input(event):
	if event.is_action_pressed("jump"):
		if coyote_time:
			delay_timer.stop()
			emit_signal("finished", "jumping")
		else:
			buffer_jump = true
			delay_timer.start(delay_timer.get_wait_time())
	else:
		.handle_input(event)

func update(delta):
	var direction = get_input_direction()
	if direction:
		update_look_direction(direction)
		velocity.x = clamp(velocity.x + (HORIZONTAL_ACCELERATION * ACCELERATION_MULTIPLIER * direction),
				-HORIZONTAL_SPEED, HORIZONTAL_SPEED)
	elif owner.look_direction == 1:
		velocity.x = max(velocity.x - (HORIZONTAL_ACCELERATION * ACCELERATION_MULTIPLIER), 0)
	else:
		velocity.x = min(velocity.x + (HORIZONTAL_ACCELERATION * ACCELERATION_MULTIPLIER), 0)
	velocity.y = min(velocity.y + (GRAVITY * HIGH_GRAVITY), TERMINAL_VELOCITY)
	velocity = owner.move_and_slide(velocity, FLOOR)
	fall_distance = abs(fall_start - owner.get_global_position().y)
	
	if fall_distance > 96 and !animation_player.get_current_animation().begins_with("Fall "):
		var animation_name = "Fall " + animation_flip
		animation_player.play(animation_name)
	if owner.is_on_floor():
		if buffer_jump:
			print("Buffered Jump!")
			delay_timer.stop()
			emit_signal("finished", "jumping")
		elif Input.is_action_pressed("left") or Input.is_action_pressed("right"):
			.exit()
			emit_signal("finished", "running")
		else:
			.exit()
			emit_signal("finished", "idling")


func _on_direction_changed(direction):
	if direction == 1:
		animation_flip = "Right"
	else:
		animation_flip = "Left"

func _on_timed_out():
	if coyote_time:
		coyote_time = false
		animation_flip = "Right" if owner.look_direction == 1 else "Left"
		var animation_name = "Jump " + animation_flip
		animation_player.play(animation_name)
		animation_player.advance(animation_player.current_animation_length)
		animation_player.stop()
	else:
		buffer_jump = false