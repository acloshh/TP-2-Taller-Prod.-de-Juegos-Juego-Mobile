extends CharacterBody2D

@export var velocidad: float = 300
@export var suavizado: float = 0.15
@export var margen: float = 16.0

# --- NUEVAS VARIABLES PARA EL SALTO/REBOTE ---
@export var gravedad: float = 3500
@export var fuerza_rebote: float = -2400 # Valor negativo porque hacia arriba es -Y

func _physics_process(delta: float) -> void:
	# 1. Movimiento horizontal (Acelerómetro)
	var inclinacion_x = Input.get_accelerometer().x
	var target_vel_x = inclinacion_x * velocidad
	velocity.x = lerp(velocity.x, target_vel_x, suavizado)
	
	# 2. Aplicar gravedad (Movimiento vertical)
	# Esto hace que el personaje caiga constantemente
	if not is_on_floor():
		velocity.y += gravedad * delta
	
	# 3. Ejecutar el movimiento
	move_and_slide()
	
	# 4. Lógica de REBOTE contra el suelo
	# Si el personaje toca el suelo, lo impulsamos hacia arriba automáticamente
	if is_on_floor():
		velocity.y = fuerza_rebote
	
	# --- LÓGICA DE TELETRANSPORTE (Bordes laterales) ---
	var pantalla_ancho = get_viewport_rect().size.x
	if global_position.x > pantalla_ancho + margen:
		global_position.x = -margen
	elif global_position.x < -margen:
		global_position.x = pantalla_ancho + margen
