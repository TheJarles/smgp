extends Node

signal collision_damage()

func _ready():
	$Player.connect("collided", self, "_on_actor_collided")
	connect("collision_damage", $Player.get_node("PlayerStateMachine"), "_on_received_damage")
	connect("collision_damage", $Player.get_node("StatusStateMachine"), "_on_received_damage")


func _on_actor_collided(collision, actor):
	if collision.collider == $TileMap:
		var tile_position = $TileMap.world_to_map(actor.position)
		tile_position -= collision.normal * 3
		var tile = $TileMap.get_cellv(tile_position)
		if tile == 3 and actor.get_node("StatusStateMachine").current_state.get_name() != "Invulnerable":
			emit_signal("collision_damage")
#			actor.get_node("BufferTimer").stop()
#			current_state.damage = true
#			if current_state.get_name() in ["Jumping", "Falling"]:
#				current_state._on_timed_out()
#			current_state.emit_signal("finished", "staggering")
