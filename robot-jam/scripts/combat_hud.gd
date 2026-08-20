extends CanvasLayer

## HUD de combate: barras de vida y pantalla de victoria/derrota.
## Solo escucha EventBus, nunca llama métodos de Robot directamente.

@export var jugador: Robot
@export var rival: Robot

@onready var barra_jugador: ProgressBar = $BarraJugador
@onready var barra_rival: ProgressBar = $BarraRival
@onready var etiqueta_resultado: Label = $EtiquetaResultado
@onready var pista_reinicio: Label = $PistaReinicio


func _ready() -> void:
	etiqueta_resultado.hide()
	pista_reinicio.hide()

	if jugador:
		barra_jugador.max_value = jugador.vida_max
		barra_jugador.value = jugador.vida
	if rival:
		barra_rival.max_value = rival.vida_max
		barra_rival.value = rival.vida

	EventBus.robot_danado.connect(_on_robot_danado)
	EventBus.combate_terminado.connect(_on_combate_terminado)


func _on_robot_danado(robot: Robot, _cantidad: float) -> void:
	if robot == jugador:
		barra_jugador.value = robot.vida
	elif robot == rival:
		barra_rival.value = robot.vida


func _on_combate_terminado(ganador: Robot) -> void:
	etiqueta_resultado.text = "VICTORIA" if ganador == jugador else "DERROTA"
	etiqueta_resultado.show()
	pista_reinicio.show()


func _unhandled_input(event: InputEvent) -> void:
	if pista_reinicio.visible and event is InputEventKey and event.pressed and event.keycode == KEY_R:
		GameManager.reiniciar()
