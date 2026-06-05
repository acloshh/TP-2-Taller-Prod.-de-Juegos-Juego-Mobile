extends Node2D

@export var plataforma_escena: PackedScene
@export var escena_plataforma_piedra: PackedScene
@export var jugador: CharacterBody2D
@export var camara: Camera2D
@export var ui_game_over: Control
@export var etiqueta_puntos: Label

@export var moneda_escena: PackedScene
@export var etiqueta_monedas: Label
@export var escena_item_iman: PackedScene
@export var escena_item_jetpack: PackedScene

@export var cantidad_inicial: int = 15
@export var distancia_y: float = 420
@export var margen_x: float = 150.0

# --- NUEVA VARIABLE PARA CALIBRAR LA CÁMARA ---
# A mayor número, más rápido sigue la cámara. Un valor entre 5 y 10 suele estar bien.
@export var velocidad_seguimiento_camara: float = 8.0 

var altura_actual: float = 0.0
var puntos: int = 0
var plataformas_generadas: int = 0

func _ready() -> void:
	# Mostramos el total de monedas guardadas apenas arranca el juego, leyéndolas del Autoload
	if etiqueta_monedas != null:
		etiqueta_monedas.text = "Monedas: " + str(DatosGlobales.total_monedas)
		
	if plataforma_escena == null or jugador == null:
		return
		
	altura_actual = jugador.global_position.y - distancia_y
	
	var primera_plataforma = plataforma_escena.instantiate()
	primera_plataforma.global_position = Vector2(jugador.global_position.x, altura_actual)
	primera_plataforma.plataforma_superada.connect(sumar_punto)
	add_child(primera_plataforma)
	
	altura_actual -= distancia_y
	
	for i in range(cantidad_inicial - 1):
		generar_plataforma()

func _process(delta: float) -> void:
	if jugador != null and camara != null:
		# --- NUEVA LÓGICA: LA CÁMARA SIGUE AL JUGADOR HACIA ARRIBA ---
		# Usamos lerp (interpolación lineal) para que el movimiento sea suave, 
		# especialmente cuando el jetpack pega el tirón hacia arriba.
		# Solo nos interesa mover la cámara en Y (verticalmente).
		var destino_y = jugador.global_position.y
		camara.global_position.y = lerp(camara.global_position.y, destino_y, velocidad_seguimiento_camara * delta)

		# --- GENERACIÓN DE PLATAFORMAS (Lógica original) ---
		if jugador.global_position.y < altura_actual + (distancia_y * 4):
			generar_plataforma()
			
		# --- VERIFICACIÓN DE GAME OVER (Lógica original) ---
		if ui_game_over != null:
			# El límite inferior ahora se mueve correctamente con la cámara actual
			var limite_inferior = camara.global_position.y + (get_viewport_rect().size.y / 2.0) + 100.0
			
			if jugador.global_position.y > limite_inferior:
				activar_game_over()

func generar_plataforma() -> void:
	plataformas_generadas += 1
	var nueva_plataforma: Node2D
	
	if plataformas_generadas >= 75 and escena_plataforma_piedra != null and randf() < 0.25:
		nueva_plataforma = escena_plataforma_piedra.instantiate()
	else:
		nueva_plataforma = plataforma_escena.instantiate()
		
	var ancho_pantalla = get_viewport_rect().size.x
	var x_aleatorio = randf_range(margen_x, ancho_pantalla - margen_x)
	altura_actual -= distancia_y
	nueva_plataforma.global_position = Vector2(x_aleatorio, altura_actual)
	
	# Aseguramos que la señal se conecte sea cual sea la plataforma instanciada
	if nueva_plataforma.has_signal("plataforma_superada"):
		nueva_plataforma.plataforma_superada.connect(sumar_punto)
	
	# --- SISTEMA DE BALANCEO (Porcentajes exactos) ---
	var nivel_iman = DatosGlobales.niveles_powerups["iman"]
	var nivel_jetpack = DatosGlobales.niveles_powerups["jetpack"]
	var dado = randf() 
	
	# 2% de probabilidad de Imán
	if dado < 0.02 and escena_item_iman != null and nivel_iman > 0:
		var nuevo_iman = escena_item_iman.instantiate()
		nuevo_iman.position = Vector2(0, -50.0)
		nueva_plataforma.add_child(nuevo_iman)
		
	# 2% de probabilidad de Jetpack
	elif dado >= 0.02 and dado < 0.04 and escena_item_jetpack != null and nivel_jetpack > 0:
		var nuevo_jetpack = escena_item_jetpack.instantiate()
		nuevo_jetpack.position = Vector2(0, -50.0)
		nueva_plataforma.add_child(nuevo_jetpack)
		
	# 50% de probabilidad de Moneda
	elif dado >= 0.04 and dado < 0.54 and moneda_escena != null:
		var nueva_moneda = moneda_escena.instantiate()
		nueva_moneda.moneda_recogida.connect(sumar_moneda)
		nueva_moneda.position = Vector2(0, -40.0)
		nueva_plataforma.add_child(nueva_moneda)
	
	add_child(nueva_plataforma)

func sumar_point() -> void:
	pass

func sumar_punto() -> void:
	puntos += 1
	if etiqueta_puntos != null:
		etiqueta_puntos.text = str(puntos)

func sumar_moneda() -> void:
	# Sumamos directamente al Autoload
	DatosGlobales.total_monedas += 1
	if etiqueta_monedas != null:
		etiqueta_monedas.text = "Monedas: " + str(DatosGlobales.total_monedas)

func activar_game_over() -> void:
	# Comparamos y guardamos el récord usando el Autoload
	if puntos > DatosGlobales.mejor_puntaje:
		DatosGlobales.mejor_puntaje = puntos
	
	# Le decimos al Autoload que guarde todo
	DatosGlobales.guardar_datos()
	
	if ui_game_over.has_method("mostrar_resultados"):
		ui_game_over.mostrar_resultados(puntos, DatosGlobales.mejor_puntaje)
	
	ui_game_over.show()
	get_tree().paused = true
