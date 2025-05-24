class_name FighterPlayer extends CharacterBody2D

@export var SPEED: float = 55
@export var ACCELERATION: float = 5
@export var FRICTION: float = 8

@export var bullet : PackedScene
@export var projectile_node : PackedScene
@onready var muzzle: Marker2D = $Muzzle
@onready var shot_cooldown_timer: Timer = $ShotCooldownTimer
@onready var camera: Camera2D = $Camera2D
@onready var shotgun_ability = $Abilities/ShotgunAbility
@onready var grenade_ability = $Abilities/GrenadeAbility
@onready var freeze_grenade_ability = $Abilities/FreezeGrenadeAbility
@onready var orbital_strike_ability = $Abilities/OrbitalStrikeAbility
@onready var core: Node = get_tree().get_current_scene().get_node("Core")

var attack: Attack
var can_shoot: bool = true
var facing_direction := Vector2.RIGHT

func _ready() -> void:
	if is_multiplayer_authority():
		core.power_updated.connect(_on_power_updated)
		camera.make_current()
	attack = Attack.new()
	attack.attack_damage = 1.0
	attack.bullet_speed = 40.0
	attack.knockback_force = 10.0
	attack.attack_cooldown = 0.2

func _enter_tree() -> void:
	set_multiplayer_authority(int(str(name)))

func _process(delta: float) -> void:
	if !is_multiplayer_authority():
		return

	var input = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()
	var lerp_weight = delta * (ACCELERATION if input else FRICTION)
	velocity = lerp(velocity, input * SPEED, lerp_weight)
	move_and_slide()

	look_at(get_global_mouse_position())

	if Input.is_action_pressed("shoot") and can_shoot:
		shoot.rpc()

	facing_direction = (get_global_mouse_position() - global_position).normalized()

	if Input.is_action_just_pressed("ability_1") and is_multiplayer_authority():
		var proj_transform = Transform2D(facing_direction.angle(), global_position)
		single_shot.rpc(proj_transform, "Shotgun", 1)
	if Input.is_action_just_pressed("ability_2") and is_multiplayer_authority():
		grenade_ability.try_activate(self)
	if Input.is_action_just_pressed("ability_3") and is_multiplayer_authority():
		freeze_grenade_ability.try_activate(self)
	if Input.is_action_just_pressed("ability_4") and is_multiplayer_authority():
		orbital_strike_ability.try_activate(self)

@rpc("any_peer", "call_local")
func shoot():
	can_shoot = false
	var bullet_instance = bullet.instantiate()
	bullet_instance.transform = muzzle.global_transform
	bullet_instance.attack = self.attack
	get_tree().current_scene.add_child(bullet_instance)
	shot_cooldown_timer.start(attack.attack_cooldown)

func _on_shot_cooldown_timer_timeout() -> void:
	can_shoot = true

func _on_power_updated():
	var pct = float(core.currentPower) / float(core.MAXPOWER)
	if pct >= 0: shotgun_ability.unlock()
	if pct >= 0.25: grenade_ability.unlock()
	if pct >= 0.50: freeze_grenade_ability.unlock()
	if pct >= 0.75: orbital_strike_ability.unlock()

@rpc("any_peer", "call_local")
func single_shot(transform: Transform2D, animation_name = "Shotgun", damage: float = 1, speed: float = 40.0, lifetime: float = 1.5):
	var projectile = projectile_node.instantiate()
	projectile.transform = transform
	projectile.play(animation_name)

	var new_attack = self.attack.duplicate()
	new_attack.attack_damage = damage
	projectile.attack = new_attack

	projectile.speed = speed
	projectile.lifetime = lifetime
	projectile.explosion_animation = ""

	get_tree().current_scene.add_child(projectile)


@rpc("any_peer", "call_local")
func multi_shot(base_transform: Transform2D, count: int = 3, delay: float = 0.3, animation_name = "Shotgun", damage: float = 1, speed: float = 40.0, lifetime: float = 1.5):
	for i in range(count):
		var spread_angle = deg_to_rad(randf_range(-3, 3))
		var transform = base_transform.rotated(spread_angle)
		single_shot(transform, animation_name, damage, speed, lifetime)
		await get_tree().create_timer(delay).timeout

