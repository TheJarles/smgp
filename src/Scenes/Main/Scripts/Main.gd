extends Node

func _ready():
	$Player.get_node("Camera2D").set_offset(Vector2(- 1600 / 2, - 900 / 2))
	pass
