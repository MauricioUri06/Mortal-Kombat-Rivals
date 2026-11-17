# Mortal Kombat Rivals

Plataformero 2D con temática de Mortal Kombat hecho en GameMaker LTS 2026 por Gaira Games. Abre `MortalKombatRivals.yyp` y pulsa **F5**.

Al iniciar aparece el logo de Gaira Games y luego el menú principal (**Jugar** / **Salir**). En el selector eliges a **Sub-Zero** o a **Scorpion**. Cada uno tiene una habilidad propia para cruzar los niveles, y el luchador que no elegiste es el jefe final.

## Controles

| Acción | Tecla |
| --- | --- |
| Moverse | A / D o ← / → |
| Saltar / doble salto | W o Espacio |
| Agacharse | S o ↓ |
| Golpe / patada | Clic izquierdo / clic derecho (mantener repite) |
| Ataque a distancia | Q |
| Deslizamiento | Shift |
| Habilidad: gancho (Scorpion) o puente de hielo (Sub-Zero) | Alt |
| Dash (se desbloquea con el power-up) | E |
| Pausa | Esc |

## Mecánicas

- **Wall jump:** en el aire, contra una pared, el personaje se agarra unos instantes; con salto rebota al lado contrario.
- **Gancho de Scorpion:** se jala hacia un `o_gancho` cercano.
- **Puente de Sub-Zero:** crea un `o_puente_hielo` temporal sobre un vacío.
- **Dash:** impulso horizontal con espejismos de color; usar el gancho o el puente lo recupera.
- **Checkpoints:** se agarran una sola vez y curan. Al morir, el nivel empieza desde el comienzo.
- **Caídas:** si el jugador cae demasiado tiempo vuelve al último suelo firme (en el Nivel 2, al último checkpoint) y pierde 10 de vida.
- **Plataformas de un solo sentido:** `o_nube` y el puente se atraviesan desde abajo y sostienen desde arriba.
- **Enemigos:** Baraka (saltador) y Goro (patrulla y embiste) se activan cuando el jugador entra en su rango.

## Niveles

`Nivel1` (torre vertical), `Nivel2` y `Nivel3` (pelea contra el jefe). Los niveles se conectan con `o_next` / `o_next_down` y un fundido a negro.

Objetos que se colocan en las rooms: `o_control`, `o_spawn_player`, `o_spawn_boss`, `o_checkpoint`, `o_trampa`, `o_nube`, `o_gancho`, `o_puente_hielo`, `o_powerup_dash`, `o_baraka`, `o_goro`, `o_next`, `o_next_down` y los carteles de tutorial `o_tuto_*`.

## Organización

- `objects/o_fighter`: base de los luchadores (movimiento, estados, wall jump, dash, gancho, caídas).
- `objects/o_scorpion`, `objects/o_subzero`, `objects/o_player_*`, `objects/o_boss_*`: personajes, jugador y jefe.
- `objects/o_control`: menú, selector, pausa, HUD y reaparición.
- `scripts/c_fighter_*`: estados, movimiento, ataques y daño.
- `scripts/c_habilidades`: gancho, puente y plataformas de un solo sentido.
- `scripts/c_boss_ai`: inteligencia del jefe.
- `scripts/c_transicion`: cambio de nivel, reinicio y fundidos.
- `scripts/c_fondo`: fondo de cada nivel que sigue a la cámara.
- `scripts/c_pause_menu`, `scripts/c_menu_principal`, `scripts/c_player_select`: menús.
- `scripts/c_tutorial`, `scripts/c_sonidos`: carteles de tutorial y efectos de sonido.
