// Clase Tanque: guarda posición, dirección, teclas, vida y poderes.
class Tanque{
  int id;
  PVector pos=new PVector();
  float dx=0,dy=-1;
  boolean arriba,abajo,izquierda,derecha;
  int ultimoEnvio=0;

  // Vida y poderes
  int vida=VIDA_MAXIMA;
  float vidaVisible=VIDA_MAXIMA;   // baja de a poco para animar la barra
  int finVelocidad=0, finDañoDoble=0, finEscudo=0;
  boolean minaLista=false;
  int ultimoDisparo=0;             // para la recarga entre disparos

  // Detalles visuales
  float oruga=0;                   // mueve las marcas de las orugas
  int golpeadoHasta=0, avisoHasta=0;
  String aviso="";
  boolean exploto=false;

  // Crear el tanque de un jugador en su base.
  Tanque(int id){ this.id=id; reiniciar(); }

  // Volver a la base con vida llena y sin poderes.
  void reiniciar(){
    PVector inicio=posicionInicio(id);
    pos.set(inicio.x,inicio.y);
    dx=0; dy=id==SERVIDOR?1:-1;
    vida=VIDA_MAXIMA; vidaVisible=VIDA_MAXIMA;
    finVelocidad=0; finDañoDoble=0; finEscudo=0;
    minaLista=false; ultimoDisparo=0;
    exploto=false; avisoHasta=0;
    soltarTeclas();
  }

  // Actualizar el control de movimiento del modo red.
  void cambiarTecla(char tecla,int codigo,boolean pulsada){
    if(tecla=='w'||tecla=='W'||codigo==UP) arriba=pulsada;
    if(tecla=='s'||tecla=='S'||codigo==DOWN) abajo=pulsada;
    if(tecla=='a'||tecla=='A'||codigo==LEFT) izquierda=pulsada;
    if(tecla=='d'||tecla=='D'||codigo==RIGHT) derecha=pulsada;
  }

  // Actualizar las teclas WASD del jugador verde.
  void cambiarWASD(char tecla,boolean pulsada){
    if(tecla=='w'||tecla=='W') arriba=pulsada;
    if(tecla=='s'||tecla=='S') abajo=pulsada;
    if(tecla=='a'||tecla=='A') izquierda=pulsada;
    if(tecla=='d'||tecla=='D') derecha=pulsada;
  }

  // Actualizar las flechas del jugador azul.
  void cambiarFlechas(int codigo,boolean pulsada){
    if(codigo==UP) arriba=pulsada;
    if(codigo==DOWN) abajo=pulsada;
    if(codigo==LEFT) izquierda=pulsada;
    if(codigo==RIGHT) derecha=pulsada;
  }

  // Liberar todas las teclas al reiniciar la ronda.
  void soltarTeclas(){ arriba=abajo=izquierda=derecha=false; }

  boolean tieneVelocidad(){ return millis()<finVelocidad; }
  boolean tieneDañoDoble(){ return millis()<finDañoDoble; }
  boolean tieneEscudo(){ return millis()<finEscudo; }
  boolean recargando(){ return millis()-ultimoDisparo<RECARGA_DISPARO; }

  // Mover el tanque sin atravesar paredes (más rápido con el poder de velocidad).
  void mover(){
    if(vida<=0) return;
    float v=tieneVelocidad()?4:2;
    float vx=(derecha?v:0)-(izquierda?v:0);
    float vy=(abajo?v:0)-(arriba?v:0);
    if(vx!=0){ dx=vx/v; dy=0; }
    else if(vy!=0){ dx=0; dy=vy/v; }
    float antesX=pos.x, antesY=pos.y;
    if(!choca(pos.x+vx,pos.y)) pos.x+=vx;
    if(!choca(pos.x,pos.y+vy)) pos.y+=vy;

    float recorrido=dist(antesX,antesY,pos.x,pos.y);
    oruga=(oruga+recorrido*0.5)%5;
    if(recorrido>0 && tieneVelocidad() && frameCount%3==0)
      particulas.add(new Particula(pos.x-dx*14,pos.y-dy*14,color(225,205,160),0.7));
  }

