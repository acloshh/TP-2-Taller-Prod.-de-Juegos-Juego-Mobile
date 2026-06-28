extends CharacterBody2D

@export var velocidad: float = 300
@export var suavizado: float = 0.15
@export var margen: float = 16.0

# --- VARIABLES PARA EL SALTO/REBOTE ---
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

# --- VARIABLE DE ANIMACIONES ---
@onready var sprite_animado: AnimatedSprite2D = $Sprite2D

func _ready() -> void:
	if area_iman != null:
		area_iman.monitoring = false
		
	# Guardamos la máscara original por si acaso
	mascara_colision_original = collision_mask
	
	# ESTADO INICIAL NORMAL:
	# Detecta plataformas comunes (Capa 1) y Piedra Sólida (Capa 2). Ignora el alma de la piedra (Capa 3).
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, true)
	set_collision_mask_value(3, false)
	
	# --- LÓGICA PASIVA DEL CORAZÓN ---
	if DatosGlobales.niveles_powerups.has("vida") and DatosGlobales.niveles_powerups["vida"] > 0:
		vidas_extras = 1
	else:
		vidas_extras = 0

func _physics_process(delta: float) -> void:
	# 1. Movimiento horizontal (Acelerómetro)
	var inclinacion_x = Input.get_accelerometer().x
	var target_vel_x = inclinacion_x * velocidad
	velocity.x = lerp(velocity.x, target_vel_x, suavizado)
	
	# 2. LÓGICA DE MOVIMIENTO VERTICAL
	if jetpack_activo:
		velocity.y = velocidad_vuelo
	else:
		if not is_on_floor():
			velocity.y += gravedad * delta
			
		if is_on_floor():
			velocity.y = fuerza_rebote
	
	# 3. Ejecutar el movimiento
	move_and_slide()
	
	# --- LÓGICA DE ANIMACIONES (Ultra responsiva) ---
	if sprite_animado != null:
		if jetpack_activo:
			sprite_animado.play("normal")
		else:
			if velocity.y < 0:
				sprite_animado.play("normal")
			elif velocity.y > 0:
				sprite_animado.play("caida salto")
	
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
	
	# El jetpack ignora absolutamente todas las plataformas existentes
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, false)
	set_collision_mask_value(3, false)
	
	if temporizador_jetpack == null:
		print("¡ERROR: El nodo TemporizadorJetpack NO se encontró! Revisá el nombre en la escena.")
		return
		
	var duracion = 1.0 + (1.0 * nivel_jetpack)
	temporizador_jetpack.start(duracion)

func _on_temporizador_jetpack_timeout() -> void:
	jetpack_activo = false
	velocity.y = fuerza_rebote 
	
	# Al terminar el jetpack, restauramos las capas dependiendo de si todavía le queda tiempo al fantasma
	set_collision_mask_value(1, true)
	if es_fantasma:
		set_collision_mask_value(2, false)
		set_collision_mask_value(3, true)
	else:
		set_collision_mask_value(2, true)
		set_collision_mask_value(3, false)

# --- MECÁNICA DEL FANTASMA ---
func activar_fantasma() -> void:
	var nivel_fantasma = DatosGlobales.niveles_powerups["fantasma"]
	if nivel_fantasma == 0:
		return 
		
	es_fantasma = true
	modulate.a = 0.5
	
	# INTERCAMBIO DE CAPAS: Apagamos la colisión sólida (2) y prendemos la colisión unidireccional (3)
	if not jetpack_activo:
		set_collision_mask_value(2, false)
		set_collision_mask_value(3, true)
	
	if temporizador_fantasma != null:
		var duracion = 3.0 + (1.5 * nivel_fantasma)
		temporizador_fantasma.start(duracion)

func _on_temporizador_fantasma_timeout() -> void:
	es_fantasma = false
	modulate.a = 1.0
	
	# Al terminarse el poder, devolvemos la piedra a su estado sólido normal y apagamos la capa fantasma
	if not jetpack_activo:
		set_collision_mask_value(2, true)
		set_collision_mask_value(3, false)
