extends CharacterBody2D

@export var velocidad: float = 300
@export var suavizado: float = 0.15
@export var margen: float = 16.0

# --- NUEVAS VARIABLES PARA EL SALTO/REBOTE ---
@export var gravedad: float = 3500
@export var fuerza_rebote: float = -2400 # Valor negativo porque hacia arriba es -Y

# --- VARIABLES DEL IMÁN ---
@onready var area_iman: Area2D = $AreaIman
@onready var colision_iman: CollisionShape2D = $AreaIman/CollisionShape2D
@onready var temporizador_iman: Timer = $TemporizadorIman

# --- VARIABLES DEL JETPACK ---
@onready var temporizador_jetpack: Timer = $TemporizadorJetpack
var jetpack_activo: bool = false
var mascara_colision_original: int = 0
var velocidad_vuelo: float = -3000 # Velocidad constante hacia arriba

func _ready() -> void:
	if area_iman != null:
		area_iman.monitoring = false
	# Guardamos la máscara original del personaje al empezar
	mascara_colision_original = collision_mask

func _physics_process(delta: float) -> void:
	# 1. Movimiento horizontal (Acelerómetro) - Lo dejamos activo para poder movernos mientras volamos
	var inclinacion_x = Input.get_accelerometer().x
	var target_vel_x = inclinacion_x * velocidad
	velocity.x = lerp(velocity.x, target_vel_x, suavizado)
	
	# 2. LÓGICA DE MOVIMIENTO VERTICAL (Bifurcación si hay Jetpack)
	if jetpack_activo:
		# Si el jetpack está encendido, vamos hacia arriba a velocidad fija ignorando la gravedad
		velocity.y = velocidad_vuelo
	else:
		# Movimiento normal con gravedad si el jetpack está apagado
		if not is_on_floor():
			velocity.y += gravedad * delta
			
		# Lógica de REBOTE contra el suelo
		if is_on_floor():
			velocity.y = fuerza_rebote
	
	# 3. Ejecutar el movimiento
	move_and_slide()
	
	# --- LÓGICA DE TELETRANSPORTE (Bordes laterales) ---
	var pantalla_ancho = get_viewport_rect().size.x
	if global_position.x > pantalla_ancho + margen:
		global_position.x = -margen
	elif global_position.x < -margen:
		global_position.x = pantalla_ancho + margen

# --- MECÁNICA DEL IMÁN ---
func activar_iman() -> void:
	var nivel_iman = DatosGlobales.niveles_powerups["iman"]
	if nivel_iman == 0: return
	if colision_iman != null and colision_iman.shape is CircleShape2D:
		colision_iman.shape.radius = 150.0 + (50.0 * nivel_iman)
	if area_iman != null:
		area_iman.monitoring = true
	if temporizador_iman != null:
		temporizador_iman.start(7.0 + (2.0 * nivel_iman))

func _on_area_iman_area_entered(area: Area2D) -> void:
	if area.has_method("ser_atraida"):
		area.ser_atraida(self)

func _on_temporizador_iman_timeout() -> void:
	if area_iman != null:
		area_iman.monitoring = false

# --- MECÁNICA DEL JETPACK ---
func activar_jetpack() -> void:
	var nivel_jetpack = DatosGlobales.niveles_powerups["jetpack"]
	if nivel_jetpack == 0:
		return
		
	jetpack_activo = true
	collision_mask = 0
	
	# Mensaje de control para ver si el nodo existe
	if temporizador_jetpack == null:
		print("¡ERROR: El nodo TemporizadorJetpack NO se encontró! Revisá el nombre en la escena.")
		return
		
	var duracion = 3.0 + (1.0 * nivel_jetpack)
	temporizador_jetpack.start(duracion)
	print("¡Jetpack encendido! Debería durar: ", duracion, " segundos.")

# SEÑAL: Conectá la señal 'timeout' de tu TemporizadorJetpack a esta función
func _on_temporizador_jetpack_timeout() -> void:
	jetpack_activo = false
	collision_mask = mascara_colision_original # Devolvemos las colisiones normales
	velocity.y = fuerza_rebote # Le damos un pequeño impulso inicial al salir para que no caiga como piedra
