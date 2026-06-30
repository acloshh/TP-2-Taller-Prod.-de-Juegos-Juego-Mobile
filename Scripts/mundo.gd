extends Node2D

@export var escena_madera: PackedScene
@export var escena_madera_movil: PackedScene
@export var escena_plataforma_piedra: PackedScene
@export var escena_piedra_movil: PackedScene
@export var escena_pinchos: PackedScene

@export var popup_logro: Control
@export var etiqueta_mensaje_logro: Label

@export var jugador: CharacterBody2D
@export var camara: Camera2D
@export var ui_game_over: Control
@export var etiqueta_puntos: Label

@export var moneda_escena: PackedScene
@export var etiqueta_monedas: Label
@export var escena_item_iman: PackedScene
@export var escena_item_jetpack: PackedScene
@export var escena_item_fantasma: PackedScene

@export var icono_vida_extra: TextureRect

@export var cantidad_inicial: int = 15
@export var distancia_y: float = 420
@export var margen_x: float = 150.0
@export var velocidad_seguimiento_camara: float = 8.0 

var altura_actual: float = 0.0
var puntos: int = 0
var plataformas_generadas: int = 0

func _ready() -> void:
	# Inicialización visual básica
	if etiqueta_monedas != null: etiqueta_monedas.text = str(DatosGlobales.total_monedas)
	
	if icono_vida_extra != null:
		icono_vida_extra.visible = (DatosGlobales.niveles_powerups.has("vida") and DatosGlobales.niveles_powerups["vida"] > 0)
		icono_vida_extra.modulate = Color(1, 1, 1, 1)

	if escena_madera == null or jugador == null: return
	
	# Conexión segura de la señal
	jugador.vida_extra_usada.connect(_on_jugador_vida_extra_usada)
		
	altura_actual = jugador.global_position.y - distancia_y
	
	var primera_plataforma = escena_madera.instantiate()
	primera_plataforma.global_position = Vector2(jugador.global_position.x, altura_actual)
	if primera_plataforma.has_signal("plataforma_superada"):
		primera_plataforma.plataforma_superada.connect(sumar_punto)
	add_child(primera_plataforma)
	
	altura_actual -= distancia_y
	for i in range(cantidad_inicial - 1):
		generar_plataforma()

func _process(delta: float) -> void:
	if jugador != null and camara != null:
		var destino_y = jugador.global_position.y
		if destino_y < camara.global_position.y:
			camara.global_position.y = lerp(camara.global_position.y, destino_y, velocidad_seguimiento_camara * delta)

		while jugador.global_position.y < altura_actual + (distancia_y * 6):
			generar_plataforma()
			
		if ui_game_over != null:
			var limite_inferior = camara.global_position.y + (get_viewport_rect().size.y / 2.0) + 100.0
			if jugador.global_position.y > limite_inferior:
				if jugador.vidas_extras > 0:
					jugador.vidas_extras -= 1
					jugador.global_position.y = limite_inferior - 50.0
					jugador.velocity.y = jugador.fuerza_rebote * 1.5
					_on_jugador_vida_extra_usada()
				else:
					activar_game_over()

func generar_plataforma() -> void:
	plataformas_generadas += 1
	var escena_elegida = elegir_plataforma_aleatoria(puntos)
	var nueva_plataforma = escena_elegida.instantiate()
		
	var ancho_pantalla = get_viewport_rect().size.x
	var x_aleatorio = randf_range(margen_x, ancho_pantalla - margen_x)
	altura_actual -= distancia_y
	nueva_plataforma.global_position = Vector2(x_aleatorio, altura_actual)
	
	if randf() < calcular_probabilidad_pinchos(puntos) and escena_pinchos != null:
		var pinchos = escena_pinchos.instantiate()
		pinchos.position = Vector2(0, -39)
		nueva_plataforma.add_child(pinchos)
	
	if nueva_plataforma.has_signal("plataforma_superada"):
		nueva_plataforma.plataforma_superada.connect(sumar_punto)
	
	add_child(nueva_plataforma)

func elegir_plataforma_aleatoria(puntos_actuales: int) -> PackedScene:
	var prob = randf()
	if puntos_actuales < 50: return escena_madera
	if puntos_actuales < 120: return escena_madera if prob < 0.7 else escena_madera_movil
	if puntos_actuales < 250:
		if prob < 0.4: return escena_madera
		if prob < 0.7: return escena_madera_movil
		if prob < 0.9: return escena_plataforma_piedra
		return escena_piedra_movil
	return escena_piedra_movil

func calcular_probabilidad_pinchos(puntos_actuales: int) -> float:
	if puntos_actuales < 75: return 0.0
	if puntos_actuales < 120: return 0.1
	if puntos_actuales < 250: return 0.25
	return 0.35

func sumar_punto() -> void:
	puntos += 1
	if etiqueta_puntos != null: etiqueta_puntos.text = str(puntos)

func sumar_moneda() -> void:
	DatosGlobales.total_monedas += 1
	if etiqueta_monedas != null: etiqueta_monedas.text = str(DatosGlobales.total_monedas)

func verificar_logros(puntos_finales: int) -> int:
	var ganadas: int = 0
	if puntos_finales >= 50 and not 50 in DatosGlobales.logros_reclamados:
		DatosGlobales.logros_reclamados.append(50); ganadas += 50
	if puntos_finales >= 150 and not 150 in DatosGlobales.logros_reclamados:
		DatosGlobales.logros_reclamados.append(150); ganadas += 100
	if ganadas > 0: DatosGlobales.total_gemas += ganadas
	return ganadas

func activar_game_over() -> void:
	if puntos > DatosGlobales.mejor_puntaje: DatosGlobales.mejor_puntaje = puntos
	var gemas = verificar_logros(puntos)
	DatosGlobales.guardar_datos()
	
	if gemas > 0 and popup_logro != null:
		etiqueta_mensaje_logro.text = "¡LOGRO DESBLOQUEADO!\nGanaste " + str(gemas) + " Gemas"
		
		# Ajuste de visibilidad forzada
		popup_logro.visible = true 
		
		# Pausamos el mundo
		get_tree().paused = true 
	else:
		mostrar_pantalla_game_over()

func mostrar_pantalla_game_over() -> void:
	if ui_game_over.has_method("mostrar_resultados"):
		ui_game_over.mostrar_resultados(puntos, DatosGlobales.mejor_puntaje)
	ui_game_over.show(); get_tree().paused = true

func _on_character_body_2d_jugador_murio() -> void:
	activar_game_over()

func _on_jugador_vida_extra_usada() -> void:
	if icono_vida_extra != null: icono_vida_extra.modulate = Color(0.4, 0.4, 0.4, 0.5)

func _on_boton_continuar_logro_pressed() -> void:
	get_tree().paused = false # Despausamos ANTES de cambiar estados
	popup_logro.visible = false
	mostrar_pantalla_game_over()
