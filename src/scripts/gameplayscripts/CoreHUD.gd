extends CanvasLayer

@onready var core_health_bar = $CoreStatusBox/CoreHealthBar
@onready var core_charge_bar = $CoreStatusBox/CoreChargeBar
@onready var stopwatch_label = $StopwatchLabel

var core_health: Node = null
var time_elapsed := 0.0
var core_node: Core
var game_running: bool = false

func _ready():
	hide()
	get_parent().game_start.connect(start_game)
	core_node = get_parent().get_node("Core")
	if core_node:
		core_health = core_node.get_node("HealthComponent")

func _process(delta):
	if game_running:
		time_elapsed += delta
		var minutes = int(time_elapsed) / 60
		var seconds = int(time_elapsed) % 60
		stopwatch_label.text = "%02d:%02d" % [minutes, seconds]

	if core_health and core_node:
		core_health_bar.max_value = core_health.MAX_HEALTH
		core_health_bar.value = core_health.health

		core_charge_bar.max_value = core_node.MAXPOWER
		core_charge_bar.value = core_node.currentPower

func start_game() -> void:
	show()
	game_running = true
	
