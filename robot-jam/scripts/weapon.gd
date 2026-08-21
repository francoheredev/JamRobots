class_name Weapon
extends Node2D

## Arma base. Cada arma concreta hereda de esta y sobreescribe _ejecutar().
## Maneja cooldown y durabilidad, que son iguales para todas.

enum Estado { INTACTA, DANADA, ROTA }

## Daño que pierde el arma mientras está dañada (ver GDD 10.4).
const PENALIZACION_DANADA := 0.4
## Cuánto dura la ventana de golpe de la activación genérica.
const DURACION_GOLPE := 0.2

## Datos del arma. Los asigna el robot al equiparla.
var data: WeaponData
var estado := Estado.INTACTA
## Robot que la lleva equipada.
var robot: Robot

var _cooldown_restante := 0.0
var _puntos := 0
var _golpe_restante := 0.0
var _ya_golpeados: Array[RobotHurtbox] = []
var _armas_chocadas: Array[Weapon] = []
var _acerto := false
var _tiempo_dano := 0.0

@onready var hitbox: Area2D = $Hitbox
@onready var forma_hitbox: CollisionShape2D = $Hitbox/FormaHitbox
@onready var sprite: Sprite2D = $Sprite


func _ready() -> void:
	hitbox.area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	if _cooldown_restante > 0.0:
		_cooldown_restante = maxf(_cooldown_restante - delta, 0.0)

	if _golpe_restante > 0.0:
		_revisar_choques()
		_golpe_restante = maxf(_golpe_restante - delta, 0.0)
		if _golpe_restante <= 0.0:
			forma_hitbox.disabled = true
			_ya_golpeados.clear()
			_armas_chocadas.clear()
			_al_cerrar_golpe()
			# Cerró sin tocar nada: erró y se llevó el golpe el terreno.
			if not _acerto and data.desgaste_activo:
				recibir_desgaste(WeaponData.Fuente.TERRENO)


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


## Si la hitbox está abierta ahora mismo.
func golpeando() -> bool:
	return _golpe_restante > 0.0


## Daño real, ya considerando la calidad y el desgaste.
func dano() -> float:
	var base := data.dano()
	return base * (1.0 - PENALIZACION_DANADA) if estado == Estado.DANADA else base


## Un robot solo puede ser golpeado una vez por activación de esta arma.
func _on_area_entered(area: Area2D) -> void:
	if not (area is RobotHurtbox):
		return
	var objetivo := area as RobotHurtbox
	if objetivo.robot == robot or objetivo in _ya_golpeados:
		return
	_ya_golpeados.append(objetivo)
	_acerto = true
	objetivo.robot.recibir_dano(dano(), data.slot, robot.global_position)	


## Detecta armas rivales dentro de la hitbox. Se consulta cada frame porque
## area_entered no dispara si el área ya estaba adentro al abrirse.
func _revisar_choques() -> void:
	for area in hitbox.get_overlapping_areas():
		var otra := area.get_parent() as Weapon
		if otra == null or otra.robot == robot or otra in _armas_chocadas:
			continue

		_armas_chocadas.append(otra)
		_acerto = true

		if otra.golpeando():
			# Las dos se cruzaron atacando: desgaste alto a cada una.
			recibir_desgaste(WeaponData.Fuente.CHOQUE)
		else:
			# Le pegué a un arma que no estaba atacando.
			otra.recibir_desgaste(WeaponData.Fuente.DIRECTO)


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
	_pintar_estado()
	EventBus.arma_desgastada.emit(robot, data.slot, estado)
	if estado == Estado.ROTA:
		EventBus.arma_rota.emit(robot, data.slot)


## Provisorio hasta que arte entregue los sprites por estado (ver GDD 10.8).
func _pintar_estado() -> void:
	match estado:
		Estado.DANADA:
			sprite.modulate = Color(1.0, 0.8, 0.2)
		Estado.ROTA:
			sprite.modulate = Color(0.9, 0.2, 0.2)
		_:
			sprite.modulate = Color.WHITE


## Cada arma concreta puede sobreescribir esto con su propia animación de
## ataque. Por defecto abre la hitbox un instante frente al robot.
func _ejecutar() -> void:
	_acerto = false
	forma_hitbox.disabled = false
	_golpe_restante = DURACION_GOLPE


## Gancho para las armas hijas: se llama al cerrarse la ventana de golpe.
func _al_cerrar_golpe() -> void:
	pass


## Permite que un arma vuelva a golpear a un objetivo que ya tocó.
func _limpiar_golpeados() -> void:
	_ya_golpeados.clear()
