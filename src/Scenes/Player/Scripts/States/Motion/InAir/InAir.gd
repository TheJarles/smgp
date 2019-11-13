extends "../Motion.gd"

const MINIMUM_HEIGHT = 96

export(float) var TERMINAL_VELOCITY = 48 * 100
export(float) var HIGH_GRAVITY = 1.33

onready var buffer_timer = owner.get_node("BufferTimer")
onready var momentum_timer = owner.get_node("MomentumTimer")

var fall_distance = 0
var damage = false
var air_drag = 0.9
var momentum_buffer = false
var buffer_jump = false


func enter():
	owner.get_node("StandingHitbox").set_disabled(true)
	owner.get_node("JumpingHitbox").set_disabled(false)


func exit():
	buffer_timer.stop()
	if fall_distance > 64:
		var animation_name = "Land " + animation_flip if velocity.x != 0 \
		or momentum_buffer else "Land " + animation_flip + " Stationary"
		animation_player.play(animation_name)


func _on_received_damage():
	owner.get_node("BufferTimer").stop()
	buffer_jump = false
	damage = true


func _on_timed_out():
	buffer_jump = false
