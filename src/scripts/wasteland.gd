extends Node2D

@export var RESPAWN_TIME: float = 10.0

@onready var core: Core = $Core
@onready var wait_screen: CanvasLayer = $WaitScreen
@onready var victory_screen: CanvasLayer = $VictoryScreen
@onready var loss_screen: CanvasLayer = $LossScreen
@onready var gameplay_music: AudioStreamPlayer = $GameplayMusic
@onready var menu_music: AudioStreamPlayer2D = $MenuMusic
@onready var fighter_respawn: Timer = $Timers/FighterRespawn
@onready var ranger_respawn: Timer = $Timers/RangerRespawn
@onready var menu: Control = $Menu

signal game_start

var fighter_joined := false
var ranger_joined := false
var game_has_started := false

func _ready() -> void:
	await get_tree().process_frame
	wait_screen.hide()
	victory_screen.hide()
	loss_screen.hide()
	core.game_lost.connect(game_over)
	core.game_won.connect(game_beat)
	Multiplayer.show_wait_screen.connect(_on_show_wait_screen)
	menu_music.play()

func start_game():
	if game_has_started:
		return
	game_has_started = true
	game_start.emit()
	Global.GAME_RUNNING = true
	wait_screen.hide()
	menu_music.stop()
	gameplay_music.play()

func add_cell(cell_position: Vector2) -> void:
	menu.multiplayer_spawner.spawn(cell_position)

func game_over() -> void:
	get_tree().paused = true
	loss_screen.show()
	loss_screen.get_node("LossAudio").play()

func game_beat() -> void:
	get_tree().paused = true
	victory_screen.show()
	victory_screen.get_node("WinAudio").play()

func _on_child_entered_tree(node: Node) -> void:
	if node is RangerPlayer:
		ranger_joined = true
	elif node is FighterPlayer:
		fighter_joined = true

	if ranger_joined and fighter_joined:
		start_game()

	if node is EnergyCell:
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

func _on_show_wait_screen():
	wait_screen.show()
