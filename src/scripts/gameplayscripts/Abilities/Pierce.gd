extends "res://src/scripts/gameplayscripts/Abilities/Skill.gd"
class_name Pierce

func _init(target):
	cooldown = 3.0
	animation_name = "Pierce"
	texture = preload("res://src/assets/Abilities/PierceIcon.png")
	super._init(target)

func cast_spell(target):
	super.cast_spell(target)

	if target.is_multiplayer_authority():
		var facing_dir = (target.get_global_mouse_position() - target.global_position).normalized()
		var base_transform = Transform2D(facing_dir.angle(), target.global_position)
		var speed = 500
		var lifetime = 10
		var damage = 10
		target.rpc("single_shot", base_transform, animation_name, damage, speed, lifetime)
