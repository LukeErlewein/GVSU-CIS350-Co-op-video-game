extends Node2D

@export var GRUNT_DELAY: float = 2.0
@export var CARRIER_DELAY: float = 15.0

@onready var core: Core = $Core
@onready var grunt_timer: Timer = $Timers/GruntTimer
@onready var carrier_timer: Timer = $Timers/CarrierTimer
@onready var mob_spawn_location: PathFollow2D = $Path2D/MobSpawnLocation
@onready var wait_screen: Control = $WaitScreen
@onready var gameplay_music: AudioStreamPlayer = $GameplayMusic

var grunt: PackedScene = preload("res://src/scenes/enemyscenes/Grunt.tscn")
var cell_carrier: PackedScene = preload("res://src/scenes/enemyscenes/CellCarrier.tscn")
var energy_cell: PackedScene = preload("res://src/scenes/gameplayscenes/EnergyCell.tscn")

signal game_start

func _ready() -> void:
	wait_screen.hide()
	core.game_lost.connect(game_over)
	core.game_won.connect(game_beat)

func start_game():
	game_start.emit()
	wait_screen.hide()
	gameplay_music.play()
	grunt_timer.start(GRUNT_DELAY)
	carrier_timer.start(CARRIER_DELAY)

func spawn_mob(enemy):
	mob_spawn_location.progress_ratio = randf()
	enemy.global_position = mob_spawn_location.global_position
	enemy.name = str(global_position.x)
	add_child.call_deferred(enemy)

func add_cell(cell_position: Vector2) -> void:
	print(cell_position)
	var cell = energy_cell.instantiate()
	cell.global_position = cell_position
	add_child.call_deferred(cell)

func game_over() -> void:
	get_tree().paused = true

func game_beat() -> void:
	get_tree().paused = true


func _on_child_entered_tree(node: Node) -> void:
	if node is RangerPlayer:
		start_game()
	elif node is CellCarrier:
		node.carrier_death.connect(add_cell)
	elif node is EnergyCell:
		node.cell_pickup.connect(core.add_power)


func _on_grunt_timer_timeout() -> void:
	for i in range(0, 5):
		spawn_mob(grunt.instantiate())


func _on_carrier_timer_timeout() -> void:
	spawn_mob(cell_carrier.instantiate())


func _on_gameplay_music_finished() -> void:
	gameplay_music.play()
