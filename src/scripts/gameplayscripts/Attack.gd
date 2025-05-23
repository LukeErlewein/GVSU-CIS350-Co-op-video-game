class_name Attack

var attack_damage: float = 10.0
var knockback_force: float = 100.0
var bullet_speed: float = 40.0
var hurt_cell_holders: bool = false
var attack_cooldown: float = 0.5 # time between attacks

func duplicate() -> Attack:
	var copy = Attack.new()
	copy.attack_damage = attack_damage
	copy.bullet_speed = bullet_speed
	copy.knockback_force = knockback_force
	copy.attack_cooldown = attack_cooldown
	return copy
