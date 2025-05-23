extends "res://src/scripts/gameplayscripts/Abilities/Skill.gd"

class_name Orbital
 
func _init(target):
	cooldown = 25.0
	animation_name = "Orbital"
	texture = preload("res://src/assets/Abilities/OrbitalpointIcon.png")
 
	super._init(target)
 
 
func cast_spell(target):
	super.cast_spell(target)
	target.single_shot(animation_name)
