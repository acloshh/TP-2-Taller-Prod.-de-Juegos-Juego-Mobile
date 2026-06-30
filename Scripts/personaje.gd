extends CharacterBody2D

# --- LA SEÑAL QUE VA A ESCUCHAR EL MUNDO ---
signal jugador_murio
signal vida_extra_usada

@export var velocidad: float = 300
@export var suavizado: float = 0.15
@export var margen: float = 16.0

# --- VARIABLES PARA EL SALTO/REBOTE ---
@export var gravedad: float = 3500
@export var fuerza_rebote: float = -2400 # Valor negativo porque hacia arriba es -Y
@export var fuerza_salto_pared: float = 2500.0 # Fuerza horizontal para el salto del Ninja

# --- VARIABLES DEL IMÁN ---
@onready var area_iman: Area2D = $AreaIman
@onready var colision_iman: CollisionShape2D = $AreaIman/CollisionShape2D
@onready var temporizador_iman: Timer = $TemporizadorIman

# --- VARIABLES DEL JETPACK ---
@onready var temporizador_jetpack: Timer = $TemporizadorJetpack
var jetpack_activo: bool = false
var mascara_colision_original: int = 0
var velocidad_vuelo: float = -3000

# --- VARIABLES DEL FANTASMA ---
@onready var temporizador_fantasma: Timer = $TemporizadorFantasma
var es_fantasma: bool = false

# --- VARIABLES DE LA VIDA EXTRA ---
var vidas_extras: int = 0

# --- VARIABLE DE ANIMACIONES ---
@onready var sprite_animado: AnimatedSprite2D = $Sprite2D

# --- VARIABLES EXTRAS PARA SKINS ---
var es_ninja: bool = false
var pegado_a_pared: bool = false
var puede_saltar_pared: bool = true 
var lado_salto_pared: String = "" 

func _ready() -> void:
	if area_iman != null:
		area_iman.monitoring = false
		
	mascara_colision_original = collision_mask
	
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, true)
	set_collision_mask_value(3, false)
	
	if DatosGlobales.niveles_powerups.has("vida") and DatosGlobales.niveles_powerups["vida"] > 0:
		vidas_extras = 1
	else:
		vidas_extras = 0
		
	match DatosGlobales.skin_actual:
		"base":
			pass 
		"turista":
			gravedad = 2100 
		"saltador":
			fuerza_rebote = -3400 
		"tigreninja":
			es_ninja = true 

func _physics_process(delta: float) -> void:
	var inclinacion_x = Input.get_accelerometer().x
	
	if pegado_a_pared:
		velocity.x = 0 
	else:
		var target_vel_x = inclinacion_x * velocidad
		velocity.x = lerp(velocity.x, target_vel_x, suavizado)
	
	var pantalla_ancho = get_viewport_rect().size.x
	
	if es_ninja:
		if global_position.x >= pantalla_ancho:
			global_position.x = pantalla_ancho
			if not pegado_a_pared and inclinacion_x > 0 and velocity.y >= 0 and puede_saltar_pared:
				pegado_a_pared = true
				
		elif global_position.x <= 0:
			global_position.x = 0
			if not pegado_a_pared and inclinacion_x < 0 and velocity.y >= 0 and puede_saltar_pared:
				pegado_a_pared = true
		else:
			pegado_a_pared = false
	else:
		if global_position.x > pantalla_ancho + margen:
			global_position.x = -margen
		elif global_position.x < -margen:
			global_position.x = pantalla_ancho + margen
			
	if jetpack_activo:
		velocity.y = velocidad_vuelo
	else:
		if pegado_a_pared:
			velocity.y = 0 
		else:
			if not is_on_floor():
				velocity.y += gravedad * delta
				
			if is_on_floor():
				velocity.y = fuerza_rebote
				puede_saltar_pared = true 
				lado_salto_pared = "" 

	if velocity.y >= 0:
		lado_salto_pared = ""
	
	move_and_slide()
	
	if sprite_animado != null:
		var nombre_skin = DatosGlobales.skin_actual
		
		if jetpack_activo:
			sprite_animado.play(nombre_skin + "_normal")
		elif pegado_a_pared:
			sprite_animado.play(nombre_skin + "_normal")
		elif es_ninja and lado_salto_pared != "" and velocity.y < 0:
			sprite_animado.play("tigreninja_pared_" + lado_salto_pared)
		else:
			if velocity.y < 0:
				sprite_animado.play(nombre_skin + "_normal")
			elif velocity.y > 0:
				sprite_animado.play(nombre_skin + "_caida_salto")

func _input(event: InputEvent) -> void:
	if es_ninja and pegado_a_pared:
		if (event is InputEventScreenTouch or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT)) and event.pressed:
			
			velocity.y = fuerza_rebote
			var mitad_pantalla = get_viewport_rect().size.x / 2.0
			
			if global_position.x < mitad_pantalla:
				velocity.x = fuerza_salto_pared
				lado_salto_pared = "izquierda"
			else:
				velocity.x = -fuerza_salto_pared
				lado_salto_pared = "derecha"
				
			pegado_a_pared = false
			puede_saltar_pared = false

# --- SISTEMA DE DAÑO REESCRITO ---
# --- SISTEMA DE DAÑO REESCRITO ---
func recibir_dano() -> void:
	if jetpack_activo or es_fantasma:
		return
		
	if vidas_extras > 0:
		vidas_extras -= 1
		
		# Le damos el mismo súper rebote x1.5 que tiene cuando cae al vacío
		velocity.y = fuerza_rebote * 1.5 
		
		vida_extra_usada.emit() 
		print("¡Me salvó la vida extra en el pincho!")
	else:
		jugador_murio.emit()

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
	
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, false)
	set_collision_mask_value(3, false)
	
	if temporizador_jetpack == null:
		return
		
	var duracion = 1.0 + (1.0 * nivel_jetpack)
	temporizador_jetpack.start(duracion)

func _on_temporizador_jetpack_timeout() -> void:
	jetpack_activo = false
	velocity.y = fuerza_rebote 
	
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
	
	if not jetpack_activo:
		set_collision_mask_value(2, false)
		set_collision_mask_value(3, true)
	
	if temporizador_fantasma != null:
		var duracion = 3.0 + (1.5 * nivel_fantasma)
		temporizador_fantasma.start(duracion)

func _on_temporizador_fantasma_timeout() -> void:
	es_fantasma = false
	modulate.a = 1.0
	
	if not jetpack_activo:
		set_collision_mask_value(2, true)
		set_collision_mask_value(3, false)
