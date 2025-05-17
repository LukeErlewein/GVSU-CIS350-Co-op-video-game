extends Control

func _ready():
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
	peer.create_client("localhost", 21832)
	multiplayer.multiplayer_peer = peer
	hide()
	

func _on_host_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_guide_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		guide.show()
	else:
		guide.hide()
