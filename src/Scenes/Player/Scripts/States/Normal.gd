extends "./State.gd"

func _on_received_damage():
	emit_signal("finished", "invulnerable")
