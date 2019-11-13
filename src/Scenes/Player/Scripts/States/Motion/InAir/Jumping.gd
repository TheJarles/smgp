extends "./InAir.gd"


export(float) var JUMP_VELOCITY = -1200

var jump_start = 0
var peak_height = 0
var horizontal_start = 0
var current_gravity = 0
var jump_released = false
var jump_stopped = false
var bonked = false
var previous_velocity = Vector2()
var hang_time = 0


func _ready():
	momentum_timer.connect("timeout", self, "_on_momentum_timed_out")


func enter():
	damage = false
	jump_released = false if Input.is_action_pressed("jump") else true
	jump_stopped = false
	buffer_jump = false
	bonked = false
	fall_distance = 0
	peak_height = 0
	hang_time = 0
	horizontal_start = owner.get_global_position().x
	velocity = enter_velocity
	velocity.y = JUMP_VELOCITY
	previous_velocity = velocity
	current_gravity = GRAVITY
	animation_flip = "Right" if owner.look_direction == 1 else "Left"
	jump_start = owner.get_global_position().y
	momentum_buffer = true if velocity.x != 0 else false
	var animation_name = "Jump " + animation_flip if velocity.x != 0 else "Jump " + animation_flip + " Stationary"
	animation_player.clear_queue()
	animation_player.stop()
	animation_player.play(animation_name)
	.enter()

func jump_height(start = jump_start):
	return start - owner.get_global_position().y

func stop_jump():
	velocity.y /= 2
	current_gravity = GRAVITY * HIGH_GRAVITY
	jump_stopped = true


func handle_input(event):
	if event.is_action_released("jump") and velocity.y < 0:
		jump_released = true
		if jump_height() > MINIMUM_HEIGHT:
			stop_jump()
	elif event.is_action_pressed("jump"):
		buffer_jump = true
		buffer_timer.start()
	else:
		.handle_input(event)


func update(delta):

	# Code for handling horizontal acceleration
	var direction = get_input_direction()
	if direction:
		momentum_buffer = true
		update_look_direction(direction)
		velocity.x = clamp(velocity.x + (HORIZONTAL_ACCELERATION * air_drag * direction),
				-HORIZONTAL_SPEED, HORIZONTAL_SPEED)
	elif owner.look_direction == 1:
		velocity.x = max(velocity.x - (HORIZONTAL_DECELERATION * air_drag), 0)
	else:
		velocity.x = min(velocity.x + (HORIZONTAL_DECELERATION * air_drag), 0)

	if !direction and momentum_timer.get_time_left() == 0:
		momentum_timer.start()

	# If player is below the starting point of the jump, set gravity to high gravity
	if jump_height() < 0:
		current_gravity = GRAVITY * HIGH_GRAVITY

	# If player has released the jump button and the jump hasn't been stopped, stop the jump
	if jump_height() >= MINIMUM_HEIGHT and jump_released and !jump_stopped:
		stop_jump()

	if velocity.y >= 0 and !peak_height:
		peak_height = owner.get_global_position().y
		current_gravity = GRAVITY * HIGH_GRAVITY
		var animation_name = "Fall Start " + animation_flip
		animation_player.play(animation_name)

	previous_velocity = velocity
	velocity = owner.move_and_slide(velocity, FLOOR)
	for slide in owner.get_slide_count():
		if owner.get_slide_collision(slide).normal.y == 1 and !bonked:
			bonked = true
			peak_height = owner.get_global_position().y
			hang_time = ceil(abs((previous_velocity.y + GRAVITY) / (4 * GRAVITY * HIGH_GRAVITY))) + 1
	if hang_time:
		if !animation_player.get_current_animation().begins_with("Fall"):
			var animation_name = "Fall Start " + animation_flip
			animation_player.play(animation_name)
		velocity.y = -1
		hang_time -= 1
	else:
		velocity.y = min(velocity.y + current_gravity, TERMINAL_VELOCITY)
	owner.check_for_collision_damage()
	
	if velocity.x == 0 and animation_player.get_current_animation().begins_with("Jump") \
	and animation_player.get_current_animation().find("Stationary") == -1 and !direction:
		var animation_name = "Jump " + animation_flip + " Stationary"
		seamless_transition(animation_name)

	fall_distance = abs(jump_height(peak_height)) if peak_height else 0
	if fall_distance >= MINIMUM_HEIGHT and velocity.y > 0 \
	and !(animation_player.get_current_animation() in ["Fall Right", "Fall Left"]):
		var animation_name = "Fall " + animation_flip
		animation_player.play(animation_name)

	if owner.is_on_floor():
#		print("Horizontal Distance: ", (owner.get_global_position().x - horizontal_start))
#		print("Vertical Distance at Peak: ", abs(jump_height(peak_height)))
		if damage:
			emit_signal("finished", "staggering")
		elif buffer_jump:
			emit_signal("finished", "jumping")
		elif Input.is_action_pressed("left") or Input.is_action_pressed("right"):
			emit_signal("finished", "running")
		else:
			emit_signal("finished", "idling")



func _on_direction_changed(direction):
	animation_flip = "Right" if direction == 1 else "Left"
	var animation_name = animation_player.get_assigned_animation().replace("Left", animation_flip) \
		if direction == 1 else animation_player.get_assigned_animation().replace("Right", animation_flip)
	seamless_transition(animation_name)


func _on_received_damage():
	return ._on_received_damage()


func _on_momentum_timed_out():
	momentum_buffer = false


func exit():
	momentum_timer.stop()
	.exit()