class_name BaseEnemy extends CharacterBody2D

var attack: Attack

@export var STATS: EnemyStats

var external_force := Vector2.ZERO

var current_speed := 0.0
var is_frozen := false

func _ready():
	STATS = STATS.duplicate(true)

	current_speed = STATS.speed

	if $Timer:
		$Timer.timeout.connect(unfreeze)

func action(hitbox: HitboxComponent):
	pass

# Get Node from scene tree, whether that is core or players
func set_target(stats: EnemyStats):
	# FRC is just short for FighterRangerCore cause im lazy
	var all_nodes = get_tree().get_current_scene().get_children()
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
	var shortest = global_position.distance_to(FRC[0].global_position)
	for node in FRC:
		var dist = global_position.distance_to(node.global_position)
		if dist < shortest:
			shortest = dist
			shortest_target = node
	return shortest_target

func freeze(duration: float = 5.0):
	if is_frozen:
		return
	is_frozen = true
	current_speed = 0.0
	$Timer.start(duration)

func unfreeze():
	is_frozen = false
	current_speed = STATS.speed

func apply_pull_force(direction: Vector2, strength: float):
	external_force += direction * strength
