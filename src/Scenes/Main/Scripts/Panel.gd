extends Panel


func _ready():
	owner.get_node("Player").get_node("PlayerStateMachine").connect("state_changed", self, "_on_state_changed")

func _on_state_changed(current_state):
	$State.text = "State: " + current_state.get_name()