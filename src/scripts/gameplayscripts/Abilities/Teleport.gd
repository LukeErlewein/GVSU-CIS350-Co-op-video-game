extends "res://src/scripts/gameplayscripts/Abilities/Skill.gd"
class_name Teleport

func _init(target):
	cooldown = 1.0
	animation_name = "Pierce"
	texture = preload("res://src/assets/Abilities/BlinkIcon.png")
	super._init(target)

func cast_spell(target):
	super.cast_spell(target)

	if target.is_multiplayer_authority():
		target.teleport_and_burst()
