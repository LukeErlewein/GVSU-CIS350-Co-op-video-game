class_name EnergyCell extends Area2D

@export var CHARGE_AMOUNT: int = 5
signal cell_pickup

func _on_body_entered(body: Node2D) -> void:
	if body is FighterPlayer:
		cell_pickup.emit(CHARGE_AMOUNT)
		queue_free()
