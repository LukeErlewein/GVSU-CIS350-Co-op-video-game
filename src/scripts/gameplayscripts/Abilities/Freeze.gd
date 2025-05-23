extends "res://src/scripts/gameplayscripts/Abilities/Skill.gd"

class_name Freeze
 

func _init(target):
	cooldown = 10.0
	animation_name = "Freeze"
	texture = preload("res://src/assets/Abilities/FreezeProjectileIcon.png")
 
	super._init(target)
 
 
func cast_spell(target):
	super.cast_spell(target)
	target.single_shot(animation_name)
