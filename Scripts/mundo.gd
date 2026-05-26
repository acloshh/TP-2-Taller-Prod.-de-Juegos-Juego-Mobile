extends Node2D

@export var plataforma_escena: PackedScene
@export var jugador: CharacterBody2D
@export var camara: Camera2D
@export var ui_game_over: Control
@export var etiqueta_puntos: Label

@export var moneda_escena: PackedScene
@export var etiqueta_monedas: Label

@export var cantidad_inicial: int = 15
@export var distancia_y: float = 420
@export var margen_x: float = 150.0

var altura_actual: float = 0.0
var puntos: int = 0

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

func _process(_delta: float) -> void:
	if jugador != null:
		if jugador.global_position.y < altura_actual + (distancia_y * 4):
			generar_plataforma()
			
		if camara != null and ui_game_over != null:
			var limite_inferior = camara.global_position.y + (get_viewport_rect().size.y / 2.0) + 100.0
			
			if jugador.global_position.y > limite_inferior:
				activar_game_over()

func generar_plataforma() -> void:
	var nueva_plataforma = plataforma_escena.instantiate()
	var ancho_pantalla = get_viewport_rect().size.x
	var x_aleatorio = randf_range(margen_x, ancho_pantalla - margen_x)
	altura_actual -= distancia_y
	nueva_plataforma.global_position = Vector2(x_aleatorio, altura_actual)
	
	nueva_plataforma.plataforma_superada.connect(sumar_punto)
	
	if moneda_escena != null and randi() % 3 == 0:
		var nueva_moneda = moneda_escena.instantiate()
		nueva_moneda.moneda_recogida.connect(sumar_moneda)
		nueva_moneda.position = Vector2(0, -40.0)
		nueva_plataforma.add_child(nueva_moneda)
	
	add_child(nueva_plataforma)

func sumar_point() -> void:
	pass # Nota: mantenemos la consistencia con tus funciones de puntos

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
