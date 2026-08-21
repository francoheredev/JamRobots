class_name Mobility
extends Node2D

## Habilidad de movilidad base. Maneja el cooldown; cada habilidad
## concreta define qué hace en _ejecutar().

var data: MobilityData
var robot: Robot

var _cooldown_restante := 0.0


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
