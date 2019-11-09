extends Panel


func _ready():
	owner.get_node("Player").get_node("PlayerStateMachine").connect("state_changed", self, "_on_player_state_changed")
	owner.get_node("Player").get_node("StatusStateMachine").connect("state_changed", self, "_on_status_state_changed")

func _on_player_state_changed(current_state):
	$State.text = "State: " + current_state.get_name()

func _on_status_state_changed(current_state):
	$Status.text = "Status: " + current_state.get_name()