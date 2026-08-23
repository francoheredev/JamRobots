class_name Projectile
extends Area2D

## Proyectil base. Vuela con gravedad y explota al tocar el piso, a un
## robot, o al agotarse la mecha. El arma que lo dispara le pasa sus
## datos para que el daño y el desgaste sigan siendo los de esa arma.

const GRAVEDAD := 900.0

## Quién lo disparó. Nunca se daña a sí mismo.
var tirador: Robot
## Arma de origen: de ahí sale el daño y a ella se le avisa si acertó.
var arma: Weapon

var dano := 0.0
var radio := 90.0
## Segundos hasta explotar sola si no toca nada.
var mecha := 1.6
## Si voltea a los robots alcanzados de cerca (ver GDD 4.3).
var voltea := false

var _velocidad := Vector2.ZERO
var _explotado := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	if _explotado:
		return

	mecha -= delta
	if mecha <= 0.0:
		_explotar()
		return

	_velocidad.y += GRAVEDAD * delta
	position += _velocidad * delta
	rotation = _velocidad.angle()


## La llama el arma al instanciarlo.
func lanzar(velocidad_inicial: Vector2) -> void:
	_velocidad = velocidad_inicial


func _on_body_entered(_cuerpo: Node) -> void:
	# Tocó el piso o una pared.
	_explotar()


func _on_area_entered(area: Area2D) -> void:
	var hurtbox := area as RobotHurtbox
	if hurtbox == null or hurtbox.robot == tirador:
		return
	_explotar()


## Daña a todos los robots dentro del radio, incluido el tirador: una
## granada propia a quemarropa también te alcanza.
func _explotar() -> void:
	if _explotado:
		return
	_explotado = true
	AudioManager.reproducir(&"explosion_granada")

	for robot in get_tree().get_nodes_in_group("robots"):
		var objetivo := robot as Robot
		if objetivo == null or objetivo.esta_destruido():
			continue

		var distancia := global_position.distance_to(objetivo.global_position)
		if distancia > radio:
			continue

		# El daño cae con la distancia: de lleno duele el doble que al borde.
		var factor := 1.0 - (distancia / radio) * 0.5
		objetivo.recibir_dano(dano * factor, -1, global_position)

		if voltea:
			objetivo.voltear(global_position)

	if arma != null:
		arma.marcar_acierto()

	queue_free()
