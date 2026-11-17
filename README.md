# Mortal Kombat Rivals

Sub-Zero y Scorpion como personajes jugables en GameMaker LTS 2026. Abre `MortalKombatRivals.yyp` y pulsa **F5**. Al iniciar aparece un selector: elige con **A/D**, **←/→** o **1/2**, y confirma con **Enter** o **Espacio**. El personaje que no elijas aparece enfrente como jefe controlado por la IA, con las mismas estadísticas que el jugador.

El jefe funciona como el de la referencia: un estado con nombre y `alarm[0]` que decide la siguiente acción cada 18–42 frames. Según la distancia y con un factor de azar elige puñetazo, patada, deslizarse, lanzar su ataque a distancia, acercarse, retroceder, agacharse, saltar (hacia delante o hacia atrás) o esperar. Ante un proyectil a veces salta o se agacha para esquivarlo. No gasta ataques mientras el jugador es invulnerable y salta por encima del jugador si queda acorralado. Pulsa los mismos botones que el jugador, así que respeta las mismas recargas y reglas.

En el centro de la arena aparece además **Baraka**, un enemigo con el comportamiento de `o_jumper` de la referencia: cada 70–140 frames se agacha un momento, salta hacia el jugador en posición horizontal hasta casi tocar el suelo y se queda quieto al aterrizar. Solo hace daño (15) si te alcanza durante el salto; quieto no daña. Tiene 30 de vida, recibe los golpes y proyectiles del jugador (parpadea en rojo) y desaparece al llegar a cero. El jefe y los enemigos no se hacen daño entre sí.

Cerca del borde derecho aparece **Goro**, que patrulla el suelo como `o_enemy_walker` de la referencia: da la vuelta (`c_flip`) al llegar a una pared, al final del mapa o a un borde del que caería. Si ve al jugador en su misma línea horizontal, delante de él y sin una pared en medio, lo embiste a toda velocidad. La embestida sigue hasta golpear al jugador (20 de daño) o chocar con algo; después queda confundido 2 segundos y vuelve a patrullar. Caminando o confundido no hace daño. Tiene 60 de vida.

En **Nivel 1** también aparece Kitana como enemiga: lanza su abanico cuando el jugador está a su altura y a menos de 560 píxeles; tiene 40 de vida y el abanico hace 10 de daño.

| Acción | Ambos personajes |
| --- | --- |
| Moverse | A / D o ← / → |
| Saltar | W o Espacio |
| Puñetazo | Clic izquierdo |
| Patada | Clic derecho |
| Ataque a distancia (hielo / lanza) | Q |
| Deslizamiento / patada deslizante | Shift |
| Agacharse | S o ↓ |

**R** reinicia con el personaje elegido y restaura la vida. **Esc** vuelve al selector. **F1** muestra las máscaras de colisión, los golpes y el estado actual. Los ataques se activan con una pulsación y se realizan en el suelo. Soltar salto durante el ascenso reduce su altura. La patada hace 14 de daño (el puñetazo 10) y llega más lejos, pero es más lenta. Agachado no te mueves y el proyectil enemigo y la patada pasan por encima; el puñetazo sí te alcanza. El hielo y la lanza salen a la altura de la mano. La lanza se dibuja al 45 % y su cadena sale horizontal desde los eslabones que sostiene Scorpion. Los luchadores pueden atravesarse en movimiento, pero si quedan parados uno encima del otro se separan solos.

Cada personaje incluye quieto, correr, preparación de salto, salto, caída, aterrizaje, puñetazo, patada, agacharse, ataque a distancia, deslizamiento, recibir daño y muerte. Los proyectiles tienen ocho fotogramas: bola de hielo para Sub-Zero y kunai con cadena para Scorpion. El hielo congela durante un segundo; la lanza hace 20 de daño y arrastra al rival hacia Scorpion cuando hay objetivos en la sala. La cadena tiene un alcance máximo de **320 píxeles** desde la mano de Scorpion y desaparece al alcanzar ese límite o si Scorpion se aleja demasiado. Los golpes tienen un único impacto por objetivo, hay invulnerabilidad temporal tras recibir daño y la muerte conserva el último fotograma.

## Organización

