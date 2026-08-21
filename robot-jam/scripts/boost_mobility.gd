class_name BoostMobility
extends Mobility

## Turbo. Impulsa al robot hacia adelante a gran velocidad.
## Excluyente con el salto: el slot de movilidad es único (ver GDD 8).
##
## No solo sirve para acercarse o escapar: es lo que habilita el daño
## por velocidad de la Lanza y lo que permite cruzar al otro lado del
## rival para atacarle el arma trasera (ver GDD 10.3).

## Velocidad que alcanza al activarse.
const VELOCIDAD := 720.0
## Cuánto dura el impulso antes de que la fricción lo frene.
const DURACION := 0.35

var _restante := 0.0


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if _restante <= 0.0:
		return

	_restante = maxf(_restante - delta, 0.0)
	# Sostiene la velocidad mientras dura, sin importar la fricción.
	robot.velocity.x = _direccion_actual() * VELOCIDAD


func _ejecutar() -> void:
	_restante = DURACION
	robot.velocity.x = _direccion_actual() * VELOCIDAD


## Hacia dónde impulsa. Si el jugador está pidiendo dirección, respeta esa;
## si no, sale hacia donde el robot está mirando.
func _direccion_actual() -> float:
	var pedida := robot.direccion_pedida()
	if not is_zero_approx(pedida):
		return signf(pedida)
	return signf(robot.visual.scale.x)


## Si el turbo está empujando ahora mismo. Lo va a usar la Lanza.
func impulsando() -> bool:
	return _restante > 0.0
