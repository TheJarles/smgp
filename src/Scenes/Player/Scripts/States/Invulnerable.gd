extends "./State.gd"

func _ready():
	owner.get_node("InvTimer").connect("timeout", self, "_on_timed_out")


func enter(): 
	owner.get_node("EffectsPlayer").play("Damage")
	owner.get_node("InvTimer").start()


func exit():
	owner.get_node("EffectsPlayer").stop()
	owner.get_node("Sprite").modulate = Color(1, 1, 1, 1)


func _on_timed_out():
	emit_signal("finished", "normal")
