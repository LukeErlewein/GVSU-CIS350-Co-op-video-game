extends "res://src/scripts/gameplayscripts/Abilities/Skill.gd"
class_name Dash

func _init(target):
	cooldown = 1.0
	animation_name = "Dash"
	texture = preload("res://src/assets/Abilities/DashIcon.png")
	super._init(target)

func cast_spell(target):
	super.cast_spell(target)

	if target.is_multiplayer_authority():
		target.start_dash()
