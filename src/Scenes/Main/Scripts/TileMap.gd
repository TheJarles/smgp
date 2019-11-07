extends TileMap

func _ready():
	owner.get_node("Player").connect("collided", self, "_on_actor_collided")


func _on_actor_collided(collision, actor):
	if collision.collider == self:
		var tile_position = world_to_map(actor.position)
		print(tile_position)
