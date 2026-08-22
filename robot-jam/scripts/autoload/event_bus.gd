extends Node

## Único punto de comunicación entre sistemas.
## No guarda estado ni lógica: solo declara señales.
## Nadie conecta directo con nadie, todo pasa por acá.

# --- Combate ---

## El robot activó el arma de un slot. slot usa WeaponData.Slot.
signal arma_activada(robot: Node, slot: int)

## Un arma cambió de estado de durabilidad.
## estado usa Weapon.Estado (INTACTA, DANADA, ROTA).
signal arma_desgastada(robot: Node, slot: int, estado: int)

## Un arma llegó al estado ROTA y queda inutilizable hasta fin del combate.
signal arma_rota(robot: Node, slot: int)

# --- Robot ---

signal robot_danado(robot: Node, cantidad: float)

## El robot quedó volcado y no puede atacar.
signal robot_volteado(robot: Node)

## El robot completó la secuencia de reincorporación.
signal robot_reincorporado(robot: Node)

## ganador es el nodo del robot que ganó el combate.
signal combate_terminado(ganador: Node)

# --- Meta ---

## lista es un Array[WeaponData] con los fragmentos que suelta el rival.
signal fragmentos_ofrecidos(lista: Array)

signal fragmento_elegido(fragmento: Resource)

## El equipamiento del robot del jugador cambió y hay que reconstruirlo.
signal equipamiento_cambiado()

## La corrida terminó. gano indica si fue por vencer al jefe final
## o por perder un combate.
signal torneo_terminado(gano: bool)

## Al perder, el jugador elige cuál de sus fragmentos ganados conserva.
signal conservar_ofrecido(lista: Array)
