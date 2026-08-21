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
