# TankLAN

## Modos
- **JUGAR** inicia dos tanques en la misma computadora. Verde usa WASD y espacio; azul usa flechas y Enter.
- **MULTIJUGADOR** permite crear una partida o conectarse a una.

Todo se maneja con el teclado: en los menús se eligen las opciones con las flechas ↑ ↓ y se acepta con Enter. ESC vuelve atrás (en el menú principal cierra el juego, y durante una partida vuelve al menú).

## Pantalla
El juego se abre en pantalla completa. El mapa es un cuadrado que ocupa todo el alto y queda centrado. A los costados hay dos paneles de metal oscuro, uno por jugador (verde a la izquierda y azul a la derecha), con:
- el nombre y la **barra de vida** en la esquina de arriba (se pone roja y titila con poca vida),
- las **medallas de puntos** en el centro,
- los **poderes activos** abajo, con su tiempo restante.

Internamente todo se dibuja como si el mapa midiera 600 × 600 y después se agranda con `scale()`, así que la lógica del mapa no cambia según la pantalla.

## Vida, rondas y puntaje
Cada tanque tiene 100 de vida. Una bala saca 25 (4 impactos) y una mina saca 50. Cuando un tanque se queda sin vida explota y aparece **PUNTO PARA VERDE** o **PUNTO PARA AZUL** junto con el número de la ronda siguiente. El primero en llegar a cinco puntos gana la partida (`VERDE GANA` / `AZUL GANA`). Los cinco mapas se repiten en orden.

## Poderes
Cada 20 segundos aparece una **caja de madera con un "?"** en una casilla libre al azar (como máximo 2 a la vez). Al pasar por encima se obtiene un poder aleatorio:

| Poder | Efecto |
|---|---|
| Velocidad | Se mueve al doble de velocidad durante 8 s |
| Daño x2 | Las balas sacan 50 durante 8 s |
| Escudo | Absorbe el próximo impacto (bala o mina) |
| Mina | El próximo disparo deja una mina en el piso; explota cuando el rival la pisa |

Además, al empezar cada mapa hay un **kit de auxilio** (cruz verde) en la esquina de la base de cada jugador. Solo lo puede usar su dueño, restaura toda la vida y aparece una sola vez por mapa: para curarse hay que volver a la base.

## Red local
Para dos ventanas en una PC, usa `127.0.0.1` como `ipServidor`. Entre dos computadoras, el cliente debe usar la IPv4 local del servidor. El puerto TCP es 12345 y el firewall debe permitirlo. La partida empieza cuando los dos jugadores están conectados. En red, la vida la decide el servidor; los mensajes están explicados al principio de `Red.pde`.

## Pestañas
- `TankLAN.pde`: configuración, variables globales, `setup()`, `draw()` y teclado.
- `Partida.pde`: empezar partidas, preparar rondas, daño y puntos.
- `Menu.pde`: menú principal, menú multijugador y sala de espera.
- `Interfaz.pde`: paneles laterales, barras de vida, medallas y avisos de ronda.
- `Mapas.pde`: mapas, piso, paredes y posiciones de inicio y de los kits.
- `Jugadores.pde`: clases `Tanque` y `Bala`.
- `Poderes.pde`: cajas de poder, minas y kits de auxilio.
- `Red.pde`: conexión y mensajes entre servidor y cliente.
- `Efectos.pde`: partículas (chispas, explosiones, humo y polvo).
