extends "res://src/scripts/gameplayscripts/Abilities/Skill.gd"
class_name Orbital

@export var speed: float = 200.0
@export var lifetime: float = 0.5
@export var damage: int = 100

func _init(target):
	cooldown = 1
	animation_name = "OrbitalProjectile"
	texture = preload("res://src/assets/Abilities/OrbitalpointIcon.png")
	super._init(target)

func cast_spell(target):
	var pct = float(target.core.currentPower) / float(target.core.MAXPOWER)
	if pct < 0.75:
		print("Not enough charge")
		return
	super.cast_spell(target)

	if target.is_multiplayer_authority():
		var mouse_pos = target.get_global_mouse_position()
		target.rpc("orbital_strike_shot", mouse_pos, damage)
