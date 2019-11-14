extends "../Motion.gd"


func enter():
	owner.get_node("JumpingHitbox").set_disabled(true)
	owner.get_node("StandingHitbox").set_disabled(false)


func handle_input(event):
	if event.is_action_pressed("jump"):
		if !animation_player.get_current_animation().begins_with("Slam") or \
		animation_player.get_current_animation_position() > 0.36:
			emit_signal("finished", "jumping")
		else:
			owner.get_node("BufferTimer").start()
	if event.is_action_pressed("down"):
		emit_signal("finished", "crouching")


func update(delta):
	if !owner.is_on_floor():
		emit_signal("finished", "falling")


func _on_direction_changed(direction):
	if direction == 1:
		animation_flip = "Right"
		animation_player.play("Turn Right")
	else:
		animation_flip = "Left"
		animation_player.play("Turn Left")


func _on_timed_out():
	if !animation_player.get_current_animation().begins_with("Slam") or \
		animation_player.get_current_animation_position() > 0.42:
		emit_signal("finished", "jumping")
