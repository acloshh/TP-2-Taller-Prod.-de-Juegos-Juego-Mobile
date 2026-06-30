extends AnimatableBody2D

@export var velocidad: float = 150.0
@export var mitad_ancho: float = 128.0 # Ajustá esto según el ancho de tu imagen

var direccion: int = 1
var limite_derecho: float = 1080.0

func _ready() -> void:
	limite_derecho = get_viewport_rect().size.x

func _physics_process(delta: float) -> void:
	global_position.x += velocidad * direccion * delta
	
	# Rebota en la derecha SOLO si se está moviendo hacia la derecha (direccion == 1)
	if global_position.x + mitad_ancho >= limite_derecho and direccion == 1:
		direccion = -1
		
	# Rebota en la izquierda SOLO si se está moviendo hacia la izquierda (direccion == -1)
	elif global_position.x - mitad_ancho <= 0 and direccion == -1:
		direccion = 1
