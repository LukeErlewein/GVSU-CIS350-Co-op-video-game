extends Control

@export var player_node_path: NodePath
var player: Node2D
var health_component

@onready var health_bar = $HealthBar

func _ready():
	player = get_node(player_node_path)
	health_component = player.get_node("HealthComponent")
	health_bar.max_value = health_component.MAX_HEALTH


func _process(_delta):
	if player == null:
		return

	var camera := get_viewport().get_camera_2d()
	var half_screen: Vector2 = get_viewport().get_visible_rect().size / 2.0
	var screen_pos: Vector2 = player.global_position - camera.global_position + half_screen
	global_position = screen_pos + Vector2(-37, -40)  # offset above player

	var current: float = health_component.health
	health_bar.value = current
	$HealthLabel.text = str(round(current)) + "/" + str(round(health_component.MAX_HEALTH))
