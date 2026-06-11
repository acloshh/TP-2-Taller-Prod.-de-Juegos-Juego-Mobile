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

# --- VARIABLES DEL FANTASMA ---
@onready var temporizador_fantasma: Timer = $TemporizadorFantasma
var es_fantasma: bool = false

# --- VARIABLES DE LA VIDA EXTRA ---
var vidas_extras: int = 0

func _ready() -> void:
	if area_iman != null:
		area_iman.monitoring = false
	# Guardamos la máscara original del personaje al empezar
	mascara_colision_original = collision_mask
	
	# --- LÓGICA PASIVA DEL CORAZÓN ---
	# Al arrancar la run, si el ítem está comprado en la tienda, te da 1 vida extra
	if DatosGlobales.niveles_powerups.has("vida") and DatosGlobales.niveles_powerups["vida"] > 0:
		vidas_extras = 1
	else:
		vidas_extras = 0

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
		colision_iman.shape.radius = 100 + (30.0 * nivel_iman)
	if area_iman != null:
		area_iman.monitoring = true
	if temporizador_iman != null:
		temporizador_iman.start(5.0 + (2.0 * nivel_iman))

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
		
	var duracion = 1.0 + (1.0 * nivel_jetpack)
	temporizador_jetpack.start(duracion)
	print("¡Jetpack encendido! Debería durar: ", duracion, " segundos.")

# SEÑAL: Conectá la señal 'timeout' de tu TemporizadorJetpack a esta función
func _on_temporizador_jetpack_timeout() -> void:
	jetpack_activo = false
	collision_mask = mascara_colision_original # Devolvemos las colisiones normales
	velocity.y = fuerza_rebote # Le damos un pequeño impulso inicial al salir para que no caiga como piedra

# --- MECÁNICA DEL FANTASMA ---
func activar_fantasma() -> void:
	var nivel_fantasma = DatosGlobales.niveles_powerups["fantasma"]
	if nivel_fantasma == 0:
		return # Bloqueado si no se compró en la tienda
		
	es_fantasma = true
	
	# Efecto visual: bajamos la opacidad al 50% para que parezca transparente
	modulate.a = 0.5
	
	if temporizador_fantasma != null:
		# Duración: 5 segundos base + 1.5 segundos por nivel de mejora
		var duracion = 3.0 + (1.5 * nivel_fantasma)
		temporizador_fantasma.start(duracion)
		print("¡Modo Fantasma activado por ", duracion, " segundos!")

# SEÑAL: Conectá la señal 'timeout' de tu TemporizadorFantasma a esta función
func _on_temporizador_fantasma_timeout() -> void:
	es_fantasma = false
	# Le devolvemos la opacidad normal al personaje (100%)
	modulate.a = 1.0
	print("¡Modo Fantasma terminado!")
