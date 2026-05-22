extends Node2D

@export var plataforma_escena: PackedScene
@export var jugador: CharacterBody2D
@export var camara: Camera2D
@export var ui_game_over: Control
@export var etiqueta_puntos: Label # <-- Nueva variable para la etiqueta

@export var cantidad_inicial: int = 15
@export var distancia_y: float = 350
@export var margen_x: float = 150.0

var altura_actual: float = 0.0
var puntos: int = 0 # <-- Variable para llevar la cuenta
static var mejor_puntaje: int = 0

func _ready() -> void:
	if plataforma_escena == null or jugador == null:
		return
		
	altura_actual = jugador.global_position.y - distancia_y
	
	# Creamos la plataforma inicial y la conectamos
	var primera_plataforma = plataforma_escena.instantiate()
	primera_plataforma.global_position = Vector2(jugador.global_position.x, altura_actual)
	
	# Conectamos la señal para que sume puntos
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
	
	# IMPORTANTE: Conectar la señal de cada plataforma nueva
	nueva_plataforma.plataforma_superada.connect(sumar_punto)
	
	add_child(nueva_plataforma)

# Función que se ejecuta cada vez que una plataforma sale de pantalla
func sumar_punto() -> void:
	puntos += 1
	if etiqueta_puntos != null:
		etiqueta_puntos.text = str(puntos)

func activar_game_over() -> void:
	# 1. Comprobar si superó el récord
	if puntos > mejor_puntaje:
		mejor_puntaje = puntos
	
	# 2. Pasar los datos a la pantalla de Game Over antes de mostrarla
	if ui_game_over.has_method("mostrar_resultados"):
		ui_game_over.mostrar_resultados(puntos, mejor_puntaje)
	
	ui_game_over.show()
	get_tree().paused = true
