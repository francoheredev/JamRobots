extends Control

## Panel de opciones reutilizable: se abre desde el menú principal o desde
## la pausa. Volumen general y pantalla completa, persistidos en Configuracion.

signal cerrado

@onready var control_volumen: HSlider = $CenterContainer/Panel/Margen/VBoxContainer/FilaVolumen/ControlVolumen
@onready var etiqueta_volumen: Label = $CenterContainer/Panel/Margen/VBoxContainer/FilaVolumen/EtiquetaVolumenValor
@onready var casilla_pantalla_completa: CheckButton = $CenterContainer/Panel/Margen/VBoxContainer/FilaPantallaCompleta/CasillaPantallaCompleta
@onready var boton_cerrar: Button = $CenterContainer/Panel/Margen/VBoxContainer/BotonCerrar


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	control_volumen.value = Configuracion.volumen_general
	casilla_pantalla_completa.button_pressed = Configuracion.pantalla_completa
	_actualizar_etiqueta_volumen(Configuracion.volumen_general)

	control_volumen.value_changed.connect(_on_volumen_cambiado)
	casilla_pantalla_completa.toggled.connect(_on_pantalla_completa_alternada)
	boton_cerrar.pressed.connect(_on_cerrar_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_cerrar_pressed()
		get_viewport().set_input_as_handled()


func _on_volumen_cambiado(valor: float) -> void:
	Configuracion.establecer_volumen(valor)
	_actualizar_etiqueta_volumen(valor)


func _actualizar_etiqueta_volumen(valor: float) -> void:
	etiqueta_volumen.text = "%d%%" % int(round(valor * 100.0))


func _on_pantalla_completa_alternada(activo: bool) -> void:
	Configuracion.establecer_pantalla_completa(activo)


func _on_cerrar_pressed() -> void:
	cerrado.emit()
