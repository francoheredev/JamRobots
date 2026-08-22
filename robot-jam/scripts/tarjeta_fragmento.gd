extends PanelContainer

## Tarjeta de un fragmento elegible: ícono (forma=parte, color=calidad),
## nombre, calidad y estadísticas, con un botón para elegirlo.

signal elegido(fragmento: WeaponData)

@onready var icono: FragmentoIcono = $VBoxContainer/Icono
@onready var etiqueta_nombre: Label = $VBoxContainer/EtiquetaNombre
@onready var etiqueta_calidad: Label = $VBoxContainer/EtiquetaCalidad
@onready var etiqueta_stats: Label = $VBoxContainer/EtiquetaStats
@onready var boton_elegir: Button = $VBoxContainer/BotonElegir

var _fragmento: WeaponData


func _ready() -> void:
	boton_elegir.pressed.connect(_on_boton_elegir_pressed)


func mostrar(fragmento: WeaponData) -> void:
	_fragmento = fragmento
	icono.mostrar(fragmento)
	etiqueta_nombre.text = fragmento.nombre
	etiqueta_calidad.text = fragmento.nombre_calidad()
	etiqueta_calidad.add_theme_color_override("font_color", fragmento.color_calidad())
	etiqueta_stats.text = "Daño %.1f | Cooldown %.2fs" % [fragmento.dano(), fragmento.cooldown()]


func _on_boton_elegir_pressed() -> void:
	elegido.emit(_fragmento)
