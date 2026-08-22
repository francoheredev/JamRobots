class_name FragmentoIcono
extends Control

## Ícono de un fragmento: dibuja la forma de su slot (WeaponData.forma_slot)
## coloreada según su calidad (WeaponData.color_calidad). Así la forma dice
## qué parte modifica y el color dice qué tan buena es, sin arte.

var _fragmento: WeaponData


func mostrar(fragmento: WeaponData) -> void:
	_fragmento = fragmento
	queue_redraw()


func _draw() -> void:
	if _fragmento == null:
		return
	var centro := size * 0.5
	var radio := minf(size.x, size.y) * 0.5 * 0.8
	var puntos := PackedVector2Array()
	for punto in _fragmento.forma_slot():
		puntos.append(centro + punto * radio)
	draw_colored_polygon(puntos, _fragmento.color_calidad())
