extends CanvasLayer

## Pantalla de elección de fragmentos. Aparece cuando EventBus ofrece una
## lista de armas (ver EventBus.fragmentos_ofrecidos), guarda la elegida
## en Torneo (para que sobreviva al próximo combate) y avanza de etapa.

const ESCENA_TARJETA := preload("res://scenes/ui/tarjeta_fragmento.tscn")

@onready var fila_tarjetas: HBoxContainer = $Fondo/CenterContainer/VBoxContainer/FilaTarjetas
@onready var boton_descartar: Button = $Fondo/CenterContainer/VBoxContainer/BotonDescartar

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	EventBus.fragmentos_ofrecidos.connect(_on_fragmentos_ofrecidos)
	boton_descartar.pressed.connect(_on_descartar_pressed)

func _on_fragmentos_ofrecidos(lista: Array) -> void:
	for hijo in fila_tarjetas.get_children():
		hijo.queue_free()

	for fragmento in lista:
		var tarjeta := ESCENA_TARJETA.instantiate()
		fila_tarjetas.add_child(tarjeta)
		tarjeta.mostrar(fragmento)
		tarjeta.elegido.connect(_on_fragmento_elegido)

	get_tree().paused = true
	show()


func _on_fragmento_elegido(fragmento: WeaponData) -> void:
	Torneo.equipar_fragmento(fragmento)
	EventBus.fragmento_elegido.emit(fragmento)
	_continuar()


## El jugador puede rechazar los fragmentos ofrecidos. Tiene sentido:
## un fragmento de calidad Normal puede ser peor que el arma equipada,
## y quedarse con lo que tiene es una decisión válida (ver GDD pilar 1).
func _on_descartar_pressed() -> void:
	_continuar()


func _continuar() -> void:
	Torneo.avanzar()
	get_tree().paused = false
	hide()
	GameManager.reiniciar()
