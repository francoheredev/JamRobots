class_name Robot
extends CharacterBody2D

## Robot base. Lo usan tanto el jugador como el rival: la única diferencia
## es quién le da las órdenes (nodo de input o nodo de IA).

const GRAVEDAD := 1400.0
const VELOCIDAD_MAX := 240.0
const ACELERACION := 1800.0
const FRICCION := 2400.0
## Reincorporación: alternancia fija W-S (ver GDD 4.4).
const PULSACIONES_PARA_LEVANTARSE := 6
## Piso de duración: aunque complete la secuencia perfecto, tarda esto.
const VOLTEO_MINIMO := 1.0
## Empujón que recibe el robot al ser volteado, para no caer sobre el rival.
const EMPUJE_VOLTEO := Vector2(320.0, -180.0)

## Nodo al que este robot orienta su vista. Lo asigna la arena al empezar.
@export var rival: Node2D

@export var vida_max := 100.0

var vida := 0.0

## Dirección pedida este frame por el nodo de control (-1 a 1).
var _direccion := 0.0

## Mientras está volcado no puede moverse ni atacar (ver GDD 4.3).
var volteado := false

var _pulsaciones := 0
## Cuál de las dos teclas toca ahora. Arranca en arriba.
var _espera_arriba := true
var _tiempo_volcado := 0.0

## Armas equipadas por slot.
var _armas := {}
var _movilidad: Mobility

@onready var visual: Node2D = $Visual
@onready var _mounts := {
	WeaponData.Slot.SUPERIOR: $Visual/MountSuperior,
	WeaponData.Slot.DELANTERO: $Visual/MountDelantero,
	WeaponData.Slot.TRASERO: $Visual/MountTrasero,
}

func _ready() -> void:
	vida = vida_max

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVEDAD * delta

	if volteado:
		_direccion = 0.0
		_tiempo_volcado += delta
		_intentar_levantarse()

	# En el aire casi no frena: el impulso del salto se mantiene (ver GDD 8).
	var freno := FRICCION if is_on_floor() else FRICCION * 0.15
	var acel := ACELERACION if is_on_floor() else ACELERACION * 0.35

	if is_zero_approx(_direccion):
		velocity.x = move_toward(velocity.x, 0.0, freno * delta)
	else:
		velocity.x = move_toward(velocity.x, _direccion * VELOCIDAD_MAX, acel * delta)
	
	move_and_slide()

	if is_on_floor() and not volteado:
		_actualizar_orientacion()

	# El control vuelve a pedir dirección cada frame; si nadie pide, frena.
	_direccion = 0.0


## La llama el nodo de control una vez por frame mientras se quiera avanzar.
func mover(direccion: float) -> void:
	_direccion = clampf(direccion, -1.0, 1.0)


## Punto de montaje donde se instancia el arma de ese slot.
func mount(slot: int) -> Marker2D:
	return _mounts[slot]

## Instancia el arma en su punto de montaje. Si ya había una, la reemplaza.
func equipar(slot: int, datos: WeaponData) -> void:
	if _armas.has(slot):
		_armas[slot].queue_free()
		_armas.erase(slot)

	if datos == null or datos.escena == null:
		return

	var nueva: Weapon = datos.escena.instantiate()
	nueva.data = datos
	nueva.robot = self
	mount(slot).add_child(nueva)
	_armas[slot] = nueva


## La llama el nodo de control. Volteado no puede atacar (ver GDD 4.3),
## y una vez terminado el combate ya nadie ataca.
func activar_arma(slot: int) -> void:
	if not GameManager.esta_en_combate():
		return
	if volteado or esta_destruido() or not _armas.has(slot):
		return
	_armas[slot].activar()


func arma(slot: int) -> Weapon:
	return _armas.get(slot)

## El robot siempre mira al rival, pero solo se reorienta con los pies en
## el piso: si lo salta y cae del otro lado, gira recién al aterrizar.
func _actualizar_orientacion() -> void:
	if rival == null:
		return
	var hacia := signf(rival.global_position.x - global_position.x)
	if hacia != 0.0:
		visual.scale.x = absf(visual.scale.x) * hacia

## slot_origen indica con qué tipo de arma lo golpearon; -1 si no aplica.
func recibir_dano(cantidad: float, slot_origen: int = -1, origen: Vector2 = Vector2.ZERO) -> void:
	if esta_destruido():
		return
	vida = maxf(vida - cantidad, 0.0)
	EventBus.robot_danado.emit(self, cantidad)

	# Golpe de arma superior recibido en el aire: cae volcado (ver GDD 4.3).
	if slot_origen == WeaponData.Slot.SUPERIOR and not is_on_floor():
		voltear(origen)

func esta_destruido() -> bool:
	return vida <= 0.0

## Lo llama quien voltea al robot: paletas, granada o impacto en el aire.
## origen es la posición del atacante, para empujar en sentido contrario.
func voltear(origen: Vector2 = Vector2.ZERO) -> void:
	if volteado or esta_destruido():
		return
	volteado = true
	_pulsaciones = 0
	_espera_arriba = true
	_tiempo_volcado = 0.0
	visual.rotation_degrees = 180.0

	if origen != Vector2.ZERO:
		var lejos := signf(global_position.x - origen.x)
		if lejos == 0.0:
			lejos = 1.0
		velocity.x = lejos * EMPUJE_VOLTEO.x
		velocity.y = EMPUJE_VOLTEO.y

	EventBus.robot_volteado.emit(self)


## La llama el nodo de control con la tecla que se apretó.
## Si es la que tocaba, suma; si no, no pasa nada (ver GDD 4.4).
func pulsar_reincorporacion(es_arriba: bool) -> void:
	if not volteado or es_arriba != _espera_arriba:
		return
	_pulsaciones += 1
	_espera_arriba = not _espera_arriba
	_intentar_levantarse()


func _intentar_levantarse() -> void:
	if _pulsaciones < PULSACIONES_PARA_LEVANTARSE:
		return
	if _tiempo_volcado < VOLTEO_MINIMO:
		return
	volteado = false
	visual.rotation_degrees = 0.0
	_actualizar_orientacion()
	EventBus.robot_reincorporado.emit(self)


## Cuál de las dos teclas toca ahora. La usa el HUD para el indicador.
func espera_arriba() -> bool:
	return _espera_arriba


## Instancia la habilidad de movilidad en su punto de montaje.
## Es un slot único: equipar una reemplaza a la anterior (ver GDD 5.1).
func equipar_movilidad(datos: MobilityData) -> void:
	if _movilidad != null:
		_movilidad.queue_free()
		_movilidad = null

	if datos == null or datos.escena == null:
		return

	var nueva: Mobility = datos.escena.instantiate()
	nueva.data = datos
	nueva.robot = self
	$Visual/MountMovilidad.add_child(nueva)
	_movilidad = nueva


func activar_movilidad() -> void:
	if not GameManager.esta_en_combate():
		return
	if volteado or esta_destruido() or _movilidad == null:
		return
	_movilidad.activar()


func movilidad() -> Mobility:
	return _movilidad
