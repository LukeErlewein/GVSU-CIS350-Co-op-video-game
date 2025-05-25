extends "res://src/scripts/gameplayscripts/Abilities/Skill.gd"

class_name Shotgun

func _init(target):
	cooldown = 3.0
	animation_name = "Shotgun"
	texture = preload("res://src/assets/Abilities/SprayBulletsIcon.png")
	super._init(target)

func cast_spell(target):
	super.cast_spell(target)

	if target.is_multiplayer_authority():
		var facing_dir = (target.get_global_mouse_position() - target.global_position).normalized()
		var base_transform = Transform2D(facing_dir.angle(), target.global_position)
		var speed = 1000
		var lifetime = 0.2
		var num_of_shots = 7
		var delay = 0.0005
		var damage = 1
		target.rpc("multi_shot", base_transform, num_of_shots, delay, animation_name, damage, speed, lifetime)
