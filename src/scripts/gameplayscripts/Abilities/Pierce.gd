extends "res://src/scripts/gameplayscripts/Abilities/Skill.gd"
class_name Pierce

@export var speed: float = 500.0
@export var lifetime: float = 10.0
@export var damage: int = 100.0

func _init(target):
	cooldown = 1
	animation_name = "PierceProjectile"
	texture = preload("res://src/assets/Abilities/PierceIcon.png")
	super._init(target)

func cast_spell(target):
	super.cast_spell(target)

	if target.is_multiplayer_authority():
		var facing_dir = (target.get_global_mouse_position() - target.global_position).normalized()
		var base_transform = Transform2D(facing_dir.angle(), target.global_position)
		target.rpc("single_shot", base_transform, animation_name, damage, speed, lifetime)
