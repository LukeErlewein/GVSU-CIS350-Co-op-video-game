extends Control

const host_player: PackedScene = preload("res://src/scenes/playerscenes/FighterPlayer.tscn")
const join_player: PackedScene = preload("res://src/scenes/playerscenes/RangerPlayer.tscn")
@export var address: String = "192.168.125.102"

var peer = ENetMultiplayerPeer.new()

func _ready():
	multiplayer.peer_connected.connect(player_connected)
	multiplayer.peer_disconnected.connect(player_disconnected)
	multiplayer.connection_failed.connect(cant_connect)
	$VBoxContainer/JoinButton.grab_focus()
	

func player_connected(id):
	print("Player Connected: ", id)
	var ranger_player = join_player.instantiate()
	ranger_player.name = str(id)
	get_parent().add_child(ranger_player)

func player_disconnected(id):
	print("Player Disconnected: "+id)

func cant_connect(id):
	print("Couldnt connect")

func _on_join_button_pressed() -> void:
	peer.create_client("localhost", 21832)
	multiplayer.multiplayer_peer = peer
	hide()
	

func _on_host_button_pressed() -> void:
	peer.create_server(21832, 2)
	multiplayer.multiplayer_peer = peer
	hide()
	var fighter_player = host_player.instantiate()
	fighter_player.name = str(multiplayer.get_unique_id())
	get_parent().add_child(fighter_player)
	


func _on_quit_button_pressed() -> void:
	get_tree().quit()
