extends Node

## Estado de la corrida. Por ahora solo arbitra el combate actual;
## más adelante suma inventario, equipamiento y progreso (ver GDD 12.1).

const RUTA_MENU := "res://scenes/ui/menu_principal.tscn"
const RUTA_ARENA := "res://scenes/levels/arena.tscn"

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


func reiniciar() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


## La llama el menú principal para arrancar una partida nueva.
func empezar_partida() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(RUTA_ARENA)


## La llama el menú de pausa (o cualquier UI) para volver al menú principal.
func ir_a_menu_principal() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(RUTA_MENU)
