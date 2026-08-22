class_name TaserWeapon
extends Weapon

## Táser. Montado atrás, con el brazo arqueado por encima del chasis:
## dispara un arco eléctrico hacia ADELANTE, a media distancia. Al
## impactar aturde al rival unos segundos (ver GDD 6.3).

## Cuánto dura visible el arco.
const DURACION_ARCO := 0.15
## Segundos que queda aturdido el rival alcanzado.
const ATURDIMIENTO := 1.2

var _rayo: Line2D


func _ready() -> void:
	super._ready()
	_crear_rayo()


func _ejecutar() -> void:
	_acerto = false
	forma_hitbox.disabled = false
	_golpe_restante = DURACION_ARCO
	_rayo.visible = true


func _al_cerrar_golpe() -> void:
	_rayo.visible = false


## El daño lo aplica la clase base; acá solo se agrega el aturdimiento.
func _al_golpear(victima: Robot) -> void:
	victima.aturdir(ATURDIMIENTO)


## Arco eléctrico dibujado por código: sigue el largo de la hitbox, así
## que si se ajusta el alcance en el inspector el visual acompaña solo.
func _crear_rayo() -> void:
	_rayo = Line2D.new()
	_rayo.width = 4.0
	_rayo.default_color = Color(0.45, 0.6, 1.0)
	_rayo.visible = false
	add_child(_rayo)

	var forma := forma_hitbox.shape as RectangleShape2D
	var largo := forma.size.x
	var desde := forma_hitbox.position.x - largo * 0.5

	var puntos := PackedVector2Array()
	const PASOS := 12
	for i in PASOS + 1:
		var t := float(i) / PASOS
		# Coordenadas locales a la hitbox: el zigzag va sobre su eje largo.
		var x := -largo * 0.5 + largo * t
		var y := 0.0
		if i > 0 and i < PASOS:
			y = 11.0 if i % 2 == 0 else -11.0
		# Se rota igual que la hitbox para que el visual la acompañe.
		puntos.append(forma_hitbox.position + Vector2(x, y).rotated(forma_hitbox.rotation))

	_rayo.points = puntos
