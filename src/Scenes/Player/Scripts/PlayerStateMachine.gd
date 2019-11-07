extends "./StateMachine.gd"

# Helper map for checking current state
var state_names = {}

func _ready():
	states_map = {
		"idling": $Idling,
		"running": $Running,
		"jumping": $Jumping,
		"staggering": $Staggering,
		"falling": $Falling,
	}
	state_names = {
		$Idling: "idling",
		$Running: "running",
		$Jumping: "jumping",
		$Staggering: "staggering",
		$Falling: "falling",
	}
	owner.get_node("AnimationPlayer").connect("animation_finished", self, "_on_animation_finished")
	owner.get_node("AnimationPlayer").set_animation_process_mode(0)
	owner.get_node("Timer").connect("timeout", self, "_on_timed_out")


func _change_state(state_name):
	if not _active:
		return
	if state_name in ["staggering", "jumping", "falling"]:
		states_stack.push_front(states_map[state_name])
	if !(state_name in ["staggering", "previous"]):
		states_map[state_name].initialize(current_state.velocity)
	._change_state(state_name)
	print("Entering State: ", state_names[states_stack[0]])
	print("Current Animation: ", owner.get_node("AnimationPlayer").get_current_animation())
	print("Animation Queue: ", owner.get_node("AnimationPlayer").get_queue())

func _on_direction_changed(direction):
	current_state._on_direction_changed(direction)

func _on_timed_out():
	if current_state in [$Falling, $Jumping]:
		current_state._on_timed_out()