extends Area2D

signal moneda_recogida

# --- VARIABLES DEL IMÁN ---
var objetivo_iman: Node2D = null
var velocidad_atraccion: float = 1000.0 # Velocidad de arranque
var aceleracion_atraccion: float = 6000.0 # Aceleración por segundo

func _process(delta: float) -> void:
	# Si el imán la enganchó, acelera y persigue al jugador
	if objetivo_iman != null:
		velocidad_atraccion += aceleracion_atraccion * delta
		global_position = global_position.move_toward(objetivo_iman.global_position, velocidad_atraccion * delta)

# El personaje llama a esta función con su Área2D del imán
func ser_atraida(personaje: Node2D) -> void:
	objetivo_iman = personaje

# Cuando choca físicamente contra el personaje
func _on_body_entered(body: Node2D) -> void:
	# Verificamos que sea el jugador (usando un método que sepamos que tiene el personaje)
	if body.has_method("activar_iman"):
		moneda_recogida.emit()
		queue_free()
