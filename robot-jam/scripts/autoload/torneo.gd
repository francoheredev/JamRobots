extends Node

## Torneo: la secuencia de etapas hasta el jefe final y el equipamiento del
## jugador, que sobrevive entre combates. No hay progresión de por vida:
## esto vive solo mientras dura una corrida.
##
## Cada etapa define CUÁNTAS armas lleva el rival y de qué calidad; cuáles
## le tocan se sortea del pool en cada combate. Así ningún rival es igual
## dos veces y los fragmentos que suelta valen lo que él llevaba puesto.

const ARMA_SIERRA := preload("res://data/weapons/sierra.tres")
const ARMA_MARTILLO := preload("res://data/weapons/martillo.tres")
const ARMA_PALETAS := preload("res://data/weapons/paletas.tres")
const ARMA_TASER := preload("res://data/weapons/taser.tres")
const MOVILIDAD_TURBO := preload("res://data/mobility/turbo.tres")
const ARMA_GRANADA := preload("res://data/weapons/granada.tres")
const ARMA_LANZA := preload("res://data/weapons/lanza.tres")
const ARMA_LANZALLAMAS := preload("res://data/weapons/lanzallamas.tres")

## Armas disponibles por slot. Al sumar un arma nueva al juego, agregarla
## acá y empieza a aparecer sola en los rivales.
const POOL := {
	WeaponData.Slot.SUPERIOR: [ARMA_SIERRA, ARMA_MARTILLO],
	WeaponData.Slot.DELANTERO: [ARMA_PALETAS, ARMA_LANZA, ARMA_LANZALLAMAS],
	WeaponData.Slot.TRASERO: [ARMA_TASER, ARMA_GRANADA],
}

## Escalado del torneo: primero suben las partes, después la calidad.
const ETAPAS := [
	{"nombre": "Chatarrero", "armas": 1, "calidad": WeaponData.Calidad.NORMAL},
	{"nombre": "Oxidado", "armas": 2, "calidad": WeaponData.Calidad.NORMAL},
	{"nombre": "Verdugo", "armas": 2, "calidad": WeaponData.Calidad.BUENA},
	{"nombre": "Centinela", "armas": 3, "calidad": WeaponData.Calidad.BUENA},
	{"nombre": "Acorazado", "armas": 3, "calidad": WeaponData.Calidad.BUENA},
	{"nombre": "Implacable", "armas": 3, "calidad": WeaponData.Calidad.EPICA},
	{"nombre": "Devastador", "armas": 3, "calidad": WeaponData.Calidad.EPICA},
	{"nombre": "Titán", "armas": 3, "calidad": WeaponData.Calidad.LEGENDARIA},
	{"nombre": "Campeón", "armas": 3, "calidad": WeaponData.Calidad.LEGENDARIA},
]

var indice_actual := 0
## Slot -> WeaponData ganado. Sobrevive entre combates y recargas de
## escena; es lo que hace que elegir un fragmento tenga efecto real.
var equipo_jugador: Dictionary = {}
var movilidad_jugador: MobilityData = MOVILIDAD_TURBO
## Armas del rival del combate en curso. Son exactamente las que se
## ofrecen como fragmentos al derrotarlo (ver GDD 1).
var equipo_rival: Dictionary = {}


func reiniciar_torneo() -> void:
	indice_actual = 0
	equipo_jugador.clear()
	equipo_rival.clear()
	movilidad_jugador = MOVILIDAD_TURBO


func rival_actual() -> Dictionary:
	return ETAPAS[indice_actual]


func total_rivales() -> int:
	return ETAPAS.size()


func es_ultimo_rival() -> bool:
	return indice_actual >= ETAPAS.size() - 1


## Sortea el equipamiento del rival de esta etapa. Se guarda porque son
## las mismas armas que va a soltar como fragmentos si el jugador gana.
func generar_equipo_rival() -> Dictionary:
	var etapa := rival_actual()
	var slots := POOL.keys()
	slots.shuffle()

	var cantidad: int = mini(etapa["armas"], slots.size())
	equipo_rival = {}

	for i in cantidad:
		var slot = slots[i]
		var opciones: Array = POOL[slot]
		var base: WeaponData = opciones[randi() % opciones.size()]
		equipo_rival[slot] = base.generar(etapa["calidad"])

	return equipo_rival


## Equipo con el que arranca toda corrida: las tres armas comunes en
## calidad Normal. Los fragmentos ganados reemplazan estas de a una.
func equipo_base() -> Dictionary:
	var base := {}
	for arma: WeaponData in [ARMA_SIERRA, ARMA_PALETAS, ARMA_TASER]:
		var comun := arma.generar(WeaponData.Calidad.NORMAL)
		base[comun.slot] = comun
	return base


func avanzar() -> void:
	indice_actual = mini(indice_actual + 1, ETAPAS.size() - 1)


func equipar_fragmento(fragmento: WeaponData) -> void:
	equipo_jugador[fragmento.slot] = fragmento


## Al perder se conserva UNA sola de las armas ganadas y se descarta el
## resto, volviendo al primer rival (ver GDD 1 y pilar 3).
func registrar_derrota(slot_conservado: int = -1) -> void:
	var conservada: WeaponData = null

	if not equipo_jugador.is_empty():
		if slot_conservado >= 0 and equipo_jugador.has(slot_conservado):
			conservada = equipo_jugador[slot_conservado]
		else:
			var slots := equipo_jugador.keys()
			conservada = equipo_jugador[slots[randi() % slots.size()]]

	equipo_jugador.clear()
	if conservada != null:
		equipo_jugador[conservada.slot] = conservada

	indice_actual = 0
