extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# Verificamos si el objeto que nos tocó tiene la función para recibir daño
	if body.has_method("recibir_dano"):
		body.recibir_dano()
