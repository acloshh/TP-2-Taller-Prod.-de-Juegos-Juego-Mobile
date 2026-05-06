extends CharacterBody2D

@export var velocidad: float = 600.0
@export var suavizado: float = 0.15 # Valor entre 0 y 1 para evitar movimientos bruscos
@export var margen: float = 16.0 # Mitad del ancho de tu sprite para el cálculo de bordes


func _ready() -> void:
	# Si esto no aparece en la consola, el nodo no se está cargando o hay un problema de red
	print("¡El personaje se ha instanciado correctamente en el celular!")
	
	# También podemos ver si el dispositivo reporta tener acelerómetro
	var tiene_acelerometro = Input.get_accelerometer() != Vector3.ZERO
	print("¿El acelerómetro da datos al inicio?: ", tiene_acelerometro)
	
	
	
func _physics_process(_delta: float) -> void:
	var acc = Input.get_accelerometer()
	
	# Esto imprimirá los datos en la consola de tu PC en tiempo real
	print("Acelerómetro: ", acc)
	
	var inclinacion_x = acc.x
	var target_vel_x = -inclinacion_x * velocidad
	velocity.x = lerp(velocity.x, target_vel_x, suavizado)
	move_and_slide()
	
	# --- LÓGICA DE TELETRANSPORTE (EFECTO ESPEJO) ---
	var pantalla_ancho = get_viewport_rect().size.x
	
	# Si el personaje sale por la derecha, aparece por la izquierda
	if global_position.x > pantalla_ancho + margen:
		global_position.x = -margen
	
	# Si el personaje sale por la izquierda, aparece por la derecha
	elif global_position.x < -margen:
		global_position.x = pantalla_ancho + margen
