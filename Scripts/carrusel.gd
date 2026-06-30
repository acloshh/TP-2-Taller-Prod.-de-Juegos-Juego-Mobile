extends Control

@onready var carrusel: HBoxContainer = $ContenedorCarrusel
@onready var boton_go: TextureButton = $BotonJugar
@onready var boton_desbloquear: TextureButton = $BotonDesbloquear
@onready var etiqueta_gemas: Label = $ContenedorGemas/EtiquetaGemas

# --- LISTA Y PRECIOS DE SKINS ---
var skins: Array = ["base", "turista", "tigreninja", "saltador"]
var precios: Dictionary = {
	"base": 0,
	"turista": 50,
	"tigreninja": 100,
	"saltador": 200
}
var indice_actual: int = 1 

# --- VARIABLES PARA EL ARRASTRE ---
var arrastrando: bool = false
var inicio_toque_x: float = 0.0
var posicion_inicio_carrusel: float = 0.0
var x_objetivo: float = 0.0
var ancho_pantalla: float = 1080.0
var umbral_arrastre: float = 60.0

# --- SEGURIDAD CONTRA CLICK FANTASMA ---
var recientemente_desbloqueado: bool = false

func _ready() -> void:
	get_tree().paused = false
	ancho_pantalla = get_viewport().get_visible_rect().size.x
	
	# TRUCO DE DEBUG: 1000 gemas para pruebas
	DatosGlobales.total_gemas += 1000
	DatosGlobales.guardar_datos()
	
	actualizar_texto_gemas()
	
	# 1. APLICAR DESBLOQUEOS ANTES DE CLONAR
	for i in range(carrusel.get_child_count()):
		var tarjeta_skin = carrusel.get_child(i)
		var nombre_skin = skins[i]
		var esta_desbloqueada = nombre_skin in DatosGlobales.skins_desbloqueadas
		
		var imagen = tarjeta_skin.get_node_or_null("ImagenPersonaje")
		var icono_pregunta = tarjeta_skin.get_node_or_null("IconoPregunta")
		
		if not esta_desbloqueada:
			if imagen != null:
				imagen.modulate = Color(0.1, 0.1, 0.1, 0.8)
			if icono_pregunta != null:
				icono_pregunta.visible = true
		else:
			if imagen != null:
				imagen.modulate = Color(1, 1, 1, 1)
			if icono_pregunta != null:
				icono_pregunta.visible = false
				
	# 2. CLONACIÓN
	var primer_hijo = carrusel.get_child(0).duplicate()
	var ultimo_hijo = carrusel.get_child(carrusel.get_child_count() - 1).duplicate()
	
	carrusel.add_child(ultimo_hijo)
	carrusel.move_child(ultimo_hijo, 0)
	carrusel.add_child(primer_hijo)
	
	for tarjeta in carrusel.get_children():
		tarjeta.custom_minimum_size.x = ancho_pantalla
	
	x_objetivo = -indice_actual * ancho_pantalla
	carrusel.position.x = x_objetivo

func _process(delta: float) -> void:
	carrusel.position.x = move_toward(carrusel.position.x, x_objetivo, 2000.0 * delta)
	
	# --- 3. LÓGICA DE BOTONES JUGAR / DESBLOQUEAR ---
	var indice_real = indice_actual - 1
	if indice_real < 0:
		indice_real = skins.size() - 1
	elif indice_real >= skins.size():
		indice_real = 0
		
	var skin_en_pantalla = skins[indice_real]
	var precio_actual = precios[skin_en_pantalla]
	
	if skin_en_pantalla in DatosGlobales.skins_desbloqueadas:
		boton_go.visible = true
		boton_desbloquear.visible = false
		
		# Si se acaba de comprar, lo congelamos un instante para evitar el avance directo
		if recientemente_desbloqueado:
			boton_go.disabled = true
		else:
			boton_go.disabled = false
			boton_go.modulate = Color(1, 1, 1, 1)
	else:
		boton_go.visible = false
		boton_desbloquear.visible = true
		
		if DatosGlobales.total_gemas >= precio_actual:
			boton_desbloquear.disabled = false
			boton_desbloquear.modulate = Color(1, 1, 1, 1)
		else:
			boton_desbloquear.disabled = true
			boton_desbloquear.modulate = Color(0.4, 0.4, 0.4, 0.5)
	
	# --- TELETRANSPORTE INVISIBLE ---
	if carrusel.position.x == x_objetivo and not arrastrando:
		if indice_actual == 0:
			indice_actual = skins.size()
			x_objetivo = -indice_actual * ancho_pantalla
			carrusel.position.x = x_objetivo
		elif indice_actual == skins.size() + 1:
			indice_actual = 1
			x_objetivo = -indice_actual * ancho_pantalla
			carrusel.position.x = x_objetivo

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				arrastrando = true
				inicio_toque_x = event.position.x
				posicion_inicio_carrusel = carrusel.position.x
			else:
				arrastrando = false
				var distancia_arrastre = event.position.x - inicio_toque_x
				
				if abs(distancia_arrastre) > umbral_arrastre:
					if distancia_arrastre < 0:
						indice_actual += 1
					elif distancia_arrastre > 0:
						indice_actual -= 1
				
				x_objetivo = -indice_actual * ancho_pantalla
	
	elif event is InputEventMouseMotion and arrastrando:
		var distancia_arrastre = event.position.x - inicio_toque_x
		carrusel.position.x = posicion_inicio_carrusel + distancia_arrastre

func _on_boton_jugar_pressed() -> void:
	var indice_real = indice_actual - 1
	if indice_real < 0:
		indice_real = skins.size() - 1
	elif indice_real >= skins.size():
		indice_real = 0
		
	DatosGlobales.skin_actual = skins[indice_real]
	DatosGlobales.guardar_datos()
	get_tree().change_scene_to_file("res://Scenes/mundo.tscn")

# --- FUNCIÓN DE COMPRA MODIFICADA ---
func _on_boton_desbloquear_pressed() -> void:
	var indice_real = indice_actual - 1
	if indice_real < 0:
		indice_real = skins.size() - 1
	elif indice_real >= skins.size():
		indice_real = 0
		
	var skin_a_comprar = skins[indice_real]
	var precio = precios[skin_a_comprar]
	
	if DatosGlobales.total_gemas >= precio and not skin_a_comprar in DatosGlobales.skins_desbloqueadas:
		# Activamos la protección antes de realizar la transacción
		recientemente_desbloqueado = true
		
		DatosGlobales.total_gemas -= precio
		DatosGlobales.skins_desbloqueadas.append(skin_a_comprar)
		DatosGlobales.guardar_datos()
		
		actualizar_texto_gemas()
		print("¡Skin ", skin_a_comprar, " comprada con éxito!")
		
		for tarjeta in carrusel.get_children():
			if tarjeta.name.to_lower().contains(skin_a_comprar):
				var imagen = tarjeta.get_node_or_null("ImagenPersonaje")
				var icono = tarjeta.get_node_or_null("IconoPregunta")
				if imagen != null:
					imagen.modulate = Color(1, 1, 1, 1)
				if icono != null:
					icono.visible = false
					
		# Esperamos 0.1 segundos y liberamos el botón para que ya se pueda presionar
		await get_tree().create_timer(0.1).timeout
		recientemente_desbloqueado = false

func actualizar_texto_gemas() -> void:
	if etiqueta_gemas != null:
		etiqueta_gemas.text = str(DatosGlobales.total_gemas)

func _on_boton_tienda_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/tienda.tscn")
