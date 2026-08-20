class_name RobotHurtbox
extends Area2D

## Zona vulnerable del robot. La detectan las hitbox de las armas rivales.
## Guarda una referencia a su propio robot para que un arma nunca se
## pueda golpear a sí misma (ver Weapon._on_area_entered).

@onready var robot: Robot = get_parent() as Robot
