extends "res://src/scripts/gameplayscripts/Abilities/Skill.gd"
class_name GravBomb

@export var speed: float = 100.0
@export var lifetime: float = 0.5
@export var damage: int = 0

func _init(target):
	cooldown = 1
	animation_name = "GravGrenProjectile"
	texture = preload("res://src/assets/Abilities/GravGrenIcon.png")
	super._init(target)

func cast_spell(target):
	var pct = float(target.core.currentPower) / float(target.core.MAXPOWER)
	if pct < 0.50:
		print("Not enough charge")
		return
	super.cast_spell(target)

	if target.is_multiplayer_authority():
		var facing_dir = (target.get_global_mouse_position() - target.global_position).normalized()
		var base_transform = Transform2D(facing_dir.angle(), target.global_position)
		target.rpc("gravity_grenade_shot", base_transform, animation_name, speed, lifetime)
