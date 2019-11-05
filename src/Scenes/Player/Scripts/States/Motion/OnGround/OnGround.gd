extends "../Motion.gd"


func handle_input(event):
	if event.is_action_pressed("jump"):
		emit_signal("finished", "jumping")
	.handle_input(event)

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
