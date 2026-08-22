class_name Mobility
extends Node2D

## Habilidad de movilidad base. Maneja el cooldown; cada habilidad
## concreta define qué hace en _ejecutar().

var data: MobilityData
var robot: Robot

var _cooldown_restante := 0.0

@onready var sprite: Polygon2D = $Sprite


func _ready() -> void:
	_dibujar_forma()


## Dibuja la habilidad como su forma (hexágono) coloreada según el tipo
## (ver MobilityData.forma y color). Antes no había ningún visual acá.
func _dibujar_forma() -> void:
	const RADIO := 22.0
	var puntos := PackedVector2Array()
	for punto in data.forma():
		puntos.append(punto * RADIO)
	sprite.polygon = puntos
	sprite.color = data.color()


func _physics_process(delta: float) -> void:
	if _cooldown_restante > 0.0:
		_cooldown_restante = maxf(_cooldown_restante - delta, 0.0)


## La llama el robot. Devuelve true si llegó a activarse.
func activar() -> bool:
	if not disponible():
		return false
	if not _puede_ejecutar():
		return false
	_cooldown_restante = data.cooldown()
	_ejecutar()
	return true


func disponible() -> bool:
	return _cooldown_restante <= 0.0


## Condición extra propia de cada habilidad. El salto la usa para exigir piso.
func _puede_ejecutar() -> bool:
	return true


func _ejecutar() -> void:
	pass
