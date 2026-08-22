class_name AIInput
extends Node

## IA del rival. Usa la misma interfaz que PlayerInput (mover /
## activar_arma / activar_movilidad) porque el Robot no distingue quién
## lo maneja.
##
## Tres principios de diseño:
## 1. No es precisa: apunta con error y a veces yerra a propósito.
## 2. No es instantánea: tarda en reaccionar a lo que hace el jugador.
## 3. No es constante: alterna entre presionar y retroceder, para que la
##    pelea tenga ritmo en vez de ser un empuje continuo.

## Distancia ideal a la que quiere pelear con cada slot.
const DISTANCIA_IDEAL := {
	WeaponData.Slot.SUPERIOR: 95.0,
	WeaponData.Slot.DELANTERO: 85.0,
	WeaponData.Slot.TRASERO: 330.0,
}
## Cuánto se tolera estar lejos del ideal antes de corregir.
const TOLERANCIA := 55.0

## Cada cuánto replantea qué está haciendo.
const INTERVALO_DECISION := Vector2(0.5, 1.1)
## Cuánto tarda en "ver" un cambio del jugador, en segundos.
const REACCION := Vector2(0.15, 0.35)
## Probabilidad de atacar cuando tiene la oportunidad. Menor a 1 para
## que no dispare siempre que puede.
const GANAS_DE_ATACAR := 0.72
## Error de apuntado: fracción de la distancia ideal que puede equivocarse.
const IMPRECISION := 0.22

enum Postura { PRESIONAR, MANTENER, RETROCEDER }

@export var robot: Robot

var _postura := Postura.MANTENER
var _hasta_decidir := 0.0
var _hasta_reaccionar := 0.0
## Posición del jugador tal como la "ve": desactualizada a propósito.
var _vista_rival := Vector2.ZERO
## Agresividad de esta pelea. Se sortea al empezar para que no todos los
## rivales se sientan iguales.
var _agresividad := 0.5


func _ready() -> void:
	_agresividad = randf_range(0.3, 0.85)
	_decidir_postura()


func _physics_process(delta: float) -> void:
	if robot == null or robot.rival == null or robot.esta_destruido():
		return

	if robot.volteado:
		robot.pulsar_reincorporacion(robot.espera_arriba())
		return

	if robot.esta_aturdido():
		return

	_actualizar_vista(delta)

	_hasta_decidir -= delta
	if _hasta_decidir <= 0.0:
		_decidir_postura()

	var distancia: float = absf(_vista_rival.x - robot.global_position.x)
	_mover_segun_postura(distancia)
	_intentar_atacar(distancia)


## La IA no ve al jugador en tiempo real: actualiza su posición recordada
## cada tantos milisegundos. Eso le da un tiempo de reacción humano y
## permite que el jugador la engañe cambiando de dirección.
func _actualizar_vista(delta: float) -> void:
	_hasta_reaccionar -= delta
	if _hasta_reaccionar > 0.0:
		return

	_hasta_reaccionar = randf_range(REACCION.x, REACCION.y)
	var real: Vector2 = robot.rival.global_position

	# Anticipa hacia dónde va el jugador, pero sin exactitud.
	var prediccion: float = robot.rival.velocity.x * randf_range(0.0, 0.35)
	_vista_rival = real + Vector2(prediccion, 0.0)


func _decidir_postura() -> void:
	_hasta_decidir = randf_range(INTERVALO_DECISION.x, INTERVALO_DECISION.y)

	# Con poca vida se vuelve más cautelosa.
	var salud: float = robot.vida / robot.vida_max
	var empuje: float = _agresividad * (0.55 + salud * 0.45)

	var tirada := randf()
	if tirada < empuje:
		_postura = Postura.PRESIONAR
	elif tirada < empuje + 0.25:
		_postura = Postura.MANTENER
	else:
		_postura = Postura.RETROCEDER


func _mover_segun_postura(distancia: float) -> void:
	var hacia := signf(_vista_rival.x - robot.global_position.x)
	if hacia == 0.0:
		hacia = 1.0

	var ideal := _distancia_preferida()

	match _postura:
		Postura.PRESIONAR:
			# Se acerca hasta su distancia ideal y ahí se planta.
			if distancia > ideal - TOLERANCIA:
				robot.mover(hacia)
		Postura.MANTENER:
			# Corrige solo si se salió de la franja cómoda.
			if distancia > ideal + TOLERANCIA:
				robot.mover(hacia)
			elif distancia < ideal - TOLERANCIA:
				robot.mover(-hacia)
		Postura.RETROCEDER:
			robot.mover(-hacia)
			# Usa el turbo para despegarse cuando está muy encima.
			if distancia < ideal * 0.6:
				robot.activar_movilidad()


## Distancia que le conviene según el arma más larga que tenga sana.
func _distancia_preferida() -> float:
	var mejor := 85.0
	for slot in DISTANCIA_IDEAL:
		var arma := robot.arma(slot)
		if arma == null or arma.estado == Weapon.Estado.ROTA:
			continue
		mejor = maxf(mejor, DISTANCIA_IDEAL[slot])
	return mejor


func _intentar_atacar(distancia: float) -> void:
	for slot in DISTANCIA_IDEAL:
		var arma := robot.arma(slot)
		if arma == null or not arma.disponible():
			continue

		var ideal: float = DISTANCIA_IDEAL[slot]
		# Margen de error: a veces tira desde demasiado lejos o cerca.
		var error := ideal * randf_range(-IMPRECISION, IMPRECISION)
		if absf(distancia - ideal + error) > TOLERANCIA:
			continue

		if randf() > GANAS_DE_ATACAR:
			continue

		robot.activar_arma(slot)
		return
