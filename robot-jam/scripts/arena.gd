extends Node2D

## Arena de combate. Se encarga de presentar a los dos robots entre sí:
## cada uno necesita saber a quién mirar para orientarse.

@onready var jugador: Robot = $RobotJugador
@onready var rival: Robot = $RobotRival

## Arma que se equipa al jugador para probar. Provisorio.
@export var arma_prueba: WeaponData
## Arma del rival. Si queda vacío, usa la misma que el jugador.
@export var arma_prueba_rival: WeaponData

@export var movilidad_prueba: MobilityData

@export var arma_delantera_prueba: WeaponData

func _ready() -> void:
	jugador.rival = rival
	rival.rival = jugador

	if arma_prueba != null:
		jugador.equipar(arma_prueba.slot, Loot.generar(arma_prueba))
	var del_rival := arma_prueba_rival if arma_prueba_rival != null else arma_prueba
	if del_rival != null:
		rival.equipar(del_rival.slot, Loot.generar(del_rival))
	if movilidad_prueba != null:
		jugador.equipar_movilidad(movilidad_prueba)
	if arma_delantera_prueba != null:
		jugador.equipar(arma_delantera_prueba.slot, Loot.generar(arma_delantera_prueba))
		
	EventBus.combate_terminado.connect(_on_combate_terminado)
	GameManager.iniciar_combate(jugador, rival)
	
	_mostrar_equipamiento("Jugador", jugador, arma_prueba.slot)
	_mostrar_equipamiento("Rival", rival, del_rival.slot)

func _on_combate_terminado(ganador: Robot) -> void:
	print("Combate terminado. Ganador: %s" % ganador.name)

func _mostrar_equipamiento(quien: String, robot_objetivo: Robot, slot: int) -> void:
	var arma := robot_objetivo.arma(slot)
	if arma == null:
		return
	var d := arma.data
	print("%s: %s [%s] daño %.1f | cooldown %.2f | umbral %d/%d" % [
		quien, d.nombre, d.nombre_calidad(), d.dano(), d.cooldown(),
		d.umbral_danada(), d.umbral_rota()
	])
