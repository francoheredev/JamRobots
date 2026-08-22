extends CanvasLayer

## Pantalla de derrota: el jugador elige cuál de sus fragmentos ganados
## conserva para la próxima corrida. El resto se descarta (ver GDD 1).

const ESCENA_TARJETA := preload("res://scenes/ui/tarjeta_fragmento.tscn")

@onready var fila_tarjetas: HBoxContainer = $Fondo/CenterContainer/VBoxContainer/FilaTarjetas


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	EventBus.conservar_ofrecido.connect(_on_conservar_ofrecido)


func _on_conservar_ofrecido(lista: Array) -> void:
	for hijo in fila_tarjetas.get_children():
		hijo.queue_free()

	for fragmento in lista:
		var tarjeta := ESCENA_TARJETA.instantiate()
		fila_tarjetas.add_child(tarjeta)
		tarjeta.mostrar(fragmento)
		tarjeta.elegido.connect(_on_conservar_elegido)

	get_tree().paused = true
	show()


func _on_conservar_elegido(fragmento: WeaponData) -> void:
	Torneo.registrar_derrota(fragmento.slot)
	get_tree().paused = false
	hide()
	# Recién ahora el HUD muestra la pantalla de derrota.
	EventBus.torneo_terminado.emit(false)
