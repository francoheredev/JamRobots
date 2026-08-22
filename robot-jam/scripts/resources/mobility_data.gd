class_name MobilityData
extends Resource

## Datos de una habilidad de movilidad. El slot es único y excluyente:
## turbo o salto, nunca ambos (ver GDD 5.1 y 8).

@export var id: StringName
@export var nombre: String = ""
@export var escena: PackedScene
@export var cooldown_base: float = 1.0

## Modificador rodado según la calidad. Todavía sin definir en el GDD.
@export var mod_cooldown: float = 0.0


func cooldown() -> float:
	return cooldown_base * (1.0 - mod_cooldown)


## Forma del ícono del slot de movilidad: un hexágono, distinto de las
## formas de arma (rombo/triángulos), para reconocerlo de un vistazo como
## una parte aparte (ver WeaponData.forma_slot).
func forma() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(1, 0), Vector2(0.5, 0.87), Vector2(-0.5, 0.87),
		Vector2(-1, 0), Vector2(-0.5, -0.87), Vector2(0.5, -0.87),
	])


## Color del ícono: gris, igual que la calidad Normal de las armas
## (ver WeaponData.color_calidad), porque se arranca con la movilidad
## más básica. Cuando exista una escala de calidad para movilidad, este
## método es el lugar para variarlo igual que en las armas.
func color() -> Color:
	return Color(0.8, 0.8, 0.8)
