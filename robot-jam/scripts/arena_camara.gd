extends Camera2D

## Cámara de combate: siempre encuadra a los dos robots.
## Se centra entre ambos y se aleja cuando se separan.

@export var robots: Array[Robot] = []

## Margen alrededor de los robots para que no queden pegados al borde.
const MARGEN := 400.0
## Cuánto puede alejarse como máximo. 1.0 es el zoom natural.
const ZOOM_MIN := 0.6
const ZOOM_MAX := 1.0
## Qué tan rápido acompaña el movimiento.
const SUAVIZADO := 6.0

@onready var _alto_pantalla: float = get_viewport_rect().size.x


func _physics_process(delta: float) -> void:
	if robots.size() < 2:
		return

	var a := robots[0].global_position
	var b := robots[1].global_position

	# Centro entre los dos robots.
	var objetivo := (a + b) * 0.5
	global_position = global_position.lerp(objetivo, SUAVIZADO * delta)

	# Zoom según cuánto se separaron.
	var ancho := absf(a.x - b.x) + MARGEN
	var factor := clampf(_alto_pantalla / ancho, ZOOM_MIN, ZOOM_MAX)
	zoom = zoom.lerp(Vector2(factor, factor), SUAVIZADO * delta)
