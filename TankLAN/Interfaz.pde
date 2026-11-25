// Interfaz de la partida: paneles laterales, barras de vida, medallas y avisos.

float escalaTexto=1;   // en pantallas poco anchas los textos del panel se achican

// Dibujar el panel lateral de un jugador: nombre, vida, puntos y poderes.
void dibujarPanel(int id,float x0){
  float ancho=mapaX;
  if(ancho<60) return;              // pantalla casi cuadrada: no hay lugar a los costados
  escalaTexto=min(1,ancho/150.0);
  Tanque t=tanqueDe(id);
  color c=colorJugador(id);
  boolean izquierda=id==SERVIDOR;
  float centro=x0+ancho/2, margen=14*escalaTexto;

  // Fondo de metal oscuro con rayas finas (bien distinto de la arena del mapa)
  noStroke(); rectMode(CORNER);
  fill(lerpColor(color(22,25,23),c,0.12)); rect(x0,0,ancho,600);
  stroke(255,7); strokeWeight(1);
  for(int y=3;y<600;y+=6) line(x0,y,x0+ancho,y);
  noStroke();

  // Esquina de arriba: nombre y barra de vida
  float xTexto=izquierda?x0+margen:x0+ancho-margen;
  textAlign(izquierda?LEFT:RIGHT,CENTER); textSize(26*escalaTexto);
  textoConSombra(nombreJugador(id),xTexto,26,c);
  t.vidaVisible=lerp(t.vidaVisible,t.vida,0.06);
  dibujarBarraVida(t,x0+margen,50,ancho-margen*2,20,c,izquierda);
  textAlign(izquierda?LEFT:RIGHT,CENTER); textSize(14*escalaTexto); fill(255,170);
  text(etiquetaJugador(id),xTexto,90);

  // Centro: medallas de puntos
  textAlign(CENTER,CENTER); textSize(16*escalaTexto); fill(255,120);
  text("PUNTOS",centro,150);
  int puntos=id==SERVIDOR?puntosVerde:puntosAzul;
  for(int i=0;i<5;i++) dibujarMedalla(centro,185+i*48,i<puntos,c);

  // Abajo: poderes activos
  textAlign(CENTER,CENTER); textSize(16*escalaTexto); fill(255,120);
  text("PODERES",centro,430);
  dibujarPoderesActivos(t,x0+margen,452,ancho-margen*2);
}

// Texto chico debajo de la barra: los controles en local, VOS/RIVAL en red.
String etiquetaJugador(int id){
  if(!modoOffline) return id==miId?"VOS":"RIVAL";
  return id==SERVIDOR?"WASD + ESPACIO":"FLECHAS + ENTER";
}

// Barra de vida con marco, brillo, rastro del daño y marcas cada 25 puntos.
void dibujarBarraVida(Tanque t,float x,float y,float w,float h,color c,boolean desdeIzquierda){
  noStroke(); rectMode(CORNER);
  fill(0,130); rect(x-3,y-3,w+6,h+6,7);               // marco
  fill(45,20,20); rect(x,y,w,h,5);                     // fondo vacío

  float rastro=w*t.vidaVisible/VIDA_MAXIMA;            // la parte que se va vaciando
  fill(255,230,150);
  rect(desdeIzquierda?x:x+w-rastro,y,rastro,h,5);

  float lleno=w*t.vida/VIDA_MAXIMA;
  color tono=t.vida>50?c:lerpColor(color(230,60,50),c,t.vida/50.0);   // se pone roja
  float xLleno=desdeIzquierda?x:x+w-lleno;
  if(lleno>0){
    fill(tono); rect(xLleno,y,lleno,h,5);
    fill(255,60); rect(xLleno+2,y+2,max(0,lleno-4),h/3,3);
  }

  stroke(0,90); strokeWeight(2);
  for(int i=1;i<4;i++) line(x+w*i/4,y,x+w*i/4,y+h);
  noStroke();

  if(t.vida>0 && t.vida<=25 && frameCount%40<20){      // titila con poca vida
    noFill(); stroke(255,70,60); strokeWeight(2); rect(x-3,y-3,w+6,h+6,7); noStroke();
  }
  textAlign(CENTER,CENTER); textSize(14);
  textoConSombra(str(t.vida),x+w/2,y+h/2-1,color(255));
}

