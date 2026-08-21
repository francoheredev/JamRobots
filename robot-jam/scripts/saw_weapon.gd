class_name SawWeapon
extends Weapon

## Sierra circular. A diferencia del martillo, mantiene la hitbox abierta
## varios segundos y hace daño repetido mientras el rival siga en contacto
## (ver GDD 6.1).

## Cuánto dura girando.
const DURACION := 2.5
## Cada cuánto vuelve a hacer daño al mismo objetivo.
const INTERVALO_DANO := 0.4
## Vueltas por segundo del sprite mientras gira.
const VELOCIDAD_GIRO := 12.0

var _girando := false


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if _girando:
		_tiempo_dano += delta
		if _tiempo_dano >= INTERVALO_DANO:
			_tiempo_dano = 0.0
			_danar_a_los_que_siguen_dentro()


func _ejecutar() -> void:
	_acerto = false
	_girando = true
	forma_hitbox.disabled = false
	_golpe_restante = DURACION
	# La sierra baja delante del robot mientras está activa.
	position.y += 15.0


## Al cerrarse la ventana, la sierra vuelve a su lugar y deja de girar.
func _al_cerrar_golpe() -> void:
	_girando = false
	sprite.rotation = 0.0
	position.y -= 15.0

## La hitbox no vuelve a emitir area_entered si el rival ya estaba adentro,
## así que preguntamos directamente quién sigue en contacto.
func _danar_a_los_que_siguen_dentro() -> void:
	for area in hitbox.get_overlapping_areas():
		var hurtbox := area as RobotHurtbox
		if hurtbox == null or hurtbox.robot == robot:
			continue
		if hurtbox.robot.esta_destruido():
			continue
		_acerto = true
		hurtbox.robot.recibir_dano(dano(), data.slot)
