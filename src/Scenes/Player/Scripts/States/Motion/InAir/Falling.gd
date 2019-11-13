extends "./InAir.gd"

onready var coyote_timer = owner.get_node("CoyoteTimer")


var fall_start = 0
var coyote_time = true
var pre_fall = 0

func _ready():
	coyote_timer.connect("timeout", self, "_on_coyote_timed_out")
	momentum_timer.connect("timeout", self, "_on_momentum_timed_out")

func enter():
	damage = false
	fall_start = owner.get_global_position().y
	fall_distance = 0
	velocity = enter_velocity
	coyote_time = true
	buffer_jump = false
	momentum_buffer = true if enter_velocity.x != 0 else false
	animation_flip = "Right" if owner.look_direction == 1 else "Left"
	animation_player.clear_queue()
	coyote_timer.start()
	var animation_name = "Jump " + animation_flip
	animation_player.play(animation_name)
	animation_player.advance(0.241)
	.enter()


func handle_input(event):
	if event.is_action_pressed("jump"):
		if coyote_time:
			coyote_timer.stop()
			emit_signal("finished", "jumping")
		else:
			buffer_jump = true
			buffer_timer.start()
	else:
		.handle_input(event)


func update(delta):
	var direction = get_input_direction()
	if direction:
		momentum_buffer = true
		update_look_direction(direction)
		velocity.x = clamp(velocity.x + (HORIZONTAL_ACCELERATION * air_drag * direction),
				-HORIZONTAL_SPEED, HORIZONTAL_SPEED)
	elif owner.look_direction == 1:
		velocity.x = max(velocity.x - (HORIZONTAL_DECELERATION * air_drag), 0)
	else:
		velocity.x = min(velocity.x + HORIZONTAL_DECELERATION, 0)
	
	if !direction and momentum_timer.get_time_left() == 0:
		momentum_timer.start()
	
	velocity = owner.move_and_slide(velocity, FLOOR)
	velocity.y = min(velocity.y + (GRAVITY * HIGH_GRAVITY), TERMINAL_VELOCITY)
	owner.check_for_collision_damage()
	fall_distance = abs(fall_start - owner.get_global_position().y)
	if fall_distance > MINIMUM_HEIGHT and !animation_player.get_current_animation().begins_with("Fall "):
		var animation_name = "Fall " + animation_flip
		animation_player.play(animation_name)
	if owner.is_on_floor():
		if damage:
			emit_signal("finished", "staggering")
		elif buffer_jump:
			emit_signal("finished", "jumping")
		elif Input.is_action_pressed("left") or Input.is_action_pressed("right"):
			emit_signal("finished", "running")
		else:
			emit_signal("finished", "idling")


func exit():
	pre_fall = 0
	coyote_timer.stop()
	momentum_timer.stop()
	.exit()


func _on_direction_changed(direction):
	if direction == 1:
		animation_flip = "Right"
	else:
		animation_flip = "Left"


func _on_coyote_timed_out():
	coyote_time = false


func _on_received_damage():
	return ._on_received_damage()


func _on_momentum_timed_out():
	momentum_buffer = false