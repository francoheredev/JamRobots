class_name AIInput
extends Node

## IA de prueba mínima: camina hacia el rival y ataca en rango corto.
## Usa la misma interfaz que PlayerInput (mover / activar_arma) porque el
## Robot no distingue quién lo maneja (ver player_input.gd).

const RANGO_ATAQUE := 70.0

@export var robot: Robot
@export var slot_ataque: WeaponData.Slot = WeaponData.Slot.SUPERIOR


func _physics_process(_delta: float) -> void:
	if robot == null or robot.rival == null or robot.esta_destruido():
		return

	var hacia_rival := robot.rival.global_position.x - robot.global_position.x
	var distancia := absf(hacia_rival)

	if distancia > RANGO_ATAQUE:
		robot.mover(signf(hacia_rival))
	else:
		robot.mover(0.0)
		robot.activar_arma(slot_ataque)
