extends "../State.gd"

const FLOOR = Vector2(0, -1)

export(float) var HORIZONTAL_SPEED = 375
export(float) var HORIZONTAL_ACCELERATION = HORIZONTAL_SPEED / 6
export(float) var HORIZONTAL_DECELERATION = HORIZONTAL_SPEED / 4
export(float) var GRAVITY = 65

var enter_velocity = Vector2()
var velocity = Vector2()
var animation_flip = ""


onready var animation_player = owner.get_node("AnimationPlayer")


func initialize(init_velocity):
	enter_velocity = init_velocity


func get_input_direction():
	var input_direction = 0
	var left = int(Input.is_action_pressed("left"))
	var right = int(Input.is_action_pressed("right"))
	input_direction = right - left
	if left and right:
		if owner.previous_direction != 2:
			input_direction = owner.look_direction * -1
			owner.previous_direction = 2
		else:
			input_direction = owner.look_direction
	else:
		owner.previous_direction = owner.look_direction
	return input_direction


func seamless_transition(animation_name):
	var pos = animation_player.get_current_animation_position()
	animation_player.play(animation_name)
	animation_player.advance(pos)


func update_look_direction(direction):
	if abs(direction - owner.look_direction) == 2:
		owner.set_look_direction(owner.look_direction * -1)
		if owner.look_direction == -1:
			owner.get_node("Sprite").set_flip_h(true)
		else:
			owner.get_node("Sprite").set_flip_h(false)