@rpc("any_peer", "call_local")
func grenade_shot(transform: Transform2D, animation_name = "Grenade", damage: float = 100, speed: float = 100.0, lifetime: float = 0.5):
	
	var grenade = projectile_node.instantiate()
	grenade.transform = transform
	grenade.play(animation_name)

	var grenade_attack = self.attack.duplicate()
	grenade_attack.attack_damage = damage  # Set to full damage for explosion
	grenade.attack = grenade_attack

	grenade.speed = speed
	grenade.lifetime = lifetime

	# Explosion logic triggered when grenade expires or hits something
	grenade.exploded.connect(func(pos):
		print("Grenade exploded signal received at ", pos)
		explode_grenade(pos, damage)
	)

	get_tree().current_scene.add_child(grenade)

func explode_grenade(position: Vector2, damage: float):
	var radius = 200.0
	print("Grenade exploded at position: ", position)
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		if enemy.global_position.distance_to(position) <= radius:
			var hc = enemy.get_node_or_null("HealthComponent")
			if hc != null:
				var temp_attack = Attack.new()
				temp_attack.attack_damage = damage
				hc.damage(temp_attack)

@rpc("any_peer", "call_local")
func freeze_grenade_shot(transform: Transform2D, animation_name = "FreezeGrenade", damage: float = 0, speed: float = 100.0, lifetime: float = 0.5):
	var grenade = projectile_node.instantiate()
	grenade.transform = transform
	grenade.play(animation_name)

	var grenade_attack = self.attack.duplicate()
	grenade_attack.attack_damage = damage
	grenade.attack = grenade_attack

	grenade.speed = speed
	grenade.lifetime = lifetime
	
	grenade.explosion_animation = "FreezeExplosion"
	
	grenade.exploded.connect(func(pos):
		print("Freeze grenade exploded signal received at ", pos)
		explode_freeze_grenade(pos)
	)

	get_tree().current_scene.add_child(grenade)

func explode_freeze_grenade(position: Vector2):
	var radius = 200.0
	print("Freeze Grenade exploded at position: ", position)
	for body in get_tree().get_nodes_in_group("Enemies"):
		print("Checking enemy: ", body.name, " distance: ", body.global_position.distance_to(position))
		if body.global_position.distance_to(position) <= radius:
			if body.has_method("freeze"):
				print("Freezing enemy: ", body.name)
				body.freeze(5.0)


@rpc("any_peer", "call_local")
func orbital_strike_shot(transform: Transform2D, animation_name = "Orbital", damage: float = 100.0, speed: float = 100.0, lifetime: float = 0.5):
	var grenade = projectile_node.instantiate()
	grenade.transform = transform
	grenade.play(animation_name)

	var grenade_attack = self.attack.duplicate()
	grenade_attack.attack_damage = damage
	grenade.attack = grenade_attack

	grenade.speed = speed
	grenade.lifetime = lifetime
	grenade.explosion_animation = "Explosion"

	# Connect the multi-blast orbital sequence when grenade explodes
	grenade.exploded.connect(func(pos):
		orbital_explode_sequence(pos, damage)
	)

	get_tree().current_scene.add_child(grenade)

func orbital_explode_sequence(position: Vector2, damage: float):
	var radius = 200.0
	var explosion_count = 5
	var delay_between = 2.0

	var explosion_effect_scene := preload("res://src/scenes/gameplayscenes/explosion_effect.tscn")

	print("Orbital Strike incoming at: ", position)

	for i in range(explosion_count):
		# 1. Visual Effect
		var effect = explosion_effect_scene.instantiate()
		effect.global_position = position
		get_tree().current_scene.add_child(effect)

		# 2. Apply Damage
		print("Orbital explosion ", i + 1, " at ", position)
		for enemy in get_tree().get_nodes_in_group("Enemies"):
			if enemy.global_position.distance_to(position) <= radius:
				var hc = enemy.get_node_or_null("HealthComponent")
				if hc != null:
					var temp_attack = Attack.new()
					temp_attack.attack_damage = damage
					hc.damage(temp_attack)

		# 3. Wait before next explosion
		await get_tree().create_timer(delay_between).timeout
