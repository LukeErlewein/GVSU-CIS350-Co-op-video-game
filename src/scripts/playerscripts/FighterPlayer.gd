class_name FighterPlayer extends CharacterBody2D

@export var SPEED: float = 130
@export var ACCELERATION: float = 5
@export var FRICTION: float = 8

@export var bullet : PackedScene
@export var projectile_node : PackedScene
@onready var muzzle: Marker2D = $Muzzle
@onready var shot_cooldown_timer: Timer = $ShotCooldownTimer
@onready var camera: Camera2D = $Camera2D
@onready var core: Node = get_tree().get_current_scene().get_node("Core")
@onready var wait_screen: CanvasLayer = $FighterUI/WaitScreen
@onready var gunshot: AudioStreamPlayer2D = $Audio/Gunshot
@onready var ability_1: AudioStreamPlayer2D = $Audio/Ability1
@onready var ability_2: AudioStreamPlayer2D = $Audio/Ability2
@onready var ability_3: AudioStreamPlayer2D = $Audio/Ability3
@onready var ability_4: AudioStreamPlayer2D = $Audio/Ability4

var attack: Attack
var can_shoot: bool = true
var can_control: bool = false

func _ready() -> void:
	if is_multiplayer_authority():
		get_tree().get_current_scene().game_start.connect(hide_UI)
		camera.make_current()
	else:
		if has_node("FighterUI"):
			$FighterUI.hide()
	print("core assigned: ", core)

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
	if !is_multiplayer_authority():
		return
	can_control = true
	if has_node("FighterUI"):
		$FighterUI.show()

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
func shotgun_blast(base_transform: Transform2D, animation_name = "SprayBullets", damage: float = 9, speed: float = 40.0, lifetime: float = 1.5):
	var angles_deg = [0, -5, 5, -10, 10]
	var position = base_transform.origin
	var forward_angle = base_transform.get_rotation()
	for angle in angles_deg:
		var total_angle = forward_angle + deg_to_rad(angle)
		var new_transform = Transform2D(total_angle, position)
		single_shot(new_transform, animation_name, damage, speed, lifetime)

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
		ability_2.play()
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
		ability_3.play()
		explode_freeze_grenade(pos)
	)

	get_tree().current_scene.add_child(grenade)

func explode_freeze_grenade(position: Vector2):
	var radius = 200.0
	var freeze_duration = 5.0

	print("Freeze Grenade exploded at: ", position)

	var freeze_effect_scene := preload("res://src/scenes/gameplayscenes/FreezeMarker.tscn")
	var freeze_effect = freeze_effect_scene.instantiate()
	freeze_effect.global_position = position
	freeze_effect.modulate.a = 0.3
	get_tree().current_scene.add_child(freeze_effect)

	for enemy in get_tree().get_nodes_in_group("Enemies"):
		var distance = enemy.global_position.distance_to(position)
		if distance <= radius:
			if enemy.has_method("freeze"):
				enemy.freeze(freeze_duration)

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
		ability_4.play()
		await get_tree().create_timer(delay_between).timeout

func update_ability_ui_visibility():
	if !core: return
	
	var pct = float(core.currentPower) / float(core.MAXPOWER)

	$FighterUI/SkillBar/SpellButton.visible = pct >= 0.0
	$FighterUI/SkillBar/SpellButton2.visible = pct >= 0.25
	$FighterUI/SkillBar/SpellButton3.visible = pct >= 0.5
	$FighterUI/SkillBar/SpellButton4.visible = pct >= 0.75
