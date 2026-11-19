// hay 5 mapas fijos, y cada fila tiene 15 columnas. # es pared y . es piso.
String[][] mapas={
 {"...............",
 ".##.........##.",
 "..##.#####.##..",
 ".....#...#.....",
 "..##.#...#.##..",
 ".##.........##.",
 "......###......",
 "......#.#......",
 "......###......",
 ".##.........##.",
 "..##.#...#.##..",
 ".....#...#.....",
 "..##.#####.##..",
 ".##.........##.",
 "..............."},
{".......#.......",
".####..#..####.",
".#..#.....#..#.",
".#..#######..#.",
"...............",
".###.##.##.###.",
"...#.#...#.#...",
"##.#.#####.#.##",
"...#.......#...",
".###.#####.###.",
"...............",
".#..#######..#.",
".#..#.....#..#.",
".####..#..####.",
".......#......."},
{"...............",
"..##..###..##..",
"..##..###..##..",
"...............",
".....##.##.....",
".##..##.##..##.",
".##.........##.",
"......###......",
".##.........##.",
".##..##.##..##.",
".....##.##.....",
"...............",
"..##..###..##..",
"..##..###..##..",
"..............."},
{"...............",
".#####...#####.",
".#...........#.",
".#.##.###.##.#.",
"...#.......#.#.",
".#...##.##...#.",
".#.#.#...#.#.#.",
".#.#.#...#.#.#.",
".#.#.#...#.#.#.",
".#...##.##...#.",
".#.#.......#...",
".#.##.###.##.#.",
".#...........#.",
".#####...#####.",
"..............."},
{"...............",
"...##.....##...",
"...##.....##...",
"......###......",
"......###......",
"..##.......##..",
"..##.......##..",
"......###......",
"..##.......##..",
"..##.......##..",
"......###......",
"......###......",
"...##.....##...",
"...##.....##...",
"..............."}
};

// Posiciones libres para iniciar cada mapa: servidor X/Y, cliente X/Y en casillas.
int[][] posicionesInicio={
  {1,3,13,11}, {2,3,12,11}, {1,3,13,11}, {2,5,12,9}, {1,1,13,13}
};

// Calcular la posición inicial del jugador en píxeles.
PVector posicionInicio(int id){
  int indice=id==SERVIDOR?0:2;
  float x=posicionesInicio[numeroMapa][indice]*TAM_CASILLA+TAM_CASILLA/2;
  float y=posicionesInicio[numeroMapa][indice+1]*TAM_CASILLA+TAM_CASILLA/2;
  return new PVector(x,y);
}

int[][] tonosPiso = new int[15][15];

// Crear al azar los tonos del piso arenoso.
void generarCamuflajeDesierto() {
  int[] arena = {
    color(194,171,128),
    color(173,144,101),
    color(216,195,151),
    color(139,116,82)
  };

  for (int fila=0; fila<15; fila++) {
    for (int col=0; col<15; col++) {
      tonosPiso[fila][col] = arena[int(random(arena.length))];
    }
  }
}

// Dibujar el piso y las cajas del mapa.
void dibujarMapa(){
  for(int fila=0;fila<15;fila++) for(int col=0;col<15;col++){
    fill(tonosPiso[fila][col]);
    rect(col*TAM_CASILLA,fila*TAM_CASILLA,TAM_CASILLA,TAM_CASILLA);
    if(mapas[numeroMapa][fila].charAt(col)=='#'){
      fill(83,51,29); rect(col*TAM_CASILLA+3,fila*TAM_CASILLA+3,34,34);
      fill(135,83,43); rect(col*TAM_CASILLA+6,fila*TAM_CASILLA+6,28,28);
      fill(177,119,67); rect(col*TAM_CASILLA+10,fila*TAM_CASILLA+10,20,20);
    }
  }
}

// Comprobar si un punto toca una pared o el borde.
boolean hayPared(float x,float y){
  if(x<10||x>590||y<10||y>590) return true;
  int col=int(x/TAM_CASILLA), fila=int(y/TAM_CASILLA);
  return mapas[numeroMapa][fila].charAt(col)=='#';
}
