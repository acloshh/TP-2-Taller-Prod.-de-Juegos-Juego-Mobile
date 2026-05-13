extends Camera2D

@export var jugador: CharacterBody2D

var desfase_y: float = 0.0

func _ready() -> void:
	if jugador != null:
		var centro_x = get_viewport_rect().size.x / 2.0
		var alto_pantalla = get_viewport_rect().size.y
		
		# Calculamos el desfase: el personaje se verá en el 30% inferior de la pantalla
		desfase_y = alto_pantalla * 0.3
		
		# Posicionamos la cámara de entrada
		global_position = Vector2(centro_x, jugador.global_position.y - desfase_y)
		
		# Reseteamos el suavizado para que no haga un viaje brusco al iniciar la escena
		reset_smoothing()

func _process(_delta: float) -> void:
	if jugador != null:
		# La cámara sube con el jugador manteniendo el desfase visual
		if jugador.global_position.y < global_position.y + desfase_y:
			global_position.y = jugador.global_position.y - desfase_y
