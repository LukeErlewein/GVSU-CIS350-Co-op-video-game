class_name BaseEnemy extends CharacterBody2D

var attack: Attack

func action(hitbox: HitboxComponent):
	pass

# Get Node from scene tree, whether that is core or players
func set_target(stats):
	if stats.target == 0:
		pass
	elif stats.target == 1:
		pass
	elif stats.target == 2:
		pass
