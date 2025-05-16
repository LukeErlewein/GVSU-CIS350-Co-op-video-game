class_name Grunt extends BaseEnemy

@export var stats : EnemyStats
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var target : Node2D

func _ready() -> void:
	health_component.MAX_HEALTH = stats.health
	sprite_2d.texture = stats.texture
	sprite_2d.rotate(-PI * 0.5)
	#set_target(stats.target)
	

func _physics_process(delta: float) -> void:
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = dir * stats.speed
	move_and_slide()

func make_path() -> void:
	nav_agent.target_position = target.global_position

func _on_debug_path_timeout() -> void:
	make_path()
