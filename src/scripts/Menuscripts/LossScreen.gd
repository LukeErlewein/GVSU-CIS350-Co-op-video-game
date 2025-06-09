extends CanvasLayer

func _on_button_pressed() -> void:
	get_tree().paused = false
	await Multiplayer.reset()
	get_tree().change_scene_to_file("res://src/scenes/Wasteland.tscn")
	Global.GAME_RUNNING = false
