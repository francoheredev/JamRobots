extends Node

## Reproducción de efectos de sonido. Usa un pool de voces para que varios
## sonidos puedan sonar a la vez sin cortarse entre ellos.
##
## Los sonidos de arma no se piden por nombre desde el código: cada
## WeaponData declara el suyo, así agregar un arma nueva no obliga a tocar
## este archivo.

const SONIDOS := {
	&"martillo": preload("res://assets/audio/sfx/Martillo.mp3"),
	&"sierra": preload("res://assets/audio/sfx/Sierra.mp3"),
	&"taser": preload("res://assets/audio/sfx/Taser.mp3"),
	&"lanzallamas": preload("res://assets/audio/sfx/Lanzallamas.mp3"),
	&"lanza_granada": preload("res://assets/audio/sfx/LanzaGranada.mp3"),
	&"explosion_granada": preload("res://assets/audio/sfx/ExplocionGranada.mp3"),
	&"explosion_robot": preload("res://assets/audio/sfx/ExplocionRobot.mp3"),
	&"turbo": preload("res://assets/audio/sfx/Turbo.mp3"),
	&"salto": preload("res://assets/audio/sfx/Jump.mp3"),
	&"vapor": preload("res://assets/audio/sfx/Vapor.mp3"),
}

## Cuántos sonidos pueden sonar simultáneamente.
const VOCES := 10

const MUSICA := {
	&"menu": preload("res://assets/audio/music/Fragmento_menu.mp3"),
	&"combate": preload("res://assets/audio/music/Combate_fragmento.mp3"),
}

## Cuánto tarda en cruzar de un tema a otro.
const FUNDIDO := 0.6

var _voces: Array[AudioStreamPlayer] = []
var _siguiente := 0
var _musica: AudioStreamPlayer
## Qué tema está sonando, para no reiniciarlo si ya es el correcto.
var _tema_actual: StringName = &""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	for i in VOCES:
		var voz := AudioStreamPlayer.new()
		voz.bus = &"SFX"
		add_child(voz)
		_voces.append(voz)

	_musica = AudioStreamPlayer.new()
	_musica.bus = &"Musica"
	add_child(_musica)
	
	EventBus.robot_volteado.connect(_on_robot_volteado)


## variacion le mete una pequeña diferencia de tono a cada repetición,
## para que un martillo golpeando diez veces no suene idéntico.
func reproducir(id: StringName, variacion := 0.08) -> void:
	if id == &"" or not SONIDOS.has(id):
		return

	var voz := _voces[_siguiente]
	_siguiente = (_siguiente + 1) % VOCES

	voz.stream = SONIDOS[id]
	voz.pitch_scale = randf_range(1.0 - variacion, 1.0 + variacion)
	voz.play()


func _on_robot_volteado(_robot: Node) -> void:
	reproducir(&"vapor")

## Cambia el tema de fondo. Si ya está sonando ese, no hace nada: así se
## puede llamar en cada _ready() sin que la música se reinicie al recargar
## la escena entre combates.
func poner_musica(id: StringName) -> void:
	if id == _tema_actual:
		return
	if not MUSICA.has(id):
		return

	_tema_actual = id

	if _musica.playing:
		await _fundir_a_silencio()

	_musica.stream = MUSICA[id]
	_musica.volume_db = 0.0
	_musica.play()


func _fundir_a_silencio() -> void:
	var tween := create_tween()
	tween.tween_property(_musica, "volume_db", -40.0, FUNDIDO)
	await tween.finished
	_musica.stop()
