extends Node2D

@export var RESPAWN_TIME: float = 10.0

@onready var core: Core = $Core
@onready var wait_screen: Control = $WaitScreen
@onready var gameplay_music: AudioStreamPlayer = $GameplayMusic
@onready var fighter_respawn: Timer = $Timers/FighterRespawn
@onready var ranger_respawn: Timer = $Timers/RangerRespawn
@onready var menu: Control = $Menu

var energy_cell: PackedScene = preload("res://src/scenes/gameplayscenes/EnergyCell.tscn")

signal game_start

func _ready() -> void:
	wait_screen.hide()
	core.game_lost.connect(game_over)
	core.game_won.connect(game_beat)

func start_game():
	game_start.emit()
	Global.GAME_RUNNING = true
	wait_screen.hide()
	gameplay_music.play()


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
	elif node is EnergyCell:
		node.cell_pickup.connect(core.add_power)





func _on_gameplay_music_finished() -> void:
	gameplay_music.play()


func _on_enemies_child_entered_tree(node: Node) -> void:
	if node is CellCarrier:
		node.carrier_death.connect(add_cell)


func _on_child_exiting_tree(node: Node) -> void:
	if node is RangerPlayer:
		ranger_respawn.start(RESPAWN_TIME)
	if node is FighterPlayer:
		fighter_respawn.start(RESPAWN_TIME)


func _on_fighter_respawn_timeout() -> void:
	menu.multiplayer_spawner.spawn(multiplayer.get_unique_id())


func _on_ranger_respawn_timeout() -> void:
	menu.multiplayer_spawner.spawn(Global.RANGER_MULTIPLAYER_ID)
