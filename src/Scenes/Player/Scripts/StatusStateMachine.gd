extends "./StateMachine.gd"


func _ready():
	states_map = {
		"invulnerable": $Invulnerable,
		"normal": $Normal,
	}


func _on_received_damage():
	current_state._on_received_damage()
