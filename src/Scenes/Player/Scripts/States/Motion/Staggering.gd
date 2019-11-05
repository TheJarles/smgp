extends "./Motion.gd"

func enter():
	var animation_flip = "Right" if owner.look_direction == 1 else "Left"
	var animation_name = "Stagger " + animation_flip
	owner.get_node("AnimationPlayer").play(animation_name)

func _on_animation_finished(animation):
	print("Animation Finished")
	emit_signal("finished", "previous")
