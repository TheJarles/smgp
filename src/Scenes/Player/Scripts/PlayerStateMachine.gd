extends "./StateMachine.gd"


func _ready():
	states_map = {
		"idling": $Idling,
		"running": $Running,
		"jumping": $Jumping,
		"staggering": $Staggering,
		"falling": $Falling,
	}
	owner.connect("direction_changed", self, "_on_direction_changed")
	owner.get_node("AnimationPlayer").connect("animation_finished", self, "_on_animation_finished")
	owner.get_node("AnimationPlayer").set_animation_process_mode(0)
	owner.get_node("BufferTimer").connect("timeout", self, "_on_timed_out")


func _change_state(state_name):
	if not _active:
		return
	if current_state == $Staggering and state_name == "falling":
		$Falling.fall_start = $Staggering.peak_height
	if state_name != "staggering":
		states_map[state_name].initialize(current_state.velocity)
	._change_state(state_name)


func _on_direction_changed(direction):
	current_state._on_direction_changed(direction)


func _on_timed_out():
	if current_state in [$Falling, $Jumping, $Staggering]:
		current_state._on_timed_out()


func _on_received_damage():
	current_state._on_received_damage()
