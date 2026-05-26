extends Control

@export var etiqueta_puntaje_final: Label
@export var etiqueta_mejor_puntaje: Label

func mostrar_resultados(puntos_actuales: int, mejor_puntaje: int) -> void:
	etiqueta_puntaje_final.text = "Puntaje Final: " + str(puntos_actuales)
	etiqueta_mejor_puntaje.text = "Mejor Puntuación: " + str(mejor_puntaje)

func _on_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_boton_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MenuPrincipal.tscn")
