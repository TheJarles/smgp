extends "./InAir.gd"

const JUMP_HEIGHT = 61
const JUMP_MAX_HEIGHT = 200
const HORIZONTAL_KNOCKBACK = 222

var start_height = 0
var buffer_jump = false
var current_gravity = GRAVITY
var peak_height = 0

onready var buffer_timer = owner.get_node("BufferTimer")
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
	owner.get_node("EffectsPlayer").play("Damage")
	stagger_timer.start()


func handle_input(event):
	if event.is_action_pressed("jump"):
		buffer_jump = true
		buffer_timer.start()


func update(delta):
	if owner.get_global_position().y > start_height:
		current_gravity = GRAVITY * HIGH_GRAVITY
	velocity.y = min(velocity.y + current_gravity, TERMINAL_VELOCITY)
	if velocity.y >= 0 and !peak_height:
		peak_height = owner.get_global_position().y
	velocity = owner.move_and_slide(velocity, FLOOR)
	owner.check_for_contact_damage()


func exit():
	owner.get_node("EffectsPlayer").stop()
	owner.get_node("Sprite").modulate = Color(1, 1, 1, 1)
	stagger_timer.stop()
	buffer_timer.stop()


func _on_timed_out():
	buffer_jump = false


func _on_stagger_timed_out():
	exit()
	if owner.is_on_floor() and (Input.is_action_pressed("right") or Input.is_action_pressed("left")):
		emit_signal("finished", "running")
	elif owner.is_on_floor() and buffer_jump:
		emit_signal("finished", "jumping")
	elif owner.is_on_floor():
		emit_signal("finished", "idling")
	else:
		emit_signal("finished", "falling")

