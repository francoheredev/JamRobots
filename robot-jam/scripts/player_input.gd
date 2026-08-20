class_name PlayerInput
extends Node

## Traduce el teclado en órdenes para el robot.
## El robot nunca lee input directo: por eso el mismo robot lo puede
## manejar también la IA del rival (ver GDD 12.2).

@export var robot: Robot


func _physics_process(_delta: float) -> void:
	if robot == null:
		return

	if robot.volteado:
		if Input.is_action_just_pressed("recomponerse_arriba"):
			robot.pulsar_reincorporacion(true)
		if Input.is_action_just_pressed("recomponerse_abajo"):
			robot.pulsar_reincorporacion(false)
		return

	robot.mover(Input.get_axis("mover_izquierda", "mover_derecha"))

	if Input.is_action_just_pressed("arma_superior"):
		robot.activar_arma(WeaponData.Slot.SUPERIOR)
	if Input.is_action_just_pressed("arma_delantera"):
		robot.activar_arma(WeaponData.Slot.DELANTERO)
	if Input.is_action_just_pressed("arma_trasera"):
		robot.activar_arma(WeaponData.Slot.TRASERO)

	if Input.is_key_pressed(KEY_V):
		robot.voltear()
