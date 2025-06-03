extends Node


@export var GRUNT_DELAY: float = 2.0
@export var CARRIER_DELAY: float = 15.0

@onready var enemy_spawner: MultiplayerSpawner = $EnemySpawner
@onready var grunt_timer: Timer = $"../Timers/GruntTimer"
@onready var carrier_timer: Timer = $"../Timers/CarrierTimer"
@onready var mob_spawn_location: PathFollow2D = $"../Path2D/MobSpawnLocation"

var grunt: PackedScene = preload("res://src/scenes/enemyscenes/Grunt.tscn")
var cell_carrier: PackedScene = preload("res://src/scenes/enemyscenes/CellCarrier.tscn")

func _ready() -> void:
	get_parent().game_start.connect(begin_game)
	enemy_spawner.spawn_function = spawn_mob


func begin_game():
	grunt_timer.start(GRUNT_DELAY)
	carrier_timer.start(CARRIER_DELAY)

#@rpc("call_local")
func spawn_mob(type):
	if type == "Grunt":
		var enemy = grunt.instantiate()
		mob_spawn_location.progress_ratio = randf()
		enemy.global_position = mob_spawn_location.global_position
		enemy.name = str(enemy.global_position.x)
		return enemy
	elif type == "Cell_Carrier":
		var enemy = cell_carrier.instantiate()
		mob_spawn_location.progress_ratio = randf()
		enemy.global_position = mob_spawn_location.global_position
		enemy.name = str(enemy.global_position.x)
		return enemy

func _on_grunt_timer_timeout() -> void:
	for i in range(0, 2):
		enemy_spawner.spawn("Grunt")


func _on_carrier_timer_timeout() -> void:
	enemy_spawner.spawn("Cell_Carrier")
