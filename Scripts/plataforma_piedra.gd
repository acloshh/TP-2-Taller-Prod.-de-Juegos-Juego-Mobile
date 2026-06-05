extends Node2D

signal plataforma_superada


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	plataforma_superada.emit()
	queue_free()
