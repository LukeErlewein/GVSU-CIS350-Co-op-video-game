class_name Grunt extends BaseEnemy

@export var STATS : EnemyStats
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
	#set_target(STATS.target)
	attack.attack_damage = STATS.damage
	

func _process(delta: float) -> void:
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = dir * STATS.speed
	move_and_slide()
	sprite_2d.look_at(target.global_position)
	sprite_2d.rotate(-PI * 0.5)

func make_path() -> void:
	nav_agent.target_position = target.global_position

func action(hitbox: HitboxComponent):
	if can_attack:
		attack_cooldown.start(COOLDOWN)
		can_attack = false
		hitbox.damage(attack)


func _on_debug_path_timeout() -> void:
	make_path()

func _on_attack_cooldown_timeout() -> void:
	can_attack = true

func _on_hitbox_component_body_entered(body: Node2D) -> void:
	if body is FighterPlayer or body is RangerPlayer or body is Core:
		var hitbox = body.get_node_or_null("HitboxComponent")
		action(hitbox)
