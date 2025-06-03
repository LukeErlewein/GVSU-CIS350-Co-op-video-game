class_name Grunt extends BaseEnemy

@export var target : Node2D
@export var COOLDOWN: float = 2.0

@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var attack_cooldown: Timer = $AttackCooldown

var can_attack: bool = true

func _ready() -> void:
	attack = Attack.new()
	health_component.MAX_HEALTH = STATS.health
	sprite_2d.texture = STATS.texture
	attack.attack_damage = STATS.damage
	target = set_target(STATS)
	

func _process(delta: float) -> void:
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	var movement_velocity = dir * STATS.speed
	movement_velocity += external_force
	velocity = movement_velocity
	move_and_slide()
	external_force = external_force.lerp(Vector2.ZERO, delta * 4.0)

	sprite_2d.look_at(nav_agent.get_next_path_position())
	sprite_2d.rotate(-PI * 0.5)

func make_path() -> void:
	target = set_target(STATS)
	if target == null:
		nav_agent.target_position = global_position
		return
	nav_agent.target_position = target.global_position

func action(hitbox: HitboxComponent):
	if can_attack:
		attack_cooldown.start(COOLDOWN)
		can_attack = false
		hitbox.damage(attack)
		queue_free()

func _on_debug_path_timeout() -> void:
	make_path()
	

func _on_attack_cooldown_timeout() -> void:
	can_attack = true

func _on_hitbox_component_body_entered(body: Node2D) -> void:
	print("Body entered: ", body.name, " - class: ", body.get_class())
	var hitbox = body.get_node_or_null("HitboxComponent")
	print("Hitbox: ", hitbox)

	if body is FighterPlayer or body is RangerPlayer or body is Core:
		if hitbox:
			print("Calling action() on ", body.name)
			action(hitbox)
		else:
			print("No HitboxComponent found on ", body.name)

func take_damage(amount: float):
	if health_component:
		health_component.take_damage(amount)


func _on_timer_timeout() -> void:
	print("Timer finished, unfreezing.")
	unfreeze()
