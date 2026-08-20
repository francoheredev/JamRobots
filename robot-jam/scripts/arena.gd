extends Node2D

## Arena de combate. Se encarga de presentar a los dos robots entre sí:
## cada uno necesita saber a quién mirar para orientarse.

@onready var jugador: Robot = $RobotJugador
@onready var rival: Robot = $RobotRival

## Arma que se equipa al jugador para probar. Provisorio.
@export var arma_prueba: WeaponData

func _ready() -> void:
	jugador.rival = rival
	rival.rival = jugador

	if arma_prueba != null:
		jugador.equipar(arma_prueba.slot, arma_prueba)
	
	EventBus.combate_terminado.connect(_on_combate_terminado)
	GameManager.iniciar_combate(jugador, rival)

func _on_combate_terminado(ganador: Robot) -> void:
	print("Combate terminado. Ganador: %s" % ganador.name)
