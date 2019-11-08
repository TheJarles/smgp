extends TileMap


func _ready():
	owner.get_node("Player").connect("collided", self, "_on_actor_collided")


func _on_actor_collided(collision, actor):
	if collision.collider == self:
		var tile_position = world_to_map(actor.position)
		print(tile_position)
		print(collision.normal)
		tile_position -= collision.normal * 2
		var tile = get_cellv(tile_position)
		if tile == 3 and actor.get_node("StateMachine").current_state != actor.get_node("Staggering"):
			actor.get_node("StateMachine")._change_state("staggering")
			print(actor.get_node("StateMachine").state_names[actor.get_node("StateMachine").current_state])
