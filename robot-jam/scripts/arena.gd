extends Node2D

## Arena de combate. Arma a los dos robots según el estado del torneo
## (ver Torneo) y ofrece fragmentos cuando el jugador gana una etapa.

@onready var jugador: Robot = $Composicion/ContenedorArena/ViewportArena/RobotJugador
@onready var rival: Robot = $Composicion/ContenedorArena/ViewportArena/RobotRival


func _ready() -> void:
	jugador.rival = rival
	rival.rival = jugador

	_equipar_jugador()
	_equipar_rival()
	jugador.equipar_movilidad(Torneo.movilidad_jugador)

	EventBus.combate_terminado.connect(_on_combate_terminado)
	GameManager.iniciar_combate(jugador, rival)

	print("Rival %d/%d: %s" % [
		Torneo.indice_actual + 1, Torneo.total_rivales(), Torneo.rival_actual()["nombre"]
	])
	AudioManager.poner_musica(&"combate")
## Arranca siempre del equipo base y le superpone lo que el jugador haya
## conservado o ganado. Así una derrota nunca deja al robot con menos
## armas de las que tenía al empezar: solo pierde la calidad ganada.
func _equipar_jugador() -> void:
	var equipo := Torneo.equipo_base()

	for slot in Torneo.equipo_jugador:
		equipo[slot] = Torneo.equipo_jugador[slot]

	for slot in equipo:
		jugador.equipar(slot, equipo[slot])

func _equipar_rival() -> void:
	var equipo := Torneo.generar_equipo_rival()
	for slot in equipo:
		rival.equipar(slot, equipo[slot])
		rival.equipar_movilidad(Torneo.MOVILIDAD_TURBO)

func _on_combate_terminado(ganador: Robot) -> void:
	if ganador != jugador:
		_resolver_derrota()
		return

	# Venció al jefe final: se terminó el torneo (ver GDD 3).
	if Torneo.es_ultimo_rival():
		EventBus.torneo_terminado.emit(true)
		return

	_ofrecer_fragmentos()

## Los fragmentos son literalmente las armas que llevaba puestas el rival
## derrotado, con la calidad con la que peleó. No se re-rolean: ganarle a
## un rival fuerte tiene que valer más que ganarle a uno débil (ver GDD 1).
func _ofrecer_fragmentos() -> void:
	var fragmentos: Array[WeaponData] = []
	for slot in Torneo.equipo_rival:
		fragmentos.append(Torneo.equipo_rival[slot])
	if not fragmentos.is_empty():
		EventBus.fragmentos_ofrecidos.emit(fragmentos)

## Al perder se conserva un fragmento (ver GDD 1). Si hay más de uno en
## juego lo elige el jugador; con uno solo o ninguno no hay decisión que
## tomar y la derrota se resuelve directo.
func _resolver_derrota() -> void:
	var ganados: Array[WeaponData] = []
	for slot in Torneo.equipo_jugador:
		ganados.append(Torneo.equipo_jugador[slot])

	if ganados.size() < 2:
		Torneo.registrar_derrota()
		EventBus.torneo_terminado.emit(false)
		return

	EventBus.conservar_ofrecido.emit(ganados)
