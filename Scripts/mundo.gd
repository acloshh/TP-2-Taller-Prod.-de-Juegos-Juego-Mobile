extends Node2D

@export var plataforma_escena: PackedScene
@export var jugador: CharacterBody2D
@export var camara: Camera2D
@export var ui_game_over: Control

@export var cantidad_inicial: int = 8
@export var distancia_y: float = 350
@export var margen_x: float = 150.0

var altura_actual: float = 0.0

func _ready() -> void:
	if plataforma_escena == null or jugador == null:
		return
		
	altura_actual = jugador.global_position.y - distancia_y
	
	# Plataforma salvavidas inicial
	var primera_plataforma = plataforma_escena.instantiate()
	primera_plataforma.global_position = Vector2(jugador.global_position.x, altura_actual)
	add_child(primera_plataforma)
	
	altura_actual -= distancia_y
	
	for i in range(cantidad_inicial - 1):
		generar_plataforma()

func _process(_delta: float) -> void:
	if jugador != null:
		# 1. Generar plataformas hacia arriba
		if jugador.global_position.y < altura_actual + (distancia_y * 4):
			generar_plataforma()
			
		# 2. Comprobar si el jugador cae por debajo de la visión de la cámara
		if camara != null and ui_game_over != null:
			# Calculamos dónde está el borde inferior de la pantalla sumando un pequeño margen
			var limite_inferior = camara.global_position.y + (get_viewport_rect().size.y / 2.0) + 100.0
			
			if jugador.global_position.y > limite_inferior:
				activar_game_over()

func generar_plataforma() -> void:
	var nueva_plataforma = plataforma_escena.instantiate()
	var ancho_pantalla = get_viewport_rect().size.x
	var x_aleatorio = randf_range(margen_x, ancho_pantalla - margen_x)
	altura_actual -= distancia_y
	nueva_plataforma.global_position = Vector2(x_aleatorio, altura_actual)
	add_child(nueva_plataforma)

func activar_game_over() -> void:
	ui_game_over.show() # Mostramos la pantalla de Game Over
	get_tree().paused = true # Congelamos todas las físicas y movimientos del juego
