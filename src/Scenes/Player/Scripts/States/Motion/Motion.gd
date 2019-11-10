extends "../State.gd"

const FLOOR = Vector2(0, -1)

export(float) var HORIZONTAL_SPEED = 407
export(float) var HORIZONTAL_ACCELERATION = HORIZONTAL_SPEED / 3
export(float) var GRAVITY = 50

var enter_velocity = Vector2()
var velocity = Vector2()
var animation_flip = ""

onready var animation_player = owner.get_node("AnimationPlayer")


func initialize(init_velocity):
	enter_velocity = init_velocity


func get_input_direction():
	var input_direction = 0
	input_direction = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	return input_direction


func seamless_transition(animation_name):
	var pos = animation_player.get_current_animation_position()
	animation_player.play(animation_name)
	animation_player.advance(pos)


func update_look_direction(direction):
	if abs(direction - owner.look_direction) == 2:
		owner.set_look_direction(direction)
		if direction == -1:
			owner.get_node("Sprite").set_flip_h(true)
		else:
			owner.get_node("Sprite").set_flip_h(false)
