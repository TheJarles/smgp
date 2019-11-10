extends Panel


func _ready():
	var player_state_machine = owner.get_node("Player").get_node("PlayerStateMachine")
	var status_state_machine = owner.get_node("Player").get_node("StatusStateMachine")
	var animation_player = owner.get_node("Player").get_node("AnimationPlayer")
	animation_player.connect("animation_started", self, "_on_animation_started")
	player_state_machine.connect("state_changed", self, "_on_player_state_changed")
	status_state_machine.connect("state_changed", self, "_on_status_state_changed")
	$State.text = "State: " + player_state_machine.current_state.get_name()
	$Status.text = "Status: " + status_state_machine.current_state.get_name()
	$Animation.text = "Animation: " + animation_player.get_current_animation()

func _on_player_state_changed(current_state):
	$State.text = "State: " + current_state.get_name()

func _on_status_state_changed(current_state):
	$Status.text = "Status: " + current_state.get_name()

func _on_animation_started(animation):
	$Animation.text = "Animation: " + animation