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

// Centro en píxeles de una casilla.
PVector centroCasilla(int col,int fila){
  return new PVector(col*TAM_CASILLA+TAM_CASILLA/2,fila*TAM_CASILLA+TAM_CASILLA/2);
}

// Puntos de inicio fijos, libres en los cinco mapas.
PVector posicionInicio(int id){
  return id==SERVIDOR?centroCasilla(2,3):centroCasilla(12,11);
}

// Cada kit de auxilio está en la esquina de su base (libre en los cinco mapas).
PVector posicionKit(int id){
  return id==SERVIDOR?centroCasilla(0,0):centroCasilla(14,14);
}

int[][] tonosPiso = new int[15][15];

// Crear al azar los tonos del piso arenoso.
void generarCamuflajeDesierto() {
  int[] arena = {
    color(201,178,134),
    color(190,165,121),
    color(210,189,146),
    color(182,156,113)
  };

  for (int fila=0; fila<15; fila++) {
    for (int col=0; col<15; col++) {
      tonosPiso[fila][col] = arena[int(random(arena.length))];
    }
  }
}

// Dibujar el piso, las sombras y las cajas del mapa.
void dibujarMapa(){
  noStroke(); rectMode(CORNER);
  for(int fila=0;fila<15;fila++) for(int col=0;col<15;col++){
    int x=col*TAM_CASILLA, y=fila*TAM_CASILLA;
    fill(tonosPiso[fila][col]); rect(x,y,TAM_CASILLA,TAM_CASILLA);
    if((fila*7+col*13)%5==0){            // piedritas en algunas casillas
      fill(0,25); ellipse(x+12,y+28,4,3); ellipse(x+27,y+14,3,2);
    }
  }
  for(int fila=0;fila<15;fila++) for(int col=0;col<15;col++)
    if(esPared(col,fila)){ fill(0,55); rect(col*TAM_CASILLA+6,fila*TAM_CASILLA+7,34,34,3); }
  for(int fila=0;fila<15;fila++) for(int col=0;col<15;col++)
    if(esPared(col,fila)) dibujarPared(col*TAM_CASILLA,fila*TAM_CASILLA);
}

// Dibujar una caja de madera de pared.
void dibujarPared(int x,int y){
  fill(83,51,29); rect(x+3,y+3,34,34,3);
  fill(135,83,43); rect(x+6,y+6,28,28,2);
  fill(177,119,67); rect(x+10,y+10,20,20,2);
  fill(255,30); rect(x+6,y+6,28,3);                   // brillo de arriba
  fill(60,36,20);                                     // clavos
  ellipse(x+8,y+8,3,3); ellipse(x+32,y+8,3,3);
  ellipse(x+8,y+32,3,3); ellipse(x+32,y+32,3,3);
}

// Saber si una casilla es pared (afuera del mapa también cuenta como pared).
boolean esPared(int col,int fila){
  if(col<0||col>=15||fila<0||fila>=15) return true;
  return mapas[numeroMapa][fila].charAt(col)=='#';
}

// Comprobar si un punto toca una pared o el borde.
boolean hayPared(float x,float y){
  if(x<10||x>590||y<10||y>590) return true;
  return esPared(int(x/TAM_CASILLA),int(y/TAM_CASILLA));
}
