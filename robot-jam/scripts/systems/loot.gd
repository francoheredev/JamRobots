class_name Loot
extends RefCounted

## Genera armas con calidad aleatoria. Lo usa el rival al soltar
## sus fragmentos y la arena para las pruebas.

## Peso relativo de cada calidad. Cuanto más alto, más frecuente.
const PESOS := {
	WeaponData.Calidad.NORMAL: 60.0,
	WeaponData.Calidad.BUENA: 25.0,
	WeaponData.Calidad.EPICA: 12.0,
	WeaponData.Calidad.LEGENDARIA: 3.0,
}


## Elige una calidad al azar respetando los pesos.
static func calidad_aleatoria() -> WeaponData.Calidad:
	var total := 0.0
	for peso in PESOS.values():
		total += peso

	var tirada := randf() * total
	var acumulado := 0.0
	for calidad in PESOS:
		acumulado += PESOS[calidad]
		if tirada <= acumulado:
			return calidad

	return WeaponData.Calidad.NORMAL


## Devuelve una copia del arma con calidad rolada al azar.
static func generar(base: WeaponData) -> WeaponData:
	return base.generar(calidad_aleatoria())
