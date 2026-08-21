class_name PaddleWeapon
extends Weapon

## Paletas. Cuña al ras del piso, siempre extendida, como las horquillas
## de un autoelevador. El rival se sube solo al avanzar; al activarlas
## suben rápido y lo dan vuelta (ver GDD 6.2).
##
## No se apunta: se prepara. El jugador elige CUÁNDO levantarlas, no a
## quién. La puntería la pone el rival al meterse.

## Cuánto dura el barrido hacia arriba.
const DURACION := 0.4
## Qué parte del rival debe estar sobre las paletas para que lo levanten.
## 0.5 = al menos la mitad de su ancho.
const SOLAPE_MINIMO := 0.5

## Detecta a quién tiene encima. Siempre activa, no depende del cooldown.
@onready var zona: Area2D = $ZonaCarga
@onready var forma_zona: CollisionShape2D = $ZonaCarga/FormaZona


func _ready() -> void:
	super._ready()
	# La hitbox de choque queda siempre abierta: la cuña está extendida
	# todo el combate y puede recibir golpes en cualquier momento.
	forma_hitbox.disabled = false


func _ejecutar() -> void:
	_acerto = false
	_golpe_restante = DURACION

	for victima in _cargados():
		_acerto = true
		victima.voltear(robot.global_position)


## Robots que están lo bastante encima de las paletas como para ser
## levantados. Se consulta al activar, no por señal.
func _cargados() -> Array[Robot]:
	var resultado: Array[Robot] = []

	for area in zona.get_overlapping_areas():
		var hurtbox := area as RobotHurtbox
		if hurtbox == null or hurtbox.robot == robot:
			continue
		if hurtbox.robot.esta_destruido() or hurtbox.robot.volteado:
			continue
		if _solape_suficiente(hurtbox.robot):
			resultado.append(hurtbox.robot)

	return resultado


## Mide cuánto del ancho del rival cae dentro de la zona de carga.
func _solape_suficiente(victima: Robot) -> bool:
	var ancho_zona: float = (forma_zona.shape as RectangleShape2D).size.x
	var centro_zona := forma_zona.global_position.x
	var media_zona := ancho_zona * 0.5

	# Ancho del rival, tomado de su hurtbox.
	var forma_victima := victima.get_node("HitboxChasis/FormaHitbox") as CollisionShape2D
	var ancho_victima: float = (forma_victima.shape as RectangleShape2D).size.x
	var media_victima := ancho_victima * 0.5
	var centro_victima := victima.global_position.x

	# Intersección de los dos segmentos horizontales.
	var izq := maxf(centro_zona - media_zona, centro_victima - media_victima)
	var der := minf(centro_zona + media_zona, centro_victima + media_victima)
	var solape := maxf(der - izq, 0.0)

	return solape >= ancho_victima * SOLAPE_MINIMO


## La cuña extendida no se "cierra" al terminar: vuelve a quedar quieta.
func _al_cerrar_golpe() -> void:
	forma_hitbox.disabled = false
