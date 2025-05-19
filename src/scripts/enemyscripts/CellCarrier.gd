class_name CellCarrier extends BaseEnemy

@export var STATS : EnemyStats
@export var COOLDOWN: float = 2.0

@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var attack_cooldown: Timer = $AttackCooldown

var can_attack: bool = true
var target : Node2D

signal carrier_death

func _ready() -> void:
	attack = Attack.new()
	health_component.MAX_HEALTH = STATS.health
	sprite_2d.texture = STATS.texture
	attack.attack_damage = STATS.damage
	target = set_target(STATS)


func _process(delta: float) -> void:
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = dir * STATS.speed
	move_and_slide()
	sprite_2d.look_at(nav_agent.get_next_path_position())
	sprite_2d.rotate(-PI * 0.5)

func make_path() -> void:
	target = set_target(STATS)
	nav_agent.target_position = target.global_position

func action(hitbox: HitboxComponent):
	if can_attack:
		attack_cooldown.start(COOLDOWN)
		can_attack = false
		hitbox.damage(attack)

func _exit_tree() -> void:
	carrier_death.emit(global_position)

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
