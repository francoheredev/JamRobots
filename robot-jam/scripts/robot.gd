class_name Robot
extends CharacterBody2D

## Robot base. Lo usan tanto el jugador como el rival: la única diferencia
## es quién le da las órdenes (nodo de input o nodo de IA).

const GRAVEDAD := 1400.0
const VELOCIDAD_MAX := 240.0
const ACELERACION := 1800.0
const FRICCION := 2400.0

## Nodo al que este robot orienta su vista. Lo asigna la arena al empezar.
@export var rival: Node2D

@export var vida_max := 100.0

var vida := 0.0

## Dirección pedida este frame por el nodo de control (-1 a 1).
var _direccion := 0.0

## Mientras está volcado no puede moverse ni atacar (ver GDD 4.3).
var volteado := false

## Armas equipadas por slot.
var _armas := {}

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

	if is_zero_approx(_direccion):
		velocity.x = move_toward(velocity.x, 0.0, FRICCION * delta)
	else:
		velocity.x = move_toward(velocity.x, _direccion * VELOCIDAD_MAX, ACELERACION * delta)

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

func recibir_dano(cantidad: float) -> void:
	if esta_destruido():
		return
	vida = maxf(vida - cantidad, 0.0)
	EventBus.robot_danado.emit(self, cantidad)

func esta_destruido() -> bool:
	return vida <= 0.0
