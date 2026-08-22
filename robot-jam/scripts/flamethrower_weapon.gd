class_name FlamethrowerWeapon
extends Weapon

## Lanzallamas. Lanza fuego hacia adelante durante unos segundos, haciendo
## daño constante mientras dura y dejando daño persistente después
## (ver GDD 6.2).
##
## Es la única arma que sigue haciendo daño cuando ya se apagó: contra un
## rival que huye, la quemadura lo alcanza igual.

## Cuánto dura el chorro.
const DURACION := 1.8
## Cada cuánto aplica el daño de contacto.
const INTERVALO := 0.25
## Daño por segundo de la quemadura y cuánto dura después del chorro.
const QUEMADURA_DPS := 4.0
const QUEMADURA_SEGUNDOS := 3.0

var _lanzando := false
var _fuego: Polygon2D


func _ready() -> void:
	super._ready()
	_crear_fuego()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if not _lanzando:
		return

	_tiempo_dano += delta
	if _tiempo_dano >= INTERVALO:
		_tiempo_dano = 0.0
		_danar_a_los_que_siguen_dentro()


func _ejecutar() -> void:
	_acerto = false
	_lanzando = true
	_tiempo_dano = 0.0
	forma_hitbox.disabled = false
	_golpe_restante = DURACION
	_fuego.visible = true


func _al_cerrar_golpe() -> void:
	_lanzando = false
	_fuego.visible = false


## Igual que la sierra: la hitbox queda abierta, así que no alcanza con
## area_entered. Hay que preguntar quién sigue adentro.
func _danar_a_los_que_siguen_dentro() -> void:
	for area in hitbox.get_overlapping_areas():
		var hurtbox := area as RobotHurtbox
		if hurtbox == null or hurtbox.robot == robot:
			continue
		if hurtbox.robot.esta_destruido():
			continue

		_acerto = true
		hurtbox.robot.recibir_dano(dano(), data.slot, robot.global_position)
		hurtbox.robot.quemar(QUEMADURA_DPS, QUEMADURA_SEGUNDOS)


## Provisorio hasta tener assets: un triángulo naranja del largo del chorro.
func _crear_fuego() -> void:
	var forma := forma_hitbox.shape as RectangleShape2D
	var largo := forma.size.x
	var alto := forma.size.y
	var desde := forma_hitbox.position.x - largo * 0.5
	var y := forma_hitbox.position.y

	_fuego = Polygon2D.new()
	_fuego.color = Color(1.0, 0.55, 0.1, 0.7)
	_fuego.polygon = PackedVector2Array([
		Vector2(desde, y - alto * 0.15),
		Vector2(desde + largo, y - alto * 0.5),
		Vector2(desde + largo, y + alto * 0.5),
		Vector2(desde, y + alto * 0.15),
	])
	_fuego.visible = false
	add_child(_fuego)
