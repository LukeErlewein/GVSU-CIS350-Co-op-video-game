class_name RangerPlayer extends CharacterBody2D

@export var SPEED: float = 55
@export var ACCELERATION: float = 5
@export var FRICTION: float = 8

@export var bullet : PackedScene
@export var projectile_node : PackedScene
@onready var muzzle: Marker2D = $Muzzle
@onready var shot_cooldown_timer: Timer = $ShotCooldownTimer
@onready var camera: Camera2D = $Camera2D
@onready var pierce_ability = $Abilities/PierceAbility
@onready var dash_ability = $Abilities/DashAbility
@onready var grav_grenade_ability = $Abilities/GravGrenadeAbility
@onready var teleport_ability = $Abilities/TeleportAbility

var attack: Attack
var can_shoot: bool = true
var facing_direction := Vector2.RIGHT
var is_dashing: bool = false
var dash_timer: Timer
var original_speed: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_multiplayer_authority(): camera.make_current()
	attack = Attack.new()
	attack.attack_damage = 3.0
	attack.hurt_cell_holders = true
	attack.bullet_speed = 50.0
	attack.knockback_force = 15.0
	attack.attack_cooldown = 0.6

func _enter_tree() -> void:
	set_multiplayer_authority(int(str(name)))
	
func _process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
	
	# Get direction of movement
	var input = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()
	# get ACCELERATION or FRICTION depending on input
	var lerp_weight = delta * (ACCELERATION if input else FRICTION)
	# apply to character velocity
	velocity = lerp(velocity, input * SPEED, lerp_weight)
	# apply movement
	move_and_slide()
	# Rotate player towards mouse
	look_at(get_global_mouse_position())
	
	facing_direction = (get_global_mouse_position() - global_position).normalized()
	
	# Handle Shooting
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot.rpc()
	
	if Input.is_action_just_pressed("ability_1") and is_multiplayer_authority():
		var proj_transform = Transform2D(facing_direction.angle(), global_position)
		single_shot.rpc(proj_transform, "Pierce", 1)
	if Input.is_action_just_pressed("ability_2") and is_multiplayer_authority():
		dash_ability.try_activate(self)
	if Input.is_action_just_pressed("ability_3") and is_multiplayer_authority():
		grav_grenade_ability.try_activate(self)
	if Input.is_action_just_pressed("ability_4") and is_multiplayer_authority():
		teleport_ability.try_activate(self)

@rpc("call_local")
func shoot():
	can_shoot = false
	var bullet_instance = bullet.instantiate()
	bullet_instance.transform = muzzle.global_transform
	bullet_instance.attack = self.attack
	get_parent().add_child(bullet_instance)
	shot_cooldown_timer.start(attack.attack_cooldown)
	

func _on_shot_cooldown_timer_timeout() -> void:
	can_shoot = true

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
	
	if animation_name == "Pierce":
		projectile.is_piercing = true

	get_tree().current_scene.add_child(projectile)
	
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

func start_dash():
	if is_dashing:
		return

	is_dashing = true
	original_speed = SPEED
	SPEED *= 2.0  # Dash speed multiplier

	# Create and start the timer
	dash_timer = Timer.new()
	dash_timer.wait_time = 5.0
	dash_timer.one_shot = true
	dash_timer.timeout.connect(_end_dash)
	add_child(dash_timer)
	dash_timer.start()

func _end_dash():
	SPEED = original_speed
	is_dashing = false
	dash_timer.queue_free()

func angled_shot(angle: float, i: int):
	var projectile = projectile_node.instantiate()

	# Spawn at player position
	projectile.position = global_position
	projectile.rotation = angle

	# Setup attack details
	var radial_attack = attack.duplicate()
	radial_attack.attack_damage = 5.0
	projectile.attack = radial_attack
	
	projectile.speed = 80
	projectile.lifetime = 1.5
	projectile.explosion_animation = ""
	# Add to scene
	get_tree().current_scene.call_deferred("add_child", projectile)


func radial_burst(count: int = 12):
	for i in range(count):
		var angle = (float(i) / count) * TAU
		angled_shot(angle, i)
		
func teleport_and_burst():
	global_position = get_global_mouse_position()
	radial_burst(12)


@rpc("any_peer", "call_local")
func gravity_grenade_shot(transform: Transform2D, animation_name = "GravGrenade", speed: float = 100.0, lifetime: float = 0.5):
	var grenade = projectile_node.instantiate()
	grenade.transform = transform
	grenade.play(animation_name)

	var grenade_attack = self.attack.duplicate()
	grenade_attack.attack_damage = 0
	grenade.attack = grenade_attack

	grenade.speed = speed
	grenade.lifetime = lifetime
	grenade.explosion_animation = "GravExplosion"
	
	grenade.exploded.connect(func(pos: Vector2) -> void:
		print("Gravity grenade exploded at ", pos)
		pull_enemies_to_point(pos, 200.0)
	)

	get_tree().current_scene.call_deferred("add_child", grenade)


func pull_enemies_to_point(center: Vector2, radius: float):
	print("Grenade exploded at position: ", position)
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		if enemy.global_position.distance_to(position) <= radius:
			var direction = (position - enemy.global_position).normalized()
			if enemy.has_method("apply_pull_force"):
				enemy.apply_pull_force(direction, 300)
