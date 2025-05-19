extends Control

@onready var health_bar = $HealthBar
@onready var health_label = $HealthLabel
@onready var animation_player = $AnimationPlayer

var is_visible := true
var camera : Camera2D 
var player: Node2D
var health_component

func _ready():
	hide()
	player = get_parent().get_parent()
	camera = player.get_node("Camera2D")
	health_component = player.get_node("HealthComponent")
	health_bar.max_value = health_component.MAX_HEALTH
	modulate.a = 0.0  # Start hidden
	is_visible = false

func _process(_delta):
	if is_multiplayer_authority(): show()
	if player == null or health_component == null:
		return

	# Position above player
	var half_screen: Vector2 = get_viewport().get_visible_rect().size / 2.0
	var screen_pos: Vector2 = player.global_position - camera.global_position + half_screen
	global_position = screen_pos + Vector2(-37, -40)

	var current: float = health_component.health
	health_bar.value = current
	health_label.text = str(round(current)) + "/" + str(round(health_component.MAX_HEALTH))

	var should_be_visible = current < health_component.MAX_HEALTH

	if should_be_visible and not is_visible:
		animation_player.play("FadeIn")
		is_visible = true
	elif not should_be_visible and is_visible:
		animation_player.play("FadeOut")
		is_visible = false
