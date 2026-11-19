# TankLAN

## Modos
- **JUGAR** inicia dos tanques en la misma computadora. Verde usa WASD y espacio; azul usa flechas y Enter.
- **MULTIJUGADOR** permite crear una partida con S o conectarse con C.

## Rondas y puntaje
Cada tanque obtiene un punto al ganar una ronda. El marcador superior muestra cinco círculos por color; se rellena uno por cada victoria. Al llegar a cinco puntos, aparece `VERDE GANA` o `AZUL GANA` sobre una pantalla oscura. Entre rondas se muestra el número de la siguiente ronda durante dos segundos. Los cinco mapas se repiten en orden mientras se juega hasta cinco puntos.

## Mapas y controles
Los tanques empiezan en lados opuestos del mapa, en casillas libres. Las posiciones cambian según el mapa. El patrón de camuflaje verde del menú se genera una vez al iniciar; el piso de juego es camuflaje de desierto. La ventana mide 600 × 600 píxeles.

## Red local
Para dos ventanas en una PC, usa `127.0.0.1` como `ipServidor`. Entre dos computadoras, el cliente debe usar la IPv4 local del servidor. El puerto TCP es 12345 y el firewall debe permitirlo.

## Pestañas
- `TankLAN.pde`: menú, modos de juego, marcador y presentaciones de ronda.
- `Mapas.pde`: mapas, colores de piso y posiciones de inicio opuestas.
- `Jugadores.pde`: clases `Tanque` y `Bala`.
- `Red.pde`: conexión, mensajes de puntaje y reinicios online.
- `Efectos.pde`: partículas al chocar con paredes.
