class_name WeaponData
extends Resource

## Datos de un arma. Lo usa el combate para pelear y la meta
## para mostrarla en el inventario y generarla como fragmento.

enum Slot { SUPERIOR, DELANTERO, TRASERO }
enum Calidad { NORMAL, BUENA, EPICA, LEGENDARIA }

## Fuentes de desgaste y cuántos puntos cuesta cada una (ver GDD 10.5).
enum Fuente { TERRENO, CHOQUE, DIRECTO }

const COSTO_DESGASTE := {
	Fuente.TERRENO: 1,   # bajo
	Fuente.DIRECTO: 2,   # medio
	Fuente.CHOQUE: 3,    # alto
}

@export_group("Identidad")
@export var id: StringName
@export var nombre: String = ""
@export var slot: Slot = Slot.SUPERIOR
@export var escena: PackedScene

@export_group("Combate")
@export var dano_base: float = 10.0
@export var cooldown_base: float = 2.0

@export_group("Durabilidad")
## Si se desgasta por su propio uso: fallar contra el piso o chocar
## con otra arma. Las de distancia van en false (ver GDD 10.2).
@export var desgaste_activo: bool = true
## Puntos de desgaste hasta pasar a DANADA, y los adicionales hasta ROTA.
@export var puntos_a_danada: int = 4
@export var puntos_a_rota: int = 4

@export_group("Calidad")
## Se rolean una sola vez al generar el arma como fragmento.
## Un arma ya equipada nunca vuelve a rolear.
@export var calidad: Calidad = Calidad.NORMAL
@export var mod_dano: float = 0.0
@export var mod_vida: float = 0.0
@export var mod_cooldown: float = 0.0


func dano() -> float:
	return dano_base * (1.0 + mod_dano)


func cooldown() -> float:
	return cooldown_base * (1.0 - mod_cooldown)


func umbral_danada() -> int:
	return int(round(puntos_a_danada * (1.0 + mod_vida)))


func umbral_rota() -> int:
	return umbral_danada() + int(round(puntos_a_rota * (1.0 + mod_vida)))


## Rangos por calidad, tal cual la tabla del GDD 7.
## Cada entrada es [minimo, maximo] en fracción (0.06 = 6%).
const RANGOS := {
	Calidad.NORMAL: {
		"dano": [-0.05, 0.05], "vida": [0.0, 0.0], "cooldown": [0.0, 0.0],
	},
	Calidad.BUENA: {
		"dano": [0.06, 0.10], "vida": [0.01, 0.10], "cooldown": [0.0, 0.0],
	},
	Calidad.EPICA: {
		"dano": [0.11, 0.20], "vida": [0.11, 0.25], "cooldown": [0.01, 0.10],
	},
	Calidad.LEGENDARIA: {
		"dano": [0.20, 0.50], "vida": [0.26, 0.50], "cooldown": [0.11, 0.20],
	},
}


## Devuelve una COPIA del arma con la calidad rolada.
## Nunca modifica el recurso original: se comparte por referencia y
## rolear sobre él contaminaría todas las armas que lo usen.
func generar(calidad_pedida: Calidad) -> WeaponData:
	var copia: WeaponData = duplicate()
	var rango: Dictionary = RANGOS[calidad_pedida]

	copia.calidad = calidad_pedida
	copia.mod_dano = randf_range(rango["dano"][0], rango["dano"][1])
	copia.mod_vida = randf_range(rango["vida"][0], rango["vida"][1])
	copia.mod_cooldown = randf_range(rango["cooldown"][0], rango["cooldown"][1])

	return copia


## Nombre de la calidad para mostrar en la interfaz.
func nombre_calidad() -> String:
	return ["Normal", "Buena", "Épica", "Legendaria"][calidad]


## Color de la calidad, para bordes y textos del inventario.
func color_calidad() -> Color:
	match calidad:
		Calidad.BUENA:
			return Color(0.4, 0.85, 0.4)
		Calidad.EPICA:
			return Color(0.65, 0.45, 0.95)
		Calidad.LEGENDARIA:
			return Color(1.0, 0.75, 0.2)
		_:
			return Color(0.8, 0.8, 0.8)
