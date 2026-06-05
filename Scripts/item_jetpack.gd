extends Area2D


func _on_body_entered(body: Node2D) -> void:
# Si el personaje lo toca, activa el jetpack y se destruye el ítem
	if body.has_method("activar_jetpack"):
		body.activar_jetpack()
		queue_free()
