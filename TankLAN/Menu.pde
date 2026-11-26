// Menú principal, menú multijugador y sala de espera. Todo se maneja con el teclado.

boolean menuMultijugador=false;
int opcionMenu=0;
String[] opcionesMenu={"JUGAR","MULTIJUGADOR"};
String[] opcionesMulti={"CREAR PARTIDA","CONECTARSE","VOLVER"};
int[][] fondoCamuflaje;
Tanque tanqueMenuVerde, tanqueMenuAzul;

// Opciones del menú que se está mostrando.
String[] opcionesActuales(){ return menuMultijugador?opcionesMulti:opcionesMenu; }

// Mover la selección con las flechas y elegir con ENTER.
void teclaMenu(boolean esc,boolean enter){
  String[] opciones=opcionesActuales();
  if(keyCode==UP) opcionMenu=(opcionMenu+opciones.length-1)%opciones.length;
  if(keyCode==DOWN) opcionMenu=(opcionMenu+1)%opciones.length;
  if(menuMultijugador) escribirIp();
  if(enter) elegirOpcion(opciones[opcionMenu]);
  if(esc){
    if(menuMultijugador) abrirMenu(false);
    else exit();
  }
}

// En el menú multijugador, los números y el punto escriben la IP del servidor.
// Si se borra todo, vuelve a usar la IP encontrada automáticamente.
void escribirIp(){
  boolean valida=(key>='0' && key<='9') || key=='.';
  if(valida){
    if(!ipEscritaAMano) ipServidor="";   // al empezar a escribir se reemplaza la automática
    ipEscritaAMano=true;
    if(ipServidor.length()<15) ipServidor+=key;
  }
  if(key==BACKSPACE && ipServidor.length()>0) ipServidor=ipServidor.substring(0,ipServidor.length()-1);
  if(key==BACKSPACE && ipServidor.length()==0){
    ipEscritaAMano=false;
    ipServidor=ipEncontrada.equals("")?"127.0.0.1":ipEncontrada;
  }
}

// Texto que explica de dónde salió la IP.
String origenIp(){
  if(ipEscritaAMano) return "ESCRITA A MANO (BORRALA PARA USAR LA AUTOMÁTICA)";
  if(!ipEncontrada.equals("")) return "SERVIDOR ENCONTRADO AUTOMÁTICAMENTE";
  return "BUSCANDO SERVIDOR EN LA RED... (O ESCRIBÍ LA IP)";
}

// Hacer lo que dice la opción elegida.
void elegirOpcion(String opcion){
  if(opcion.equals("JUGAR")) iniciarOffline();
  if(opcion.equals("MULTIJUGADOR")) abrirMenu(true);
  if(opcion.equals("CREAR PARTIDA")) iniciarPartida(true);
  if(opcion.equals("CONECTARSE")) iniciarPartida(false);
  if(opcion.equals("VOLVER")) abrirMenu(false);
}

// Mostrar el menú principal o el multijugador, con la primera opción marcada.
void abrirMenu(boolean multijugador){
  menuMultijugador=multijugador;
  opcionMenu=0;
}

// Elegir al azar los colores verdes del fondo (cubre todo el ancho de la pantalla).
void generarCamuflaje(){
  color[] verdes={color(65,105,57),color(87,128,68),color(111,145,78),color(47,83,49)};
  int columnas=ceil(anchoVirtual/TAM_CASILLA);
  fondoCamuflaje=new int[15][columnas];
  for(int fila=0;fila<15;fila++) for(int col=0;col<columnas;col++)
    fondoCamuflaje[fila][col]=verdes[int(random(verdes.length))];
}

// Crear los dos tanques que adornan el título, mirándose.
void crearTanquesDelMenu(){
  tanqueMenuVerde=new Tanque(SERVIDOR);
  tanqueMenuVerde.pos.set(0,0); tanqueMenuVerde.dx=1; tanqueMenuVerde.dy=0;
  tanqueMenuAzul=new Tanque(CLIENTE);
  tanqueMenuAzul.pos.set(0,0); tanqueMenuAzul.dx=-1; tanqueMenuAzul.dy=0;
}

// Dibujar la grilla de camuflaje un poco oscurecida.
void dibujarFondoCamuflaje(){
  noStroke(); rectMode(CORNER);
  for(int fila=0;fila<15;fila++) for(int col=0;col<fondoCamuflaje[0].length;col++){
    fill(fondoCamuflaje[fila][col]);
    rect(col*TAM_CASILLA,fila*TAM_CASILLA,TAM_CASILLA,TAM_CASILLA);
  }
  fill(0,80); rect(0,0,anchoVirtual,600);
}

