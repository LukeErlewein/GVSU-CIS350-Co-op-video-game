extends Control


const host_player: PackedScene = preload("res://src/scenes/playerscenes/FighterPlayer.tscn")
const join_player: PackedScene = preload("res://src/scenes/playerscenes/RangerPlayer.tscn")
@export var address: String = "192.168.125.102"
@onready var ranger_spawn: Marker2D = $"../TileMapLayer/RangerSpawn"
@onready var fighter_spawn: Marker2D = $"../TileMapLayer/FighterSpawn"
@onready var multiplayer_spawner: MultiplayerSpawner = $"../PlayerSpawner"

@onready var guide: Label = $Guide
@onready var oid_label: Label = $VBoxContainer/OID
@onready var oid_input: LineEdit = $VBoxContainer/OIDInput

var peer = ENetMultiplayerPeer.new()

func _ready():
	guide.hide()
	show()
	
	multiplayer_spawner.spawn_function = spawn
	multiplayer.peer_disconnected.connect(player_disconnected)
	multiplayer.connection_failed.connect(cant_connect)
	
	await Multiplayer.noray_connected
	oid_label.text = Noray.oid


func player_disconnected(id):
	print("Player Disconnected: ", id)

func cant_connect(id):
	print("Couldnt connect")

func spawn(id):
	print("Player Connected: ", id)
	if id == 1:
		var fighter_player = host_player.instantiate()
		fighter_player.name = str(id)
		fighter_player.global_position = fighter_spawn.global_position
		return fighter_player
	else:
		var ranger_player = join_player.instantiate()
		ranger_player.name = str(id)
		ranger_player.global_position = ranger_spawn.global_position
		return ranger_player

func _on_join_button_pressed() -> void:
	Multiplayer.join(oid_input.text)
	hide()
	

func _on_host_button_pressed() -> void:
	Multiplayer.host()
	hide()
	multiplayer.peer_connected.connect(
		func(id):
			multiplayer_spawner.spawn(id)
	)
	multiplayer_spawner.spawn(multiplayer.get_unique_id())


func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_guide_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		guide.show()
	else:
		guide.hide()


func _on_copy_oid_pressed() -> void:
	DisplayServer.clipboard_set(Noray.oid)
