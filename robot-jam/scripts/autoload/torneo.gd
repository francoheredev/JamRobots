extends Node

## Torneo: la secuencia fija de rivales a vencer y el equipamiento del
## jugador, que sobrevive entre combates (ver GDD "Fragmentos" y un torneo
## no infinito que termina en jefe final). No hay progresión de por vida:
## esto vive solo mientras dura una corrida, se resetea al jugar de nuevo.

const ARMA_SIERRA := preload("res://data/weapons/sierra.tres")
const ARMA_MARTILLO := preload("res://data/weapons/martillo.tres")
const ARMA_PALETAS := preload("res://data/weapons/paletas.tres")
const ARMA_TASER := preload("res://data/weapons/taser.tres")
const MOVILIDAD_TURBO := preload("res://data/mobility/turbo.tres")

## Cada etapa: nombre del rival, sus armas por slot y la calidad con la
## que pelea. Ojo: sierra y martillo son las dos alternativas del mismo
## slot Superior (ver sus .tres, ninguna define slot propio y las dos
## heredan el default), paletas es Delantero y táser es Trasero — por
## eso nunca aparecen dos juntas en el mismo slot de un rival.
## Del 1ro al 3ro se van sumando partes; del 4to en adelante ya pelean
## con las tres, y de ahí en más solo escala la calidad hasta el jefe.
const RIVALES := [
	{
		"nombre": "Chatarrero",
		"armas": {WeaponData.Slot.SUPERIOR: ARMA_MARTILLO},
		"calidad": WeaponData.Calidad.NORMAL,
	},
	{
		"nombre": "Oxidado",
		"armas": {WeaponData.Slot.DELANTERO: ARMA_PALETAS},
		"calidad": WeaponData.Calidad.NORMAL,
	},
	{
		"nombre": "Verdugo",
		"armas": {WeaponData.Slot.SUPERIOR: ARMA_SIERRA, WeaponData.Slot.DELANTERO: ARMA_PALETAS},
		"calidad": WeaponData.Calidad.BUENA,
	},
	{
		"nombre": "Centinela",
		"armas": {
			WeaponData.Slot.SUPERIOR: ARMA_MARTILLO,
			WeaponData.Slot.DELANTERO: ARMA_PALETAS,
			WeaponData.Slot.TRASERO: ARMA_TASER,
		},
		"calidad": WeaponData.Calidad.BUENA,
	},
	{
		"nombre": "Acorazado",
		"armas": {
			WeaponData.Slot.SUPERIOR: ARMA_SIERRA,
			WeaponData.Slot.DELANTERO: ARMA_PALETAS,
			WeaponData.Slot.TRASERO: ARMA_TASER,
		},
		"calidad": WeaponData.Calidad.BUENA,
	},
	{
		"nombre": "Implacable",
		"armas": {
			WeaponData.Slot.SUPERIOR: ARMA_MARTILLO,
			WeaponData.Slot.DELANTERO: ARMA_PALETAS,
			WeaponData.Slot.TRASERO: ARMA_TASER,
		},
		"calidad": WeaponData.Calidad.EPICA,
	},
	{
		"nombre": "Devastador",
		"armas": {
			WeaponData.Slot.SUPERIOR: ARMA_SIERRA,
			WeaponData.Slot.DELANTERO: ARMA_PALETAS,
			WeaponData.Slot.TRASERO: ARMA_TASER,
		},
		"calidad": WeaponData.Calidad.EPICA,
	},
	{
		"nombre": "Titán",
		"armas": {
			WeaponData.Slot.SUPERIOR: ARMA_MARTILLO,
			WeaponData.Slot.DELANTERO: ARMA_PALETAS,
			WeaponData.Slot.TRASERO: ARMA_TASER,
		},
		"calidad": WeaponData.Calidad.LEGENDARIA,
	},
	{
		"nombre": "Campeón",
		"armas": {
			WeaponData.Slot.SUPERIOR: ARMA_SIERRA,
			WeaponData.Slot.DELANTERO: ARMA_PALETAS,
			WeaponData.Slot.TRASERO: ARMA_TASER,
		},
		"calidad": WeaponData.Calidad.LEGENDARIA,
	},
]

var indice_actual := 0
## Slot -> WeaponData ya equipado. Sobrevive entre combates y recargas
## de escena; es lo que hace que elegir un fragmento tenga efecto real.
var equipo_jugador: Dictionary = {}
var movilidad_jugador: MobilityData = MOVILIDAD_TURBO


func reiniciar_torneo() -> void:
	indice_actual = 0
	equipo_jugador.clear()
	movilidad_jugador = MOVILIDAD_TURBO


func rival_actual() -> Dictionary:
	return RIVALES[indice_actual]


func total_rivales() -> int:
	return RIVALES.size()


func es_ultimo_rival() -> bool:
	return indice_actual >= RIVALES.size() - 1


## La llama la arena cuando el jugador gana y elige fragmento: pasa al
## próximo rival de la lista.
func avanzar() -> void:
	indice_actual = mini(indice_actual + 1, RIVALES.size() - 1)


func equipar_fragmento(fragmento: WeaponData) -> void:
	equipo_jugador[fragmento.slot] = fragmento


## Al perder se descartan los fragmentos ganados y se vuelve al primer
## rival con el equipo común de nuevo (_equipar_jugador en arena.gd
## rearma esa base básica apenas ve el equipo vacío).
func registrar_derrota() -> void:
	equipo_jugador.clear()
	indice_actual = 0
