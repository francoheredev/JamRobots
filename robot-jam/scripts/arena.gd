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


func _equipar_jugador() -> void:
	if Torneo.equipo_jugador.is_empty():
		# Arranque del torneo: equipo básico completo (calidad Normal) para
		# poder usar las tres funciones desde el primer combate: sierra en
		# Superior, paletas en Delantero, táser en Trasero. Los fragmentos
		# que se ganen después reemplazan estas de a una.
		for base: WeaponData in [Torneo.ARMA_SIERRA, Torneo.ARMA_PALETAS, Torneo.ARMA_TASER]:
			var comun := base.generar(WeaponData.Calidad.NORMAL)
			Torneo.equipo_jugador[comun.slot] = comun

	for slot in Torneo.equipo_jugador:
		jugador.equipar(slot, Torneo.equipo_jugador[slot])


func _equipar_rival() -> void:
	var datos: Dictionary = Torneo.rival_actual()
	var armas: Dictionary = datos["armas"]
	for slot in armas:
		var base: WeaponData = armas[slot]
		rival.equipar(slot, base.generar(datos["calidad"]))


func _on_combate_terminado(ganador: Robot) -> void:
	if ganador != jugador:
		Torneo.registrar_derrota()
		return
	if not Torneo.es_ultimo_rival():
		_ofrecer_fragmentos()


## Los fragmentos ofrecidos son las mismas armas que tenía puestas el
## rival recién derrotado (ver GDD "Fragmentos": son piezas literales de
## ese robot), con calidad recién rolada. La cantidad varía según cuántas
## armas traía esa etapa, no se completa con otras para llegar a 3.
func _ofrecer_fragmentos() -> void:
	var armas: Dictionary = Torneo.rival_actual()["armas"]
	var fragmentos: Array[WeaponData] = []
	for slot in armas:
		fragmentos.append(Loot.generar(armas[slot]))
	if not fragmentos.is_empty():
		EventBus.fragmentos_ofrecidos.emit(fragmentos)
