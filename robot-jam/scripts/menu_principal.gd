extends Control

## Menú principal: Jugar, Opciones, Salir.

const ESCENA_OPCIONES := preload("res://scenes/ui/menu_opciones.tscn")

@onready var boton_jugar: Button = $CenterContainer/VBoxContainer/BotonJugar
@onready var boton_opciones: Button = $CenterContainer/VBoxContainer/BotonOpciones
@onready var boton_salir: Button = $CenterContainer/VBoxContainer/BotonSalir

var _opciones_instancia: Control


func _ready() -> void:
	boton_jugar.pressed.connect(_on_boton_jugar_pressed)
	boton_opciones.pressed.connect(_on_boton_opciones_pressed)
	boton_salir.pressed.connect(_on_boton_salir_pressed)
	boton_jugar.grab_focus()


func _on_boton_jugar_pressed() -> void:
	Torneo.reiniciar_torneo()
	GameManager.empezar_partida()


func _on_boton_opciones_pressed() -> void:
	_opciones_instancia = ESCENA_OPCIONES.instantiate()
	add_child(_opciones_instancia)
	_opciones_instancia.cerrado.connect(_on_opciones_cerradas)


func _on_opciones_cerradas() -> void:
	_opciones_instancia.queue_free()
	_opciones_instancia = null


func _on_boton_salir_pressed() -> void:
	get_tree().quit()
