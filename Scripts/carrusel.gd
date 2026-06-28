extends Control

@onready var carrusel: HBoxContainer = $ContenedorCarrusel
@onready var boton_go: TextureButton = $BotonJugar

# --- LISTA DE TUS SKINS ---
var skins: Array = ["base", "tigreninja", "turista"] # Nombres para DatosGlobales
var indice_actual: int = 0

# --- VARIABLES PARA EL ARRASTRE ---
var arrastrando: bool = false
var inicio_toque_x: float = 0.0
var posicion_inicio_carrusel: float = 0.0
var x_objetivo: float = 0.0
var ancho_pantalla: float = 1080.0 # Fijamos el ancho de tu pantalla

var umbral_arrastre: float = 60.0

func _ready() -> void:
	# SÚPER IMPORTANTE: Forzamos al motor a salir del estado de pausa al volver al menú
	get_tree().paused = false
	
	x_objetivo = 0.0
	carrusel.position.x = x_objetivo

func _process(delta: float) -> void:
	carrusel.position.x = move_toward(carrusel.position.x, x_objetivo, 2000.0 * delta)

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
					if distancia_arrastre < 0 and indice_actual < skins.size() - 1:
						indice_actual += 1
					elif distancia_arrastre > 0 and indice_actual > 0:
						indice_actual -= 1
				
				x_objetivo = -indice_actual * ancho_pantalla
	
	elif event is InputEventMouseMotion and arrastrando:
		var distancia_arrastre = event.position.x - inicio_toque_x
		carrusel.position.x = posicion_inicio_carrusel + distancia_arrastre

func _on_boton_jugar_pressed() -> void:
	DatosGlobales.skin_equipada = skins[indice_actual]
	get_tree().change_scene_to_file("res://Scenes/mundo.tscn")

func _on_boton_tienda_pressed() -> void:
	# Asegurate de poner la ruta exacta donde guardaste la escena de tu tienda
	get_tree().change_scene_to_file("res://Scenes/tienda.tscn")
