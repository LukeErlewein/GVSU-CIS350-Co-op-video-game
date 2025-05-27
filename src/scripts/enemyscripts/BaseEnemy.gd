class_name BaseEnemy extends CharacterBody2D

var attack: Attack
@export var STATS : EnemyStats
var external_force := Vector2.ZERO


func action(hitbox: HitboxComponent):
	pass

# Get Node from scene tree, whether that is core or players
func set_target(stats: EnemyStats):
	# FRC is just short for FighterRangerCore cause im lazy
	var all_nodes = get_parent().get_children()
	var FRC = []
	
	# Check target and do proper search
	if stats.target == "PLAYERS":
		for child in all_nodes:
			if child is RangerPlayer or child is FighterPlayer:
				FRC.append(child)
		return _shortest_target(FRC)
	elif stats.target == "CORE":
		for child in all_nodes:
			if child is Core:
				return child
	elif stats.target == "ALL":
		for child in all_nodes:
			if child is RangerPlayer or child is FighterPlayer or child is Core:
				FRC.append(child)
		return _shortest_target(FRC)

func _shortest_target(FRC: Array):
	if FRC.is_empty():
		return null
	var shortest_target = FRC[0]
	var shortest: float = global_position.distance_to(FRC[0].global_position)
	for node in FRC:
		if global_position.distance_to(node.global_position) < shortest:
			shortest = global_position.distance_to(node.global_position)
			shortest_target = node
	return shortest_target

var original_speed = 50.0
var is_frozen = false

func freeze(duration: float = 5.0):
	if is_frozen:
		return
	is_frozen = true
	original_speed = STATS.speed
	STATS.speed = 0.0
	$Timer.start(duration)

func unfreeze():
	is_frozen = false
	STATS.speed = original_speed
	
func apply_pull_force(direction: Vector2, strength: float):
	external_force += direction * strength
