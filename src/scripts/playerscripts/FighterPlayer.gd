class_name FighterPlayer extends CharacterBody2D

@export var SPEED: float = 55
@export var ACCELERATION: float = 5
@export var FRICTION: float = 8

@export var bullet : PackedScene
@export var projectile_node : PackedScene
@onready var muzzle: Marker2D = $Muzzle
@onready var shot_cooldown_timer: Timer = $ShotCooldownTimer
@onready var camera: Camera2D = $Camera2D
@onready var core: Node = get_tree().get_current_scene().get_node("Core")
@onready var wait_screen: Control = $FighterUI/WaitScreen
@onready var gunshot: AudioStreamPlayer2D = $Gunshot

var attack: Attack
var can_shoot: bool = true
var can_control: bool = false

func _ready() -> void:
	get_tree().get_current_scene().game_start.connect(hide_UI)
	wait_screen.show()
	print("core assigned: ", core)
	if is_multiplayer_authority():
		camera.make_current()
		if has_node("FighterUI"):
			$FighterUI.show()
	else:
		if has_node("FighterUI"):
			$FighterUI.hide()

	attack = Attack.new()
	attack.attack_damage = 50
	attack.bullet_speed = 130.0
	attack.knockback_force = 10.0
	attack.attack_cooldown = 0.15

func _enter_tree() -> void:
	set_multiplayer_authority(int(str(name)))

func _process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
	if !can_control:
		if Global.GAME_RUNNING:
			hide_UI()
		else:
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
		rpc("shoot")
	
	update_ability_ui_visibility()

func hide_UI():
	wait_screen.hide()
	can_control = true


@rpc("any_peer", "call_local")
func shoot():
	can_shoot = false
	var bullet_instance = bullet.instantiate()
	bullet_instance.transform = muzzle.global_transform
	bullet_instance.attack = self.attack
	get_tree().current_scene.add_child(bullet_instance)
	gunshot.play()
	shot_cooldown_timer.start(attack.attack_cooldown)

func _on_shot_cooldown_timer_timeout() -> void:
	can_shoot = true

@rpc("any_peer", "call_local")
func single_shot(transform: Transform2D, animation_name = "SprayBullets", damage: float = 1, speed: float = 40.0, lifetime: float = 1.5):
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
func multi_shot(base_transform: Transform2D, count: int = 3, delay: float = 0.3, animation_name = "SprayBullets", damage: float = 1, speed: float = 40.0, lifetime: float = 1.5):
	for i in range(count):
		var spread_angle = deg_to_rad(randf_range(-3, 3))
		var transform = base_transform.rotated(spread_angle)
		single_shot(transform, animation_name, damage, speed, lifetime)
		await get_tree().create_timer(delay).timeout

@rpc("any_peer", "call_local")
func grenade_shot(transform: Transform2D, animation_name = "GrenadeProjectile", damage: float = 100, speed: float = 100.0, lifetime: float = 0.5):
	var grenade = projectile_node.instantiate()
	grenade.transform = transform
	grenade.play(animation_name)

	var grenade_attack = self.attack.duplicate()
	grenade_attack.attack_damage = damage
	grenade.attack = grenade_attack

	grenade.speed = speed
	grenade.lifetime = lifetime

	grenade.exploded.connect(func(pos):
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
func freeze_grenade_shot(transform: Transform2D, animation_name = "FreezeProjectile", damage: float = 0, speed: float = 200.0, lifetime: float = 1):
	var grenade = projectile_node.instantiate()
	grenade.transform = transform
	grenade.play(animation_name)
	grenade.speed = speed
	grenade.lifetime = lifetime
	grenade.explosion_animation = "FreezeExplosion"
	
	grenade.exploded.connect(func(pos):
		explode_freeze_grenade(pos)
	)

	get_tree().current_scene.add_child(grenade)

func explode_freeze_grenade(position: Vector2):
	var radius = 200.0
	var freeze_duration = 5.0

	print("Freeze Grenade exploded at position: ", position)

	var freeze_effect_scene := preload("res://src/scenes/gameplayscenes/FreezeMarker.tscn")
	var freeze_effect = freeze_effect_scene.instantiate()
	freeze_effect.global_position = position
	freeze_effect.modulate.a = 0.3
	get_tree().current_scene.add_child(freeze_effect)

	for body in get_tree().get_nodes_in_group("Enemies"):
		var distance = body.global_position.distance_to(position)
		print("Checking enemy: ", body.name, " distance: ", distance)
		if distance <= radius:
			if body.has_method("freeze"):
				print("Freezing enemy: ", body.name)
				body.freeze(freeze_duration)

	await get_tree().create_timer(freeze_duration).timeout
	freeze_effect.queue_free()



@rpc("any_peer", "call_local")
func orbital_strike_shot(position: Vector2, damage: float = 100.0):
	print("Orbital Strike called at position: ", position)

	var orbital_sprite_scene = preload("res://src/scenes/gameplayscenes/ExplosionMarker.tscn")
	var orbital_sprite = orbital_sprite_scene.instantiate()
	orbital_sprite.global_position = position
	get_tree().current_scene.add_child(orbital_sprite)

	await orbital_explode_sequence(position, damage)

	orbital_sprite.queue_free()


func orbital_explode_sequence(position: Vector2, damage: float) -> void:
	var radius = 200.0
	var explosion_count = 5
	var delay_between = 2.0

	var explosion_effect_scene := preload("res://src/scenes/gameplayscenes/ExplosionEffect.tscn")

	print("Orbital Strike incoming at: ", position)

	for i in range(explosion_count):
		var effect = explosion_effect_scene.instantiate()
		effect.global_position = position
		get_tree().current_scene.add_child(effect)

		for enemy in get_tree().get_nodes_in_group("Enemies"):
			if enemy.global_position.distance_to(position) <= radius:
				var hc = enemy.get_node_or_null("HealthComponent")
				if hc != null:
					var temp_attack = Attack.new()
					temp_attack.attack_damage = damage
					hc.damage(temp_attack)

		await get_tree().create_timer(delay_between).timeout

func update_ability_ui_visibility():
	if !core: return
	
	var pct = float(core.currentPower) / float(core.MAXPOWER)

	$FighterUI/SkillBar/SpellButton.visible = pct >= 0.0
	$FighterUI/SkillBar/SpellButton2.visible = pct >= 0.25
	$FighterUI/SkillBar/SpellButton3.visible = pct >= 0.5
	$FighterUI/SkillBar/SpellButton4.visible = pct >= 0.75
