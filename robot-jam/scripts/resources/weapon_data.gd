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
