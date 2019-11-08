extends TileMap

signal collision_damage()

func _ready():
	var player = owner.get_node("Player")
	player.connect("collided", self, "_on_actor_collided")
	connect("collision_damage", player.get_node("PlayerStateMachine"), "_on_received_damage")


func _on_actor_collided(collision, actor):
	if collision.collider == self:
		var tile_position = world_to_map(actor.position)
		tile_position -= collision.normal * 2
		var tile = get_cellv(tile_position)
		var player_state_machine = actor.get_node("PlayerStateMachine")
		var current_state = player_state_machine.current_state
		if tile == 3 and current_state != player_state_machine.get_node("Staggering"):
			emit_signal("collision_damage")
#			actor.get_node("BufferTimer").stop()
#			current_state.damage = true
#			if current_state.get_name() in ["Jumping", "Falling"]:
#				current_state._on_timed_out()
#			current_state.emit_signal("finished", "staggering")
