extends "res://src/scripts/gameplayscripts/Abilities/Skill.gd"
class_name Freeze

func _init(target):
	cooldown = 1.0
	animation_name = "Freeze"
	texture = preload("res://src/assets/Abilities/FreezeProjectileIcon.png")
	super._init(target)

func cast_spell(target):
	super.cast_spell(target)

	if target.is_multiplayer_authority():
		var facing_dir = (target.get_global_mouse_position() - target.global_position).normalized()
		var base_transform = Transform2D(facing_dir.angle(), target.global_position)
		var speed = 100
		var lifetime = 0.5
		var damage = 0
		target.rpc("freeze_grenade_shot", base_transform, animation_name, damage, speed, lifetime)
