extends Area2D

@export var DAMAGE: int = 10

func _process(delta):
	global_position = get_global_mouse_position()
