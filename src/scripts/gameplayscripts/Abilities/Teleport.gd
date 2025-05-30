extends "res://src/scripts/gameplayscripts/Abilities/Skill.gd"
class_name Teleport

func _init(target):
	cooldown = 10
	animation_name = "PierceProjectile"
	texture = preload("res://src/assets/Abilities/BlinkIcon.png")
	super._init(target)

func cast_spell(target):
	var pct = float(target.core.currentPower) / float(target.core.MAXPOWER)
	if pct < 0.75:
		print("Not enough charge")
		return
	super.cast_spell(target)

	if target.is_multiplayer_authority():
		target.teleport_and_burst()
