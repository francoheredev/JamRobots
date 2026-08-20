# RobotJam

Proyecto de game jam hecho en Godot 4.7.

## Cómo abrir el proyecto

1. Abrir Godot 4.7 (o superior compatible).
2. `Import` → seleccionar la carpeta del proyecto (donde está `project.godot`).
3. Abrir y correr.

Motor / config actual (ver `project.godot`):
- Renderer: Forward+
- Motor de físicas 3D: Jolt Physics
- Driver de rendering en Windows: D3D12

## Estructura de carpetas

```
hell-ado/
├── assets/                  ← todo lo que Godot importa
│   ├── sprites/
│   │   ├── characters/
│   │   ├── weapons/
│   │   ├── environment/
│   │   │   ├── tilesets/
│   │   │   └── props/
│   │   ├── ui/
│   │   └── vfx/             ← fogonazos, partículas, impactos
│   ├── audio/
│   │   ├── music/
│   │   ├── sfx/
│   │   │   ├── weapons/
│   │   │   ├── player/
│   │   │   ├── enemies/
│   │   │   └── ui/
│   │   └── ambience/
│   ├── fonts/
│   └── shaders/
│
├── scenes/
│   ├── player/
│   ├── enemies/
│   ├── weapons/
│   ├── items/
│   ├── levels/
│   ├── ui/
│   └── autoload/            ← singletons (GameManager, AudioManager)
│
├── scripts/
│   ├── systems/             ← inventario, combate, guardado
│   ├── resources/           ← class_name de tipo Resource (WeaponData, EnemyData)
│   └── utils/
│
├── data/                    ← .tres de configuración
│   ├── weapons/
│   ├── enemies/
│   └── themes/
│
└── art_source/               ← .aseprite, proyectos de DAW, .wav crudos (no lo importa Godot)
    ├── sprites/
    └── audio/
```

Las carpetas vacías tienen un `.gitkeep` para que Git las trackee hasta que tengan contenido real; borrar el `.gitkeep` en cuanto se agregue el primer archivo de esa carpeta.

`art_source/` tiene un `.gdignore` para que Godot no la indexe ni la importe (ahí van los archivos fuente sin exportar: `.aseprite`, proyectos de DAW, `.wav` crudos, etc.).

## Equipo

_TODO: completar._

## Tema de la jam

_TODO: completar._

## Controles

_TODO: completar._

## Estado del build

_TODO: completar._