// Mostrar el título y las opciones del menú.
void dibujarMenu(){
  dibujarFondoCamuflaje();
  translate(mapaX,0);
  dibujarTitulo();
  String[] opciones=opcionesActuales();
  textAlign(CENTER,CENTER);
  if(!menuMultijugador){
    dibujarTarjeta(250,270);
    for(int i=0;i<opciones.length;i++) dibujarBoton(opciones[i],300+i*75,i==opcionMenu);
    textSize(17);
    fill(lerpColor(colorJugador(SERVIDOR),color(255),0.3)); text("VERDE:  WASD + ESPACIO",300,458);
    fill(lerpColor(colorJugador(CLIENTE),color(255),0.3)); text("AZUL:  FLECHAS + ENTER",300,486);
  }else{
    dibujarTarjeta(240,320);
    textSize(28); textoConSombra("MULTIJUGADOR",300,272,color(255));
    for(int i=0;i<opciones.length;i++) dibujarBoton(opciones[i],330+i*68,i==opcionMenu);
    String cursor=frameCount%60<30?"_":" ";
    textAlign(CENTER,CENTER); textSize(17); fill(255,230,140);
    text("IP DEL SERVIDOR: "+ipServidor+cursor,300,522);
    textSize(12); fill(255,140);
    text(origenIp(),300,545);
  }
  textAlign(CENTER,CENTER); textSize(14); fill(255,170);
  text("FLECHAS: ELEGIR   |   ENTER: ACEPTAR   |   ESC: "+(menuMultijugador?"VOLVER":"SALIR"),300,582);
}

// Dibujar el nombre del juego con sombra y los dos tanques a los lados.
void dibujarTitulo(){
  textAlign(CENTER,CENTER); textSize(84);
  fill(20,35,20); text("TankLAN",304,155);
  fill(255); text("TankLAN",300,150);
  textSize(18); fill(230,220,170); text("BATALLA DE TANQUES",300,212);
  dibujarTanqueDecorativo(tanqueMenuVerde,85,155);
  dibujarTanqueDecorativo(tanqueMenuAzul,515,155);
}

// Dibujar un tanque agrandado en una posición fija.
void dibujarTanqueDecorativo(Tanque t,float x,float y){
  pushMatrix();
  translate(x,y+sin(millis()*0.003+x)*3);
  scale(2.2);
  t.dibujar();
  popMatrix();
}

// Rectángulo oscuro detrás de los botones para que se lean mejor.
void dibujarTarjeta(float y,float alto){
  rectMode(CORNER);
  fill(0,130); stroke(255,25); strokeWeight(2);
  rect(140,y,320,alto,16);
  noStroke();
}

// Dibujar un botón; el elegido se ilumina y tiene flechas a los costados.
void dibujarBoton(String etiqueta,float y,boolean elegido){
  rectMode(CENTER); noStroke();
  fill(0,90); rect(300,y+5,260,56,12);                                   // sombra
  fill(elegido?color(112,175,96):color(60,95,58)); rect(300,y,260,56,12);
  fill(255,elegido?45:20); rect(300,y-12,248,22,10);                     // brillo
  if(elegido){
    noFill(); stroke(255,230,140); strokeWeight(3); rect(300,y,268,64,15); noStroke();
    float m=sin(millis()*0.008)*4;
    fill(255,230,140);
    triangle(138+m,y-10,138+m,y+10,152+m,y);
    triangle(462-m,y-10,462-m,y+10,448-m,y);
  }
  fill(elegido?color(255):color(200,215,195));
  textAlign(CENTER,CENTER); textSize(24); text(etiqueta,300,y-2);
  rectMode(CORNER);
}

// Informar que se está esperando al otro jugador.
void dibujarSalaEspera(){
  dibujarFondoCamuflaje();
  translate(mapaX,0);
  dibujarTarjeta(200,220);
  textAlign(CENTER,CENTER);
  textSize(32); textoConSombra("SALA DE ESPERA",300,240,color(255));
  textSize(18); fill(255,220); text(estadoConexion,300,285);
  if(soyServidor){                            // el cliente tiene que escribir esta IP
    textSize(20); fill(255,230,140); text("TU IP: "+miIpLocal,300,318);
  }
  for(int i=0;i<3;i++){                       // tres puntitos que laten
    fill(255,80+175*(sin(millis()*0.006-i*0.8)*0.5+0.5));
    ellipse(285+i*15,352,8,8);
  }
  textSize(15); fill(255,160); text("ESC PARA VOLVER AL MENÚ",300,392);
}
