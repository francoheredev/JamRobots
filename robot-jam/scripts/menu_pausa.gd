extends CanvasLayer

## Menú de pausa: se activa con Esc o el botón "II" del HUD de combate.
## Pausa real del motor (get_tree().paused) para congelar físicas e IA.

const ESCENA_OPCIONES := preload("res://scenes/ui/menu_opciones.tscn")

@onready var panel: Control = $Panel
@onready var boton_reanudar: Button = $Panel/VBoxContainer/BotonReanudar
@onready var boton_opciones: Button = $Panel/VBoxContainer/BotonOpciones
@onready var boton_reiniciar: Button = $Panel/VBoxContainer/BotonReiniciar
@onready var boton_menu: Button = $Panel/VBoxContainer/BotonMenu
@onready var boton_salir: Button = $Panel/VBoxContainer/BotonSalir

var _opciones_instancia: Control


func _ready() -> void:
	hide()
	boton_reanudar.pressed.connect(_on_boton_reanudar_pressed)
	boton_opciones.pressed.connect(_on_boton_opciones_pressed)
	boton_reiniciar.pressed.connect(_on_boton_reiniciar_pressed)
	boton_menu.pressed.connect(_on_boton_menu_pressed)
	boton_salir.pressed.connect(_on_boton_salir_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not _opciones_instancia:
		_alternar_pausa()
		get_viewport().set_input_as_handled()


## La llama el botón de pausa del HUD de combate.
func abrir() -> void:
	if not get_tree().paused:
		_pausar()


func _alternar_pausa() -> void:
	if get_tree().paused:
		_reanudar()
	else:
		_pausar()


func _pausar() -> void:
	get_tree().paused = true
	show()
	boton_reanudar.grab_focus()


func _reanudar() -> void:
	get_tree().paused = false
	hide()


func _on_boton_reanudar_pressed() -> void:
	_reanudar()


func _on_boton_opciones_pressed() -> void:
	_opciones_instancia = ESCENA_OPCIONES.instantiate()
	add_child(_opciones_instancia)
	_opciones_instancia.cerrado.connect(_on_opciones_cerradas)
	panel.hide()


func _on_opciones_cerradas() -> void:
	_opciones_instancia.queue_free()
	_opciones_instancia = null
	panel.show()


func _on_boton_reiniciar_pressed() -> void:
	GameManager.reiniciar()


func _on_boton_menu_pressed() -> void:
	GameManager.ir_a_menu_principal()


func _on_boton_salir_pressed() -> void:
	get_tree().quit()
