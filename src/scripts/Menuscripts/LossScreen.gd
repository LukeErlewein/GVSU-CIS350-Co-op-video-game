extends CanvasLayer

func _on_button_pressed() -> void:
	get_tree().paused = false
	print("Button pressed")
	get_tree().reload_current_scene()
