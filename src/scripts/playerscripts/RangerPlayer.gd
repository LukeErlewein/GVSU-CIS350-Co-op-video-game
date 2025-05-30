class_name RangerPlayer
extends CharacterBody2D

# Movement stats
@export var SPEED: float = 65
@export var ACCELERATION: float = 5
@export var FRICTION: float = 8

# Bullet & projectile references
@export var bullet: PackedScene
@export var projectile_node: PackedScene

# Nodes
@onready var muzzle: Marker2D = $Muzzle
@onready var shot_cooldown_timer: Timer = $ShotCooldownTimer
@onready var camera: Camera2D = $Camera2D
@onready var ranger_ui: CanvasLayer = $RangerUI
@onready var core: Node = get_tree().get_current_scene().get_node("Core")

# State
var attack: Attack
var can_shoot: bool = true
var facing_direction := Vector2.RIGHT
var is_dashing: bool = false
var dash_timer: Timer
var original_speed: float

func _enter_tree() -> void:
	set_multiplayer_authority(int(str(name)))

func _ready() -> void:
	if is_multiplayer_authority():
		camera.make_current()
		ranger_ui.show()
	else:
		ranger_ui.hide()

	setup_attack()

func setup_attack() -> void:
	attack = Attack.new()
	attack.attack_damage = 90
	attack.hurt_cell_holders = true
	attack.bullet_speed = 200.0
	attack.knockback_force = 15.0
	attack.attack_cooldown = 0.4

func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return

	var input = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()

	var lerp_weight = delta * (ACCELERATION if input else FRICTION)
	velocity = lerp(velocity, input * SPEED, lerp_weight)
	move_and_slide()
	
	look_at(get_global_mouse_position())
	facing_direction = (get_global_mouse_position() - global_position).normalized()
	
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot.rpc()
	
	update_ability_ui_visibility()

@rpc("call_local")
func shoot():
	can_shoot = false
	var bullet_instance = bullet.instantiate()
	bullet_instance.transform = muzzle.global_transform
	bullet_instance.attack = attack
	get_parent().add_child(bullet_instance)
	shot_cooldown_timer.start(attack.attack_cooldown)

func _on_shot_cooldown_timer_timeout() -> void:
	can_shoot = true

@rpc("any_peer", "call_local")
func single_shot(transform: Transform2D, animation_name := "SprayBullets", damage := 1.0, speed := 40.0, lifetime := 1.5):
	var projectile = projectile_node.instantiate()
	projectile.transform = transform
	projectile.play(animation_name)

	var new_attack = attack.duplicate()
	new_attack.attack_damage = damage
	projectile.attack = new_attack
	projectile.speed = speed
	projectile.lifetime = lifetime

	if animation_name == "PierceProjectile":
		projectile.is_piercing = true

	get_tree().current_scene.add_child(projectile)


func start_dash():
	if is_dashing:
		return

	is_dashing = true
	original_speed = SPEED
	SPEED *= 6.0

	dash_timer = Timer.new()
	dash_timer.wait_time = 1.0
	dash_timer.one_shot = true
	dash_timer.timeout.connect(_end_dash)
	add_child(dash_timer)
	dash_timer.start()

func _end_dash():
	SPEED = original_speed
	is_dashing = false
	dash_timer.queue_free()


func angled_shot(angle: float, _unused = 0):
	var projectile = projectile_node.instantiate()
	projectile.position = global_position
	projectile.rotation = angle

	var radial_attack = attack.duplicate()
	radial_attack.attack_damage = 75.0
	projectile.attack = radial_attack

	projectile.speed = 200
	projectile.lifetime = 1
	projectile.explosion_animation = ""

	projectile.play("PierceProjectile")

	get_tree().current_scene.call_deferred("add_child", projectile)

func radial_burst(count: int = 12):
	for i in range(count):
		var angle = (float(i) / count) * TAU
		angled_shot(angle)

func teleport_and_burst():
	global_position = get_global_mouse_position()
	radial_burst(18)

@rpc("any_peer", "call_local")
func gravity_grenade_shot(transform: Transform2D, animation_name := "GravGrenProjectile", speed := 100.0, lifetime := 0.5):
	var grenade = projectile_node.instantiate()
	grenade.transform = transform
	grenade.play(animation_name)

	var grenade_attack = attack.duplicate()
	grenade_attack.attack_damage = 0
	grenade.attack = grenade_attack

	grenade.speed = speed
	grenade.lifetime = lifetime
	grenade.explosion_animation = "GravGrenExplosion"

	grenade.exploded.connect(func(pos: Vector2) -> void:
		pull_enemies_to_point(pos, 200.0)
	)

	get_tree().current_scene.add_child(grenade)


func pull_enemies_to_point(center: Vector2, radius: float):
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		if enemy.global_position.distance_to(center) <= radius:
			if enemy.has_method("apply_pull_force"):
				var direction = (center - enemy.global_position).normalized()
				enemy.apply_pull_force(direction, 600)

func update_ability_ui_visibility():
	if !core: return
	
	var pct = float(core.currentPower) / float(core.MAXPOWER)

	$RangerUI/SkillBar/SpellButton.visible = pct >= 0.0
	$RangerUI/SkillBar/SpellButton2.visible = pct >= 0.25
	$RangerUI/SkillBar/SpellButton3.visible = pct >= 0.5
	$RangerUI/SkillBar/SpellButton4.visible = pct >= 0.75
