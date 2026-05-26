extends Node

var total_monedas: int = 0
var mejor_puntaje: int = 0

# --- INVENTARIO DE POWER-UPS ---
# 0 = Bloqueado (no sale en el nivel). 1 = Nivel base. 2+ = Mejoras de duración/efecto.
var niveles_powerups: Dictionary = {
	"iman": 0,
	"jetpack": 0,
	"fantasma": 0,
	"vida_extra": 0
}

const RUTA_GUARDADO = "user://partida.save"

func _ready() -> void:
	cargar_datos()

func guardar_datos() -> void:
	var archivo = FileAccess.open(RUTA_GUARDADO, FileAccess.WRITE)
	if archivo:
		var datos = {
			"mejor_puntaje": mejor_puntaje,
			"total_monedas": total_monedas,
			"niveles_powerups": niveles_powerups
		}
		archivo.store_var(datos)

func cargar_datos() -> void:
	if FileAccess.file_exists(RUTA_GUARDADO):
		var archivo = FileAccess.open(RUTA_GUARDADO, FileAccess.READ)
		if archivo:
			var datos = archivo.get_var()
			if datos is Dictionary:
				if datos.has("mejor_puntaje"):
					mejor_puntaje = datos["mejor_puntaje"]
				if datos.has("total_monedas"):
					total_monedas = datos["total_monedas"]
				
				# Cargamos los niveles de los power-ups de forma segura
				if datos.has("niveles_powerups"):
					var powerups_guardados = datos["niveles_powerups"]
					for llave in powerups_guardados.keys():
						if niveles_powerups.has(llave):
							niveles_powerups[llave] = powerups_guardados[llave]
