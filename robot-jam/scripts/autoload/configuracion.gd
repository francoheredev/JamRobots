extends Node

## Ajustes persistentes del jugador: volumen general y pantalla completa.
## Se guardan en user:// para que sobrevivan entre sesiones.

const RUTA_CONFIG := "user://configuracion.cfg"

signal configuracion_cambiada

var volumen_general := 1.0
var pantalla_completa := false


func _ready() -> void:
	cargar()
	aplicar()


func establecer_volumen(valor: float) -> void:
	volumen_general = clampf(valor, 0.0, 1.0)
	aplicar()
	guardar()


func establecer_pantalla_completa(valor: bool) -> void:
	pantalla_completa = valor
	aplicar()
	guardar()


func aplicar() -> void:
	var indice_bus := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(indice_bus, linear_to_db(volumen_general))
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if pantalla_completa else DisplayServer.WINDOW_MODE_WINDOWED
	)
	configuracion_cambiada.emit()


func guardar() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "volumen_general", volumen_general)
	config.set_value("pantalla", "pantalla_completa", pantalla_completa)
	config.save(RUTA_CONFIG)


func cargar() -> void:
	var config := ConfigFile.new()
	if config.load(RUTA_CONFIG) != OK:
		return
	volumen_general = config.get_value("audio", "volumen_general", volumen_general)
	pantalla_completa = config.get_value("pantalla", "pantalla_completa", pantalla_completa)
