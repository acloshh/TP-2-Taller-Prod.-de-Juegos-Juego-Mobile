extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# Si el personaje toca el ítem, activa el estado fantasma y se autoelimina
	if body.has_method("activar_fantasma"):
		body.activar_fantasma()
		queue_free()
