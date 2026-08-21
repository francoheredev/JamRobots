class_name JumpMobility
extends Mobility

## Salto. Si el robot venía avanzando, mantiene ese impulso en el aire
## y se sigue desplazando en esa dirección (ver GDD 8).

const FUERZA := 620.0
## Cuánto del impulso horizontal conserva al despegar.
const IMPULSO_CONSERVADO := 1.15


func _puede_ejecutar() -> bool:
	return robot.is_on_floor()


func _ejecutar() -> void:
	robot.velocity.y = -FUERZA
	robot.velocity.x *= IMPULSO_CONSERVADO