  // Revisar las esquinas del tanque contra el mapa.
  boolean choca(float x,float y){
    return hayPared(x-10,y-10)||hayPared(x+10,y-10)
      ||hayPared(x-10,y+10)||hayPared(x+10,y+10);
  }

  // Disparar una bala o, si tiene una mina guardada, dejarla en el piso.
  void disparar(){
    if(vida<=0 || recargando()) return;
    ultimoDisparo=millis();
    if(minaLista){ ponerMina(this); return; }
    float x=pos.x+dx*21, y=pos.y+dy*21;
    int daño=tieneDañoDoble()?DAÑO_BALA*2:DAÑO_BALA;
    balas.add(new Bala(x,y,dx,dy,id,daño));
    explotar(x,y,5,color(255,220,120),1.5);   // fogonazo del cañón
    if(!modoOffline) enviarRed("BALA,"+id+","+x+","+y+","+dx+","+dy+","+daño);
  }

  // Efecto visual al recibir un impacto (la vida la resta golpear()).
  void recibirImpacto(){
    if(tieneEscudo()) explotar(pos.x,pos.y,12,color(120,215,255),2.5);
    else{
      golpeadoHasta=millis()+120;
      explotar(pos.x,pos.y,10,color(255,120,40),2.5);
    }
  }

  // Mostrar un texto corto que flota sobre el tanque.
  void mostrarAviso(String texto){ aviso=texto; avisoHasta=millis()+1500; }

  // Dibujar el tanque girado hacia donde apunta.
  void dibujar(){
    color tono=colorJugador(id);
    if(millis()<golpeadoHasta) tono=lerpColor(tono,color(255),0.6);
    if(vida<=0){
      tono=color(45,40,35);
      if(!exploto){
        exploto=true;
        explotar(pos.x,pos.y,35,color(255,140,40),4);
        explotar(pos.x,pos.y,15,color(255,230,130),2.5);
      }
      if(frameCount%6==0) particulas.add(new Particula(pos.x,pos.y,color(80),0.8));   // humo
    }
    color oscuro=lerpColor(tono,color(0),0.4);

    pushMatrix();
    translate(pos.x,pos.y);
    rectMode(CENTER); noStroke();
    fill(0,60); rect(3,4,30,30,6);                         // sombra
    if(tieneDañoDoble()){                                  // aura roja del daño doble
      fill(255,60,40,60+40*sin(millis()*0.012)); ellipse(0,0,46,46);
    }
    rotate(atan2(dy,dx)+HALF_PI);

    // Orugas con marcas que se mueven al avanzar
    fill(32); rect(-10,0,8,28,3); rect(10,0,8,28,3);
    stroke(70); strokeWeight(1.5);
    for(float y=-12+oruga;y<13;y+=5){ line(-13,y,-7,y); line(7,y,13,y); }
    noStroke();

    // Casco, cañón y torreta
    fill(oscuro); rect(0,0,20,24,4);
    fill(tono); rect(0,0,16,20,3);
    fill(255,45); rect(0,-5,12,6,2);
    fill(45); rect(0,-14,6,16,2);
    fill(30); rect(0,-22,8,4,1);
    fill(oscuro); ellipse(0,0,14,14);
    fill(lerpColor(tono,color(255),0.15)); ellipse(0,0,9,9);
    popMatrix();
    rectMode(CORNER);

    if(tieneEscudo()) dibujarEscudo();
    if(recargando() && vida>0) dibujarRecarga();
    dibujarAviso();
  }