- `objects/o_fighter`: lógica común de movimiento, estados, animación y recepción de daño.
- `objects/o_subzero`, `objects/o_scorpion`: animaciones y ataque especial de cada personaje.
- `objects/o_player_sc`, `objects/o_player_sz`: jugadores de Scorpion y Sub-Zero, con los mismos controles (A/D, W o Espacio, S, Q, Shift y ratón); heredan el combate de sus respectivos personajes.
- `objects/o_boss_sc`, `objects/o_boss_sz`, `scripts/c_boss_ai`: jefe de cada personaje; la IA pulsa los botones virtuales `ai_*` de `o_fighter`.
- `objects/o_enemy`: padre de los enemigos, como en la referencia; los golpes y proyectiles del jugador dañan a cualquier `o_enemy` del otro equipo.
- `objects/o_goro`, `scripts/c_flip`: enemigo que patrulla, embiste y queda confundido; `c_flip` es el mismo de la referencia.
- `objects/o_baraka`: enemigo saltador; movimiento copiado de `o_jumper` (`move_contact_solid`, `collision_rectangle` contra `o_terrain`, `alarm[0]` con `irandom_range`).
- `objects/o_control`, `scripts/c_player_select`: selector inicial, creación del jugador elegido, del jefe, de Baraka y de Goro, reinicio y HUD.
- `objects/o_att`, `objects/o_hitbox`, `objects/o_projectile`: jerarquía de ataques, golpes cuerpo a cuerpo y proyectiles.
- `objects/o_iceball`, `objects/o_spear`: proyectiles propios de cada personaje.
- `objects/o_terrain`, `objects/o_solid`: terreno y plataformas; movimiento separado por ejes como en la referencia.
- `scripts/c_fighter_*`: cambio de estado, movimiento, ataques y aplicación de daño.
- `sprites/s_subzero_*`, `sprites/s_scorpion_*`: fotogramas originales de las hojas de `sprite_ref/`, importados con transparencia y sin escalarlos. La patada viene de `sprite_ref/Patada Sub-Zero y Scorpion.webp` y el agacharse de `sprite_ref/Agacharse Sub-Zero y Scorpion.webp`; `tools/prepare_move_sheets.py` (requiere Pillow) los escala y alinea con la pose de reposo en `sprite_ref/* patada y agacharse.png`, con celdas de 176 × 176. Baraka sale de `sprite_ref/Baraka.webp` (fila 1 reposo, fila 2 salto) y Goro de `sprite_ref/Goro.webp` (caminar, embestir, confundido) con el mismo script.
- `Room1`: selector inicial y sala de un jugador con suelo, plataformas y barras de vida.

Los sprites del cuerpo usan lienzos de 176 × 176, origen `(80,168)` y máscaras físicas separadas de la animación. El dibujo se presenta al 65 %. Los proyectiles usan lienzos de 144 × 64. La caída y el aterrizaje están separados y las animaciones de acciones no se repiten automáticamente. Se conserva el desplazamiento de las poses dentro de las hojas originales.

## Vista y comprobaciones

Abre `preview/animaciones.html` para recorrer todas las animaciones, pausar y revisar los fotogramas de ambos personajes sin ejecutar GameMaker.

Desde la raíz de este repositorio:

```powershell
python tools/check_project.py
powershell -NoProfile -ExecutionPolicy Bypass -File tools/test_game.ps1
```

El primer comando verifica los recursos, referencias, fotogramas RGBA y capas editables. El segundo compila con el runtime local de GameMaker LTS 2026 y ejecuta 95 comprobaciones reales: selección de ambos jugadores, teclas de movimiento y ataques, aparición del jefe con las estadísticas del jugador, que el jefe use todos sus movimientos y golpee, separación de luchadores parados y paso a través en movimiento, reinicio, alcance de la cadena en ambas direcciones, tamaño y altura de la lanza, pose de lanzamiento mientras existe la cadena y recuperación al desaparecer, movimiento y paredes, salto/caída/aterrizaje, golpes, patada (daño, alcance y duración), agacharse (máscara baja y esquivar la lanza), daño, hielo, invulnerabilidad, lanza, deslizamiento, muerte, y Baraka (aparece, cae, se prepara, salta hacia el jugador, aterriza, quieto no daña, su salto sí, recibe golpes y muere) y Goro (patrulla y gira en el final del mapa, paredes y bordes, embiste al ver al jugador, queda confundido 2 s, la embestida se detiene en paredes, recibe golpes y muere).

Para volver a importar las hojas después de modificar el mapa de recortes en `tools/build_characters.py`:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/test_game.ps1 -Reimport
```

La generación conserva el código `.gml`, pero reconstruye los metadatos y la distribución de la sala de prueba. Los registros de compilación y pruebas se guardan en `.build/`.

Los objetivos usados para comprobar daño y efectos solo se crean en el modo `--self-test`. No aparecen al jugar normalmente. El jugador de prueba lee el teclado real: no pulses teclas mientras corren las pruebas.
