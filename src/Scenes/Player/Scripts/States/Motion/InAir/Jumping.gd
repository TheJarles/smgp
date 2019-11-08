extends "./InAir.gd"

const JUMP_HEIGHT = 200
const MINIMUM_HEIGHT = 96

export(float) var JUMP_VELOCITY = -1171

onready var delay_timer = owner.get_node("BufferTimer")

var jump_start = 0
var peak_height = 0
var horizontal_start = 0
var current_gravity = 0
var jump_released = false
var jump_stopped = false
var gravity_reset = false
var buffer_jump = false

func enter():
	damage = false
	jump_released = false
	jump_stopped = false
	buffer_jump = false
	fall_distance = 0
	peak_height = 0
	horizontal_start = owner.get_global_position().x
#	gravity_reset = false
	velocity = enter_velocity
	velocity.y = JUMP_VELOCITY + GRAVITY
	current_gravity = GRAVITY
	animation_flip = "Right" if owner.look_direction == 1 else "Left"
	jump_start = owner.get_global_position().y
	var animation_name = "Jump " + animation_flip
	animation_player.clear_queue()
	animation_player.play(animation_name)

func jump_height(start = jump_start):
	return start - owner.get_global_position().y

func stop_jump():
	velocity.y = 0
	peak_height = owner.get_global_position().y
	current_gravity = GRAVITY * clamp((HIGH_GRAVITY * jump_height() / JUMP_HEIGHT), 1, 1.75)
#	print(GRAVITY, " ", current_gravity, " ", GRAVITY * HIGH_GRAVITY)
	jump_stopped = true


func handle_input(event):
	if event.is_action_released("jump") and velocity.y < 0:
		jump_released = true
		if jump_height() > MINIMUM_HEIGHT:
			stop_jump()
	elif event.is_action_pressed("jump"):
		buffer_jump = true
		delay_timer.start()
	else:
		.handle_input(event)


func update(delta):

	var direction = get_input_direction()
	if direction:
		update_look_direction(direction)
		velocity.x = clamp(velocity.x + (HORIZONTAL_ACCELERATION * direction),
				-HORIZONTAL_SPEED, HORIZONTAL_SPEED)
	elif owner.look_direction == 1:
		velocity.x = max(velocity.x - HORIZONTAL_ACCELERATION, 0)
	else:
		velocity.x = min(velocity.x + HORIZONTAL_ACCELERATION, 0)

	if jump_height() < 0:
		current_gravity = GRAVITY * HIGH_GRAVITY

	if jump_height() >= MINIMUM_HEIGHT and jump_released and !jump_stopped:
		stop_jump()

	if velocity.y >= 0 and !jump_stopped:
		peak_height = owner.get_global_position().y if !peak_height else peak_height
		current_gravity = GRAVITY * HIGH_GRAVITY

	velocity = owner.move_and_slide(velocity, FLOOR)
	velocity.y = min(velocity.y + current_gravity, TERMINAL_VELOCITY)
	owner.check_for_contact_damage()

	fall_distance = abs(jump_height(peak_height))
	if fall_distance > 96 and velocity.y > 0:
		if !animation_player.get_current_animation().begins_with("Fall"):
			var animation_name = "Fall " + animation_flip
			animation_player.play(animation_name)

	if owner.is_on_floor():
#		print("Horizontal Distance: ", (owner.get_global_position().x - horizontal_start))
#		print("Vertical Distance at Peak: ", (abs(owner.get_global_position().y - peak_height)))
		if damage:
			emit_signal("finished", "staggering")
		if buffer_jump:
			delay_timer.stop()
			emit_signal("finished", "jumping")
		elif Input.is_action_pressed("left") or Input.is_action_pressed("right"):
			emit_signal("finished", "running")
		else:
			emit_signal("finished", "idling")
		


func _on_direction_changed(direction):
	animation_flip = "Right" if direction == 1 else "Left"
	var animation_name = ("Fall " if velocity.y > 0 else "Jump ") + animation_flip
	var pos = animation_player.get_current_animation_position()
	animation_player.play(animation_name)
	animation_player.advance(pos)

func _on_timed_out():
	buffer_jump = false
