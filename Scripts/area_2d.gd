extends Area2D

signal moneda_recogida




func _on_body_entered(body: Node2D) -> void:
		# Verificamos que lo que tocó la moneda sea el jugador
	if body is CharacterBody2D:
		moneda_recogida.emit() # Avisamos que la agarramos
		queue_free() # Destruimos la monedapass # Replace with function body.
