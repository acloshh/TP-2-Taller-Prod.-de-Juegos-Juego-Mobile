extends Control

func _ready() -> void:
	# Nos aseguramos de descongelar el motor por si venimos del Game Over
	get_tree().paused = false

func _on_boton_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/mundo.tscn")


func _on_boton_tienda_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/tienda.tscn")
