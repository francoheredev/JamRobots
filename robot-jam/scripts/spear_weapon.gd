class_name SpearWeapon
extends Weapon

## Lanza. Hace daño cuando el jugador carga hacia adelante: a mayor
## velocidad de embestida, mayor el daño (ver GDD 6.2).
##
## Es el arma que le da un segundo uso al turbo: sin él, la Lanza pega
## como cualquier arma común. Con turbo, es la que más daño hace del juego.

## Duración de la estocada.
const DURACION := 0.3

## Velocidad desde la que empieza a sumar daño. Por debajo, pega el mínimo.
const VELOCIDAD_MINIMA := 180.0
## Velocidad a la que llega al daño máximo. Coincide con la del turbo.
const VELOCIDAD_MAXIMA := 720.0

## Multiplicadores de daño en los dos extremos.
const FACTOR_MINIMO := 0.4
const FACTOR_MAXIMO := 2.0

## Solo cuenta la velocidad hacia adelante: retroceder no carga la lanza.
var _factor := FACTOR_MINIMO


func _ejecutar() -> void:
	_acerto = false
	forma_hitbox.disabled = false
	_golpe_restante = DURACION
	_factor = _factor_por_velocidad()


## El daño se calcula al activar, no al impactar: la velocidad que cuenta
## es la del momento de la estocada, y así frenar en el aire no la anula.
func dano() -> float:
	return super.dano() * _factor


func _factor_por_velocidad() -> float:
	var hacia := signf(robot.visual.scale.x)
	# Velocidad proyectada sobre la dirección en la que mira el robot.
	var avance := robot.velocity.x * hacia

	if avance <= VELOCIDAD_MINIMA:
		return FACTOR_MINIMO

	var t := clampf(
		(avance - VELOCIDAD_MINIMA) / (VELOCIDAD_MAXIMA - VELOCIDAD_MINIMA),
		0.0, 1.0
	)
	return lerpf(FACTOR_MINIMO, FACTOR_MAXIMO, t)


## Cuánto está cargada ahora mismo, de 0 a 1. Para el color del sprite.
func carga() -> float:
	return inverse_lerp(FACTOR_MINIMO, FACTOR_MAXIMO, _factor_por_velocidad())


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	# Provisorio hasta tener assets: la lanza se aclara al ganar velocidad.
	if estado == Estado.INTACTA:
		sprite.color = data.color_calidad().lerp(Color.WHITE, carga() * 0.7)
