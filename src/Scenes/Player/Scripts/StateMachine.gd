extends Node

signal state_changed(current_state)


export(NodePath) var START_STATE
var states_map = {}
var current_state = null
var _active = true setget set_active


func _ready():
	for child in get_children():
		child.connect("finished", self, "_change_state")
	initialize(START_STATE)


func initialize(start_state):
	set_active(true)
	current_state = get_node(start_state)
	current_state.enter()


func set_active(value):
	_active = value
	set_physics_process(value)
	set_process_input(value)
	if not _active:
		current_state = null


func _input(event):
	current_state.handle_input(event)


func _physics_process(delta):
	current_state.update(delta)


func _on_animation_finished(animation):
	if not _active:
		return
	current_state._on_animation_finished(animation)


func _change_state(state_name):
	if not _active:
		return
	current_state.exit()
	current_state = states_map[state_name]
	emit_signal("state_changed", current_state)
	current_state.enter()
