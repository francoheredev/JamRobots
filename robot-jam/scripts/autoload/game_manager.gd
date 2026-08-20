extends Node

## Estado de la corrida. Por ahora solo arbitra el combate actual;
## más adelante suma inventario, equipamiento y progreso (ver GDD 12.1).

var _combatientes: Array[Robot] = []
var _en_combate := false


func _ready() -> void:
	EventBus.robot_danado.connect(_on_robot_danado)


## La llama la arena cuando los dos robots están listos.
func iniciar_combate(a: Robot, b: Robot) -> void:
	_combatientes = [a, b]
	_en_combate = true


func _on_robot_danado(robot: Robot, _cantidad: float) -> void:
	if not _en_combate or not robot.esta_destruido():
		return

	_en_combate = false
	var ganador: Robot = null
	for r in _combatientes:
		if r != robot:
			ganador = r

	EventBus.combate_terminado.emit(ganador)

func esta_en_combate() -> bool:
	return _en_combate
