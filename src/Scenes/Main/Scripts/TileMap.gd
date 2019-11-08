extends TileMap


func _ready():
	owner.get_node("Player").connect("collided", self, "_on_actor_collided")


func _on_actor_collided(collision, actor):
	if collision.collider == self:
		var tile_position = world_to_map(actor.position)
		tile_position -= collision.normal * 2
		var tile = get_cellv(tile_position)
		var player_state_machine = actor.get_node("PlayerStateMachine")
		var current_state = player_state_machine.current_state
		if tile == 3 and current_state != player_state_machine.get_node("Staggering"):
#			print(actor.get_node("PlayerStateMachine").state_names)
#			print("Current State Node: ", actor.get_node("PlayerStateMachine").current_state)
#			print("Current State: ", actor.get_node("PlayerStateMachine").current_state_to_string())
#			print("Entering stagger state")
			actor.get_node("BufferTimer").stop()
			current_state.damage = true
			if current_state.get_name() in ["Jumping", "Falling"]:
				current_state._on_timed_out()
			current_state.emit_signal("finished", "staggering")
#			print("Current State: ", actor.get_node("PlayerStateMachine").current_state_to_string())
