extends "res://src/scripts/gameplayscripts/Abilities/Skill.gd"

class_name Shotgun
@export var speed: int = 1000
@export var lifetime: float = 0.2
@export var num_of_shots: int = 7
@export var delay: float = 0.0005
@export var damage: float = 15.0

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
		target.rpc("multi_shot", base_transform, num_of_shots, delay, animation_name, damage, speed, lifetime)
