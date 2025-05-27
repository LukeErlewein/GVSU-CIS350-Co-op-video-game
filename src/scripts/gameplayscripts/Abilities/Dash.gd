extends "res://src/scripts/gameplayscripts/Abilities/Skill.gd"
class_name Dash

func _init(target):
	cooldown = 1
	animation_name = "Dash"
	texture = preload("res://src/assets/Abilities/DashIcon.png")
	super._init(target)

func cast_spell(target):
	var pct = float(target.core.currentPower) / float(target.core.MAXPOWER)
	if pct < 0.25:
		print("Not enough charge")
		return
	super.cast_spell(target)

	if target.is_multiplayer_authority():
		target.start_dash()
