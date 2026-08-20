class_name Weapon
extends Node2D

## Arma base. Cada arma concreta hereda de esta y sobreescribe _ejecutar().
## Maneja cooldown y durabilidad, que son iguales para todas.

enum Estado { INTACTA, DANADA, ROTA }

## Daño que pierde el arma mientras está dañada (ver GDD 10.4).
const PENALIZACION_DANADA := 0.4

## Datos del arma. Los asigna el robot al equiparla.
var data: WeaponData
var estado := Estado.INTACTA
## Robot que la lleva equipada.
var robot: Robot

var _cooldown_restante := 0.0
var _puntos := 0


func _process(delta: float) -> void:
	if _cooldown_restante > 0.0:
		_cooldown_restante = maxf(_cooldown_restante - delta, 0.0)


## La llama el robot. Devuelve true si el arma llegó a activarse.
func activar() -> bool:
	if not disponible():
		return false
	_cooldown_restante = data.cooldown()
	_ejecutar()
	EventBus.arma_activada.emit(robot, data.slot)
	return true


func disponible() -> bool:
	return estado != Estado.ROTA and _cooldown_restante <= 0.0


## Daño real, ya considerando la calidad y el desgaste.
func dano() -> float:
	var base := data.dano()
	return base * (1.0 - PENALIZACION_DANADA) if estado == Estado.DANADA else base


## Suma puntos de desgaste de una fuente y actualiza el estado (ver GDD 10.5).
func recibir_desgaste(fuente: WeaponData.Fuente) -> void:
	if estado == Estado.ROTA:
		return

	_puntos += WeaponData.COSTO_DESGASTE[fuente]

	var nuevo := estado
	if _puntos >= data.umbral_rota():
		nuevo = Estado.ROTA
	elif _puntos >= data.umbral_danada():
		nuevo = Estado.DANADA

	if nuevo == estado:
		return

	estado = nuevo
	EventBus.arma_desgastada.emit(robot, data.slot, estado)
	if estado == Estado.ROTA:
		EventBus.arma_rota.emit(robot, data.slot)


## Cada arma concreta define acá su ataque.
func _ejecutar() -> void:
	# Provisorio: el daño real va a salir de la hitbox del arma.
	# Por ahora golpea directo al rival para poder probar el combate.
	var objetivo := robot.rival as Robot
	if objetivo == null or objetivo.esta_destruido():
		return
	objetivo.recibir_dano(dano())
	print("%s golpea por %.0f. Vida rival: %.0f" % [data.nombre, dano(), objetivo.vida])
