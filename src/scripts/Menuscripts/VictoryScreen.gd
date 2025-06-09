extends CanvasLayer


func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	print("Button pressed")
	get_tree().reload_current_scene()
