extends "res://src/scripts/gameplayscripts/Abilities/Skill.gd"

class_name Shotgun
@export var speed: int = 800
@export var lifetime: float = 0.4
@export var damage: float = 50.0

func _init(target):
	cooldown = 1
	animation_name = "SprayBullets"
	texture = preload("res://src/assets/Abilities/SprayBulletsIcon.png")
	super._init(target)

func cast_spell(target):
	super.cast_spell(target)

	if target.is_multiplayer_authority():
		var facing_dir = (target.get_global_mouse_position() - target.global_position).normalized()
		var base_transform = Transform2D(facing_dir.angle(), target.global_position)
		target.rpc("shotgun_blast", base_transform, animation_name, damage, speed, lifetime)
