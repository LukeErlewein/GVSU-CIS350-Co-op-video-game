extends Area2D

signal cellCharge


func _on_body_entered(body: Node2D) -> void:
	if body is FighterPlayer:
		cellCharge.emit() # this is to no one just yet
		queue_free()
