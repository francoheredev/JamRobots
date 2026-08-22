class_name GrenadeWeapon
extends Weapon

## Lanzagranadas. Arroja una granada con arco a larga distancia; demora
## en explotar y hace mucho daño (ver GDD 6.3). La explosión cercana
## voltea a los robots alcanzados, que es la segunda causa de volteo
## definida en el GDD 4.3.

const ESCENA_GRANADA := preload("res://scenes/weapons/grenade.tscn")

## Velocidad de salida. La componente vertical es la que da el arco.
const IMPULSO := Vector2(520.0, -330.0)
## Radio de la explosión.
const RADIO := 110.0
## Cuánto tarda en estallar si no toca nada.
const MECHA := 1.6


func _ejecutar() -> void:
	_acerto = false
	# La granada no usa hitbox propia: el daño lo aplica la explosión.
	_golpe_restante = 0.05

	var granada: Projectile = ESCENA_GRANADA.instantiate()
	granada.tirador = robot
	granada.arma = self
	granada.dano = dano()
	granada.radio = RADIO
	granada.mecha = MECHA
	granada.voltea = true

	# Se agrega a la arena, no al arma: si el arma se rompe o el robot
	# muere, la granada ya lanzada sigue su curso.
	robot.get_parent().add_child(granada)
	granada.global_position = global_position

	var hacia := signf(robot.visual.scale.x)
	granada.lanzar(Vector2(IMPULSO.x * hacia, IMPULSO.y))
