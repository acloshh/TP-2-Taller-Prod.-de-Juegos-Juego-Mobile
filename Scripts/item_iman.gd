extends Area2D


func _on_body_entered(body: Node2D) -> void:
	# Verificamos si el cuerpo que chocó tiene la función que creamos
	if body.has_method("activar_iman"):
		body.activar_iman()
		queue_free() # Hacemos desaparecer el ítem de la pantalla
