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

## Cuánto dura la ventana de golpe de la activación genérica (ver _ejecutar).
const DURACION_GOLPE := 0.2

var _cooldown_restante := 0.0
var _puntos := 0
var _golpe_restante := 0.0
var _ya_golpeados: Array[RobotHurtbox] = []

@onready var hitbox: Area2D = $Hitbox
@onready var forma_hitbox: CollisionShape2D = $Hitbox/FormaHitbox


func _ready() -> void:
	hitbox.area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	if _cooldown_restante > 0.0:
		_cooldown_restante = maxf(_cooldown_restante - delta, 0.0)

	if _golpe_restante > 0.0:
		_golpe_restante = maxf(_golpe_restante - delta, 0.0)
		if _golpe_restante <= 0.0:
			forma_hitbox.disabled = true
			_ya_golpeados.clear()


## La llama el robot. Devuelve true si el arma llegó a activarse.
func activar() -> bool:
	if not disponible():
		return false
	_cooldown_restante = data.cooldown()
	_ejecutar()
	EventBus.arma_activada.emit(robot, data.slot)
	return true


## Un robot solo puede ser golpeado una vez por activación de esta arma.
func _on_area_entered(area: Area2D) -> void:
	if not (area is RobotHurtbox):
		return
	var objetivo := area as RobotHurtbox
	if objetivo.robot == robot or objetivo in _ya_golpeados:
		return
	_ya_golpeados.append(objetivo)
	objetivo.robot.recibir_dano(dano())


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


## Cada arma concreta puede sobreescribir esto con su propia animación de
## ataque (arco del martillo, giro de la sierra, chorro del lanzallamas...).
## Por defecto abre la hitbox un instante frente al robot: sirve como golpe
## genérico mientras no haya un arma específica todavía.
func _ejecutar() -> void:
	forma_hitbox.disabled = false
	_golpe_restante = DURACION_GOLPE
