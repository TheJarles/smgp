extends "./InAir.gd"

const JUMP_HEIGHT = 61
const JUMP_MAX_HEIGHT = 200
const HORIZONTAL_KNOCKBACK = 222

var start_height = 0
var current_gravity = GRAVITY
var peak_height = 0

onready var stagger_timer = owner.get_node("StaggerTimer")

func _ready():
	owner.get_node("StaggerTimer").connect("timeout", self, "_on_stagger_timed_out")


func enter():
	peak_height = 0
	current_gravity = GRAVITY
	buffer_jump = false
	start_height = owner.get_global_position().y
	velocity.x = -HORIZONTAL_KNOCKBACK if owner.look_direction == 1 else HORIZONTAL_KNOCKBACK
	velocity.y = -630
	animation_flip = "Right" if owner.look_direction == 1 else "Left"
	var animation_name = "Stagger " + animation_flip
	animation_player.play(animation_name)
	stagger_timer.start()
	owner.get_node("JumpingHitbox").set_disabled(true)
	owner.get_node("StandingHitbox").set_disabled(false)


func handle_input(event):
	if event.is_action_pressed("jump"):
		buffer_jump = true
		buffer_timer.start()


func update(delta):
	if owner.get_global_position().y > start_height:
		current_gravity = GRAVITY * HIGH_GRAVITY
	velocity = owner.move_and_slide(velocity, FLOOR)
	velocity.y = min(velocity.y + current_gravity, TERMINAL_VELOCITY)
	if velocity.y >= 0 and !peak_height:
		peak_height = owner.get_global_position().y


func _on_timed_out():
	buffer_jump = false


func _on_stagger_timed_out():
	if owner.is_on_floor() and buffer_jump:
		emit_signal("finished", "jumping")
	elif owner.is_on_floor() and Input.is_action_pressed("down") and \
	(Input.is_action_pressed("right") or Input.is_action_pressed("left")):
		emit_signal("finished", "crawling")
	elif owner.is_on_floor() and Input.is_action_pressed("down"):
		emit_signal("finished", "crouching")
	elif owner.is_on_floor() and (Input.is_action_pressed("right") or Input.is_action_pressed("left")):
		emit_signal("finished", "running")
	elif owner.is_on_floor():
		emit_signal("finished", "idling")
	else:
		emit_signal("finished", "falling")
