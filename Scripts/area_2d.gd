extends Area2D

signal moneda_recogida

var jugador_objetivo: Node2D = null
var velocidad_atraccion: float = 600.0

func _process(delta: float) -> void:
	# Si un jugador la está atrayendo, la moneda se mueve hacia él
	if jugador_objetivo != null:
		global_position = global_position.move_toward(jugador_objetivo.global_position, velocidad_atraccion * delta)

# Función que va a llamar el imán del jugador para "enganchar" la moneda
func ser_atraida(jugador: Node2D) -> void:
	jugador_objetivo = jugador

func _on_body_entered(body: Node2D) -> void:
	# Acá detecta cuando el jugador la toca físicamente para sumarla
	if body.name == "Jugador" or body is CharacterBody2D: 
		moneda_recogida.emit()
		queue_free()
