extends Camera2D

@export var jugador: CharacterBody2D

# Ahora podés cambiar este valor desde el Inspector a la derecha en el editor.
# 0.40 es un valor súper seguro que deja al personaje abajo pero sin borrar el piso.
@export var porcentaje_pantalla: float = 0.40

var desfase_y: float = 0.0
var altura_suelo_actual: float = 0.0

func _ready() -> void:
	if jugador != null:
		var centro_x = get_viewport_rect().size.x / 2.0
		var alto_pantalla = get_viewport_rect().size.y
		
		# Calculamos el desfase usando la nueva variable del Inspector
		desfase_y = alto_pantalla * porcentaje_pantalla
		altura_suelo_actual = jugador.global_position.y
		
		global_position = Vector2(centro_x, altura_suelo_actual - desfase_y)
		reset_smoothing()

func _process(delta: float) -> void:
	if jugador != null:
		# Detecta si toca una plataforma desde arriba
		if jugador.is_on_floor():
			if jugador.global_position.y < altura_suelo_actual:
				altura_suelo_actual = jugador.global_position.y
		
		var objetivo_y = altura_suelo_actual - desfase_y
		
		# Sube suavemente solo cuando alcanzas una plataforma más alta
		if global_position.y > objetivo_y:
			global_position.y = lerp(global_position.y, objetivo_y, 6.0 * delta)
