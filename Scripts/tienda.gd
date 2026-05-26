extends Control

# --- VARIABLES VISUALES ---
@export var etiqueta_monedas: Label

@export var etiqueta_nivel_iman: Label
@export var etiqueta_costo_iman: Label

@export var etiqueta_nivel_jetpack: Label
@export var etiqueta_costo_jetpack: Label

@export var etiqueta_nivel_fantasma: Label
@export var etiqueta_costo_fantasma: Label

@export var etiqueta_nivel_vida: Label
@export var etiqueta_costo_vida: Label

# --- PRECIOS INDIVIDUALES BASE ---
var costos_base: Dictionary = {
	"iman": 100,
	"jetpack": 150,
	"fantasma": 120,
	"vida_extra": 350
}

func _ready() -> void:
	DatosGlobales.total_monedas += 50000
	DatosGlobales.guardar_datos()
	actualizar_tienda()

func actualizar_tienda() -> void:
	if etiqueta_monedas != null:
		etiqueta_monedas.text = "Tus Monedas: " + str(DatosGlobales.total_monedas)
	
	_actualizar_item("iman", etiqueta_nivel_iman, etiqueta_costo_iman)
	_actualizar_item("jetpack", etiqueta_nivel_jetpack, etiqueta_costo_jetpack)
	_actualizar_item("fantasma", etiqueta_nivel_fantasma, etiqueta_costo_fantasma)
	_actualizar_item("vida_extra", etiqueta_nivel_vida, etiqueta_costo_vida)

func _actualizar_item(id_item: String, label_nivel: Label, label_costo: Label) -> void:
	if label_nivel != null and label_costo != null:
		var nivel_actual = DatosGlobales.niveles_powerups[id_item]
		
		# --- CASO ESPECIAL: VIDA EXTRA (Pasiva permanente de nivel 1) ---
		if id_item == "vida_extra":
			if nivel_actual == 0:
				label_nivel.text = "Estado: Bloqueado"
				label_costo.text = "Costo: " + str(costos_base[id_item])
			else:
				label_nivel.text = "Estado: ¡Equipado!"
				label_costo.text = "Costo: MAX"
		else:
			# --- CASO NORMAL: Ítems mejorables con tope en Nivel 5 ---
			if nivel_actual >= 5:
				label_nivel.text = "Nivel: 5 (MAX)"
				label_costo.text = "Costo: MAX"
			else:
				var costo_siguiente = costos_base[id_item] * (nivel_actual + 1)
				label_nivel.text = "Nivel: " + str(nivel_actual)
				label_costo.text = "Costo: " + str(costo_siguiente)

func intentar_compra(id_item: String) -> void:
	var nivel_actual = DatosGlobales.niveles_powerups[id_item]
	
	# Validación de tope para la Vida Extra
	if id_item == "vida_extra" and nivel_actual >= 1:
		print("¡Ya compraste la vida extra, es permanente!")
		return
		
	# Validación de tope para los Power-ups normales (Máximo Nivel 5)
	if id_item != "vida_extra" and nivel_actual >= 5:
		print("¡El " + id_item + " ya está al nivel máximo (5)!")
		return
		
	# Calculamos el costo dependiendo del tipo de ítem
	var costo: int = 0
	if id_item == "vida_extra":
		costo = costos_base[id_item]
	else:
		costo = costos_base[id_item] * (nivel_actual + 1)
	
	if DatosGlobales.total_monedas >= costo:
		DatosGlobales.total_monedas -= costo
		DatosGlobales.niveles_powerups[id_item] += 1
		DatosGlobales.guardar_datos() 
		
		actualizar_tienda()
	else:
		print("¡No te alcanzan las monedas para el " + id_item + "!")

# --- SEÑALES DE LOS BOTONES ---

func _on_boton_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MenuPrincipal.tscn")


func _on_comprar_iman_pressed() -> void:
	intentar_compra("iman")


func _on_comprar_jetpack_pressed() -> void:
	intentar_compra("jetpack")


func _on_comprar_fantasma_pressed() -> void:
	intentar_compra("fantasma")


func _on_comprar_vida_pressed() -> void:
	intentar_compra("vida_extra")
