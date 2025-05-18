extends CanvasLayer

@export var core_node: Core
@export var player_node: Node2D

@onready var core_health_bar = $CoreStatusBox/CoreHealthBar
@onready var core_charge_bar = $CoreStatusBox/CoreChargeBar
@onready var stopwatch_label = $StopwatchLabel
@onready var core_arrow = $CoreArrow

var core_health: Node = null  # Declare it here, at the top
var time_elapsed := 0.0

func _ready():
	if core_node:
		core_health = core_node.get_node("HealthComponent")

func _process(delta):
	time_elapsed += delta
	var minutes = int(time_elapsed) / 60
	var seconds = int(time_elapsed) % 60
	stopwatch_label.text = "%02d:%02d" % [minutes, seconds]

	if core_health and core_node:
		core_health_bar.max_value = core_health.MAX_HEALTH
		core_health_bar.value = core_health.health

		core_charge_bar.max_value = core_node.MAXPOWER
		core_charge_bar.value = core_node.currentPower

	if not core_node or not player_node:
		return

	# Compute direction from player to core using global world positions
	var center_of_map = Vector2(576, 324)  # Change if your map’s center isn't exactly (0, 0)
	var player_pos = player_node.global_position
	var direction = (center_of_map - player_pos).normalized()


	# Calculate the angle and apply it to the UI arrow
	core_arrow.rotation = direction.angle()  # Add PI/2 only if the arrow image points right


func world_to_screen(world_pos: Vector2) -> Vector2:
	var camera := get_viewport().get_camera_2d()
	if camera == null:
		return Vector2.ZERO
	var camera_transform := camera.get_global_transform()
	return camera_transform * world_pos
