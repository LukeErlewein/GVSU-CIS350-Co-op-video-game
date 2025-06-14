extends CanvasLayer


func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()