  // Barrita blanca encima del tanque que se llena mientras recarga el disparo.
  void dibujarRecarga(){
    float avance=(millis()-ultimoDisparo)/(float)RECARGA_DISPARO;
    rectMode(CORNER); noStroke();
    fill(0,130); rect(pos.x-14,pos.y-26,28,5,2);
    fill(255); rect(pos.x-13,pos.y-25,26*avance,3,1);
  }

  // Dibujar la burbuja del escudo.
  void dibujarEscudo(){
    float r=44+sin(millis()*0.008)*2;
    fill(90,200,255,45); stroke(140,220,255,200); strokeWeight(2);
    ellipse(pos.x,pos.y,r,r);
    noStroke();
  }

  // Dibujar el aviso flotante mientras dure.
  void dibujarAviso(){
    if(millis()>=avisoHasta) return;
    float resto=(avisoHasta-millis())/1500.0;
    float y=pos.y-38-(1-resto)*15;
    textAlign(CENTER,CENTER); textSize(16);
    fill(0,200*resto); text(aviso,pos.x+1,y+2);
    fill(255,255*resto); text(aviso,pos.x,y);
  }
}

// Clase Bala: mueve un disparo y revisa pared o tanque.
class Bala{
  PVector pos=new PVector(), vel=new PVector();
  int dueño, daño;
  boolean muerta=false;

  // Crear una bala con posición, dirección, dueño y daño.
  Bala(float x,float y,float dx,float dy,int id,int daño){
    pos.set(x,y); vel.set(dx*5,dy*5); dueño=id; this.daño=daño;
  }

  // Mover la bala y comprobar sus impactos.
  void actualizar(){
    pos.add(vel);
    if(hayPared(pos.x,pos.y)){
      muerta=true;
      explotar(pos.x,pos.y,5,color(255,150,50),2);
      return;
    }
    if(rondaTerminada) return;
    Tanque objetivo=tanqueDe(otroJugador(dueño));
    if(dist(pos.x,pos.y,objetivo.pos.x,objetivo.pos.y)<18){
      muerta=true;
      objetivo.recibirImpacto();
      // Solo quien disparó cuenta el golpe (en local se cuentan los dos).
      if(modoOffline || dueño==miId) golpear(objetivo.id,daño);
    }
  }

  // Dibujar la bala con una pequeña estela (más grande y roja con daño doble).
  void dibujar(){
    boolean fuerte=daño>DAÑO_BALA;
    stroke(fuerte?color(255,90,50,120):color(255,220,80,110));
    strokeWeight(fuerte?5:3);
    line(pos.x,pos.y,pos.x-vel.x*3,pos.y-vel.y*3);
    noStroke();
    fill(fuerte?color(255,110,60):color(255,225,90));
    ellipse(pos.x,pos.y,fuerte?10:7,fuerte?10:7);
    fill(255,250,220); ellipse(pos.x,pos.y,3,3);
  }
}

// Actualizar las balas y partículas y quitar las que terminan.
void actualizarObjetos(){
  for(int i=balas.size()-1;i>=0;i--){
    Bala b=balas.get(i);
    if(!rondaTerminada) b.actualizar();
    b.dibujar();
    if(b.muerta) balas.remove(i);
  }
  for(int i=particulas.size()-1;i>=0;i--){
    Particula p=particulas.get(i); p.actualizar(); p.dibujar();
    if(p.vida<=0) particulas.remove(i);
  }
}

// El tanque que no es "yo": el jugador 2 en local o el rival en red.
Tanque otroTanque(){ return modoOffline?jugador2:rival; }

// Buscar el tanque de un jugador por su número.
Tanque tanqueDe(int id){ return yo.id==id?yo:otroTanque(); }

// Número del otro jugador.
int otroJugador(int id){ return id==SERVIDOR?CLIENTE:SERVIDOR; }

// Color y nombre de cada jugador.
color colorJugador(int id){ return id==SERVIDOR?color(70,200,95):color(80,140,245); }
String nombreJugador(int id){ return id==SERVIDOR?"VERDE":"AZUL"; }
