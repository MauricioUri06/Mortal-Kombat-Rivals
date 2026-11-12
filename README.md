# Mortal Kombat Rivals

Sub-Zero y Scorpion como personajes jugables en GameMaker LTS 2026. Abre `MortalKombatRivals.yyp` y pulsa **F5**. Al iniciar aparece un selector: elige con **A/D**, **←/→** o **1/2**, y confirma con **Enter** o **Espacio**. Solo aparece el personaje elegido; no se crea ningún rival.

| Acción | Ambos personajes |
| --- | --- |
| Moverse | A / D o ← / → |
| Saltar | Espacio |
| Ataque melee | Q |
| Ataque a distancia (hielo / lanza) | W |
| Deslizamiento / patada deslizante | E |

**R** reinicia con el personaje elegido y restaura la vida. **Esc** vuelve al selector. **F1** muestra las máscaras de colisión, los golpes y el estado actual. Los ataques se activan con una pulsación y se realizan en el suelo. Soltar salto durante el ascenso reduce su altura.

Cada personaje incluye quieto, correr, preparación de salto, salto, caída, aterrizaje, puñetazo, ataque a distancia, deslizamiento, recibir daño y muerte. Los proyectiles tienen ocho fotogramas: bola de hielo para Sub-Zero y kunai con cadena para Scorpion. El hielo congela durante un segundo; la lanza daña y arrastra al rival hacia Scorpion cuando hay objetivos en la sala. La cadena tiene un alcance máximo de **320 píxeles** desde la mano de Scorpion y desaparece al alcanzar ese límite o si Scorpion se aleja demasiado. Los golpes tienen un único impacto por objetivo, hay invulnerabilidad temporal tras recibir daño y la muerte conserva el último fotograma.

## Organización

- `objects/o_fighter`: lógica común de movimiento, estados, animación y recepción de daño.
- `objects/o_subzero`, `objects/o_scorpion`: animaciones y ataque especial de cada personaje.
- `objects/o_player_sc`, `objects/o_player_sz`: jugadores de Scorpion y Sub-Zero, con los mismos controles Q/W/E y Espacio; heredan el combate de sus respectivos personajes.
- `objects/o_control`, `scripts/c_player_select`: selector inicial, creación exclusiva del jugador elegido, reinicio y HUD.
- `objects/o_att`, `objects/o_hitbox`, `objects/o_projectile`: jerarquía de ataques, golpes cuerpo a cuerpo y proyectiles.
- `objects/o_iceball`, `objects/o_spear`: proyectiles propios de cada personaje.
- `objects/o_terrain`, `objects/o_solid`: terreno y plataformas; movimiento separado por ejes como en la referencia.
- `scripts/c_fighter_*`: cambio de estado, movimiento, ataques y aplicación de daño.
- `sprites/s_subzero_*`, `sprites/s_scorpion_*`: fotogramas originales de las hojas de `sprite_ref/`, importados con transparencia y sin escalarlos.
- `Room1`: selector inicial y sala de un jugador con suelo, plataformas y barras de vida.

Los sprites del cuerpo usan lienzos de 176 × 176, origen `(80,168)` y máscaras físicas separadas de la animación. El dibujo se presenta al 65 %. Los proyectiles usan lienzos de 144 × 64. La caída y el aterrizaje están separados y las animaciones de acciones no se repiten automáticamente. Se conserva el desplazamiento de las poses dentro de las hojas originales.

## Vista y comprobaciones

Abre `preview/animaciones.html` para recorrer todas las animaciones, pausar y revisar los fotogramas de ambos personajes sin ejecutar GameMaker.

Desde la raíz de este repositorio:

```powershell
python tools/check_project.py
powershell -NoProfile -ExecutionPolicy Bypass -File tools/test_game.ps1
```

El primer comando verifica los recursos, referencias, fotogramas RGBA y capas editables. El segundo compila con el runtime local de GameMaker LTS 2026 y ejecuta 61 comprobaciones reales: selección de ambos jugadores, teclas de movimiento y ataques, aparición de un único jugador, reinicio, alcance de la cadena en ambas direcciones, pose de lanzamiento mientras existe la cadena y recuperación al desaparecer, movimiento y paredes, salto/caída/aterrizaje, golpes, daño, hielo, invulnerabilidad, lanza, deslizamiento y muerte.

Para volver a importar las hojas después de modificar el mapa de recortes en `tools/build_characters.py`:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/test_game.ps1 -Reimport
```

La generación conserva el código `.gml`, pero reconstruye los metadatos y la distribución de la sala de prueba. Los registros de compilación y pruebas se guardan en `.build/`.

Los objetivos usados para comprobar daño y efectos solo se crean en el modo `--self-test`. No aparecen al jugar normalmente.