// Dibujar una medalla de punto: dorada con estrella si se ganó, hueca si no.
void dibujarMedalla(float x,float y,boolean ganada,color c){
  noStroke();
  fill(0,100); ellipse(x+2,y+3,38,38);
  if(ganada){
    fill(150,110,35); ellipse(x,y,38,38);
    fill(230,190,80); ellipse(x,y,33,33);
    fill(c); ellipse(x,y,27,27);
    fill(255,60); ellipse(x-4,y-5,13,9);
    fill(255,245,200); estrella(x,y,9,4);
  }else{
    fill(50,53,51); ellipse(x,y,38,38);
    fill(20,22,21); ellipse(x,y,30,30);
    noFill(); stroke(c,80); strokeWeight(2); ellipse(x,y,22,22); noStroke();
  }
}

// Listar los poderes que tiene el tanque, con su tiempo restante.
void dibujarPoderesActivos(Tanque t,float x,float y,float w){
  float yFila=y;
  if(t.tieneVelocidad()){
    filaPoder(VELOCIDAD,(t.finVelocidad-millis())/(float)DURACION_PODER,x,yFila,w); yFila+=30;
  }
  if(t.tieneDañoDoble()){
    filaPoder(DAÑO_DOBLE,(t.finDañoDoble-millis())/(float)DURACION_PODER,x,yFila,w); yFila+=30;
  }
  if(t.escudo){ filaPoder(ESCUDO,1,x,yFila,w); yFila+=30; }
  if(t.minaLista){ filaPoder(MINA,1,x,yFila,w); yFila+=30; }
  if(yFila==y){
    textAlign(CENTER,CENTER); textSize(14*escalaTexto); fill(255,60);
    text("NINGUNO",x+w/2,y+8);
  }
}

// Una fila de poder: punto de color, nombre y barrita de tiempo.
void filaPoder(int tipo,float resto,float x,float y,float w){
  color c=colorPoder(tipo);
  noStroke(); rectMode(CORNER);
  fill(c); ellipse(x+6*escalaTexto,y+6,10*escalaTexto,10*escalaTexto);
  textAlign(LEFT,CENTER); textSize(14*escalaTexto); fill(255,220);
  text(nombresPoder[tipo],x+16*escalaTexto,y+5);
  fill(0,120); rect(x,y+15,w,5,3);
  fill(c); rect(x,y+15,w*resto,5,3);
}

// Sombra y borde a los costados del mapa para separarlo de los paneles.
void dibujarMarcoMapa(){
  strokeWeight(1);
  for(int i=1;i<14;i++){
    stroke(0,110-i*8);
    line(-i,0,-i,600); line(600+i,0,600+i,600);
  }
  stroke(70,45,25); strokeWeight(3);
  line(-1,0,-1,600); line(601,0,601,600);
  noStroke();
}

// Mostrar sobre el mapa quién ganó el punto, la ronda que sigue o el final.
void dibujarAvisoRonda(){
  float aparicion=constrain((millis()-(mostrarGanadorHasta-2000))/250.0,0,1);
  noStroke(); rectMode(CORNER);
  fill(0,140*aparicion); rect(0,0,600,600);

  // Franja del color del ganador
  color c=ganador==0?color(40):colorJugador(ganador);
  float alto=140*aparicion;
  fill(lerpColor(c,color(0),0.3),220); rect(0,300-alto/2,600,alto);
  fill(255,60); rect(0,300-alto/2,600,3); rect(0,300+alto/2-3,600,3);

  String titulo, detalle;
  if(partidaTerminada){
    titulo=nombreJugador(ganador)+" GANA";
    detalle=puntosVerde+" - "+puntosAzul;
  }else if(ganador!=0){
    titulo="PUNTO PARA "+nombreJugador(ganador);
    detalle="RONDA "+numeroRonda;
  }else{
    titulo="RONDA "+numeroRonda;
    detalle="¡PREPARADOS!";
  }
  textAlign(CENTER,CENTER);
  textSize(52*(0.7+0.3*aparicion)); textoConSombra(titulo,300,280,color(255));
  textSize(22); textoConSombra(detalle,300,336,color(255,230));
  if(partidaTerminada){
    textSize(16); fill(255,150+100*sin(millis()*0.005));
    text("ENTER PARA VOLVER AL MENÚ",300,400);
  }
}

// Escribir un texto con una sombra oscura abajo.
void textoConSombra(String texto,float x,float y,color c){
  fill(0,140); text(texto,x+2,y+3);
  fill(c); text(texto,x,y);
}

// Dibujar una estrella de cinco puntas.
void estrella(float x,float y,float radioGrande,float radioChico){
  beginShape();
  for(int i=0;i<10;i++){
    float angulo=-HALF_PI+i*PI/5;
    float r=i%2==0?radioGrande:radioChico;
    vertex(x+cos(angulo)*r,y+sin(angulo)*r);
  }
  endShape(CLOSE);
}
