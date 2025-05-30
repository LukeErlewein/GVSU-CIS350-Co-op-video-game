class_name HealthComponent extends Node2D

@export var MAX_HEALTH := 100.0
var health : float


func _ready() -> void:
	health = MAX_HEALTH


func damage(attack: Attack) -> void:
	if get_parent() is not CellCarrier:
		health -= attack.attack_damage
	
	if get_parent() is CellCarrier and attack.hurt_cell_holders:
		health -= attack.attack_damage
	
	if health <= 0:
		get_parent().queue_free()
