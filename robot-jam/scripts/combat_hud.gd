extends CanvasLayer

## HUD de combate: barras de vida y pantalla de victoria/derrota.
## Solo escucha EventBus, nunca llama métodos de Robot directamente.

@export var jugador: Robot
@export var rival: Robot

var _gano_torneo := false

@onready var barra_jugador: ProgressBar = $BarraJugador
@onready var barra_rival: ProgressBar = $BarraRival
@onready var etiqueta_progreso: Label = $EtiquetaProgreso
@onready var boton_pausa: Button = $BotonPausa
@onready var panel_resultado: CenterContainer = $PanelResultado
@onready var etiqueta_resultado: Label = $PanelResultado/VBoxContainer/EtiquetaResultado
@onready var pista_reinicio: Label = $PanelResultado/VBoxContainer/PistaReinicio
@onready var boton_reintentar: Button = $PanelResultado/VBoxContainer/FilaBotones/BotonReintentar
@onready var boton_menu: Button = $PanelResultado/VBoxContainer/FilaBotones/BotonMenu


func _ready() -> void:
	panel_resultado.hide()

	if jugador:
		barra_jugador.max_value = jugador.vida_max
		barra_jugador.value = jugador.vida
	if rival:
		barra_rival.max_value = rival.vida_max
		barra_rival.value = rival.vida

	etiqueta_progreso.text = "Rival %d / %d — %s" % [
		Torneo.indice_actual + 1, Torneo.total_rivales(), Torneo.rival_actual()["nombre"]
	]

	EventBus.robot_danado.connect(_on_robot_danado)
	EventBus.arma_desgastada.connect(_on_arma_desgastada)
	EventBus.torneo_terminado.connect(_on_torneo_terminado)

	boton_pausa.pressed.connect(_on_boton_pausa_pressed)
	boton_reintentar.pressed.connect(_on_boton_reintentar_pressed)
	boton_menu.pressed.connect(_on_boton_menu_pressed)

func _on_robot_danado(robot: Robot, _cantidad: float) -> void:
	if robot == jugador:
		barra_jugador.value = robot.vida
	elif robot == rival:
		barra_rival.value = robot.vida

## Solo se muestra al terminar la corrida, no en cada combate ganado:
## en las victorias intermedias la pantalla que aparece es la de fragmentos.
func _on_torneo_terminado(gano: bool) -> void:
	_gano_torneo = gano
	etiqueta_resultado.text = "¡CAMPEÓN!" if gano else "DERROTA"
	pista_reinicio.text = "Presiona R para volver al menú" if gano else "Presiona R para reintentar"
	boton_reintentar.visible = not gano
	boton_menu.visible = true
	panel_resultado.show()

func _unhandled_input(event: InputEvent) -> void:
	if not panel_resultado.visible:
		return
	if not (event is InputEventKey and event.pressed and event.keycode == KEY_R):
		return

	if _gano_torneo:
		Torneo.reiniciar_torneo()
		GameManager.ir_a_menu_principal()
	else:
		GameManager.reiniciar()

func _on_arma_desgastada(robot_afectado: Robot, slot: int, estado: int) -> void:
	var quien := "Jugador" if robot_afectado == jugador else "Rival"
	var nombres: Array[String] = ["INTACTA", "DAÑADA", "ROTA"]
	var nombre_estado: String = nombres[estado]
	print("[%s] arma del slot %d ahora está %s" % [quien, slot, nombre_estado])

func _on_boton_pausa_pressed() -> void:
	var menu_pausa := get_tree().get_first_node_in_group("menu_pausa")
	if menu_pausa:
		menu_pausa.abrir()

func _on_boton_reintentar_pressed() -> void:
	GameManager.reiniciar()

func _on_boton_menu_pressed() -> void:
	GameManager.ir_a_menu_principal()
