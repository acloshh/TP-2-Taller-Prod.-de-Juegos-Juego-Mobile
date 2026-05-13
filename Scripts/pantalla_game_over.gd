extends Control

func _on_button_pressed() -> void:
	# 1. Quitamos la pausa del juego
	get_tree().paused = false
	# 2. Recargamos la escena actual para empezar de cero
	get_tree().reload_current_scene()
