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
@export var escena_item_fantasma: PackedScene

# --- NUEVA VARIABLE PARA EL ÍCONO ---
@export var icono_vida_extra: TextureRect

@export var cantidad_inicial: int = 15
@export var distancia_y: float = 420
@export var margen_x: float = 150.0

@export var velocidad_seguimiento_camara: float = 8.0 

var altura_actual: float = 0.0
var puntos: int = 0
var plataformas_generadas: int = 0

func _ready() -> void:
	if etiqueta_monedas != null:
		etiqueta_monedas.text = str(DatosGlobales.total_monedas)
		
	# --- LÓGICA VISUAL DEL CORAZÓN ---
	# Si conectamos el ícono, chequeamos si el power-up está comprado
	if icono_vida_extra != null:
		if DatosGlobales.niveles_powerups.has("vida") and DatosGlobales.niveles_powerups["vida"] > 0:
			icono_vida_extra.visible = true
			# Modulate a blanco puro y 100% de opacidad (estado normal)
			icono_vida_extra.modulate = Color(1, 1, 1, 1)
		else:
			# Si no lo tiene comprado, ni siquiera lo mostramos
			icono_vida_extra.visible = false
		
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
					
					# --- APAGAMOS EL ÍCONO ---
					# Lo volvemos gris y le bajamos la transparencia (Canal Alfa) al 50%
					if icono_vida_extra != null:
						icono_vida_extra.modulate = Color(0.4, 0.4, 0.4, 0.5)
					
					print("¡Salvado por el power-up pasivo! Vidas restantes esta run: ", jugador.vidas_extras)
				else:
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
	
	if nueva_plataforma.has_signal("plataforma_superada"):
		nueva_plataforma.plataforma_superada.connect(sumar_punto)
	
	var nivel_iman = DatosGlobales.niveles_powerups["iman"]
	var nivel_jetpack = DatosGlobales.niveles_powerups["jetpack"]
	var nivel_fantasma = DatosGlobales.niveles_powerups["fantasma"]
	var dado = randf() 
	
	if dado < 0.02 and escena_item_iman != null and nivel_iman > 0:
		var nuevo_iman = escena_item_iman.instantiate()
		nuevo_iman.position = Vector2(0, -50.0)
		nueva_plataforma.add_child(nuevo_iman)
		
	elif dado >= 0.02 and dado < 0.04 and escena_item_jetpack != null and nivel_jetpack > 0:
		var nuevo_jetpack = escena_item_jetpack.instantiate()
		nuevo_jetpack.position = Vector2(0, -50.0)
		nueva_plataforma.add_child(nuevo_jetpack)
		
	elif dado >= 0.04 and dado < 0.06 and escena_item_fantasma != null and nivel_fantasma > 0:
		var nuevo_fantasma = escena_item_fantasma.instantiate()
		nuevo_fantasma.position = Vector2(0, -50.0)
		nueva_plataforma.add_child(nuevo_fantasma)
		
	elif dado >= 0.06 and dado < 0.56 and moneda_escena != null:
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
	DatosGlobales.total_monedas += 1
	if etiqueta_monedas != null:
		etiqueta_monedas.text = str(DatosGlobales.total_monedas)

func activar_game_over() -> void:
	if puntos > DatosGlobales.mejor_puntaje:
		DatosGlobales.mejor_puntaje = puntos
	
	DatosGlobales.guardar_datos()
	
	if ui_game_over.has_method("mostrar_resultados"):
		ui_game_over.mostrar_resultados(puntos, DatosGlobales.mejor_puntaje)
	
	ui_game_over.show()
	get_tree().paused = true
