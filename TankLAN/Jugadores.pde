// clase tanque: guarda posicion, direccion y teclas pulsadas.
class Tanque{
  PVector pos=new PVector();
  float dx=0,dy=-1;
  boolean arriba,abajo,izquierda,derecha;
  int ultimoEnvio=0;

  // Creo el tanque en la posición inicial.
  Tanque(float x,float y){ pos.set(x,y); }

  // Actualizo el control de movimiento del modo red.
  void cambiarTecla(char tecla,int codigo,boolean pulsada){
    if(tecla=='w'||tecla=='W'||codigo==UP) arriba=pulsada;
    if(tecla=='s'||tecla=='S'||codigo==DOWN) abajo=pulsada;
    if(tecla=='a'||tecla=='A'||codigo==LEFT) izquierda=pulsada;
    if(tecla=='d'||tecla=='D'||codigo==RIGHT) derecha=pulsada;
  }

  // Actualizo las teclas WASD del jugador verde.
  void cambiarWASD(char tecla,boolean pulsada){
    if(tecla=='w'||tecla=='W') arriba=pulsada;
    if(tecla=='s'||tecla=='S') abajo=pulsada;
    if(tecla=='a'||tecla=='A') izquierda=pulsada;
    if(tecla=='d'||tecla=='D') derecha=pulsada;
  }

  // Actualizo las flechas del jugador azul.
  void cambiarFlechas(int codigo,boolean pulsada){
    if(codigo==UP) arriba=pulsada;
    if(codigo==DOWN) abajo=pulsada;
    if(codigo==LEFT) izquierda=pulsada;
    if(codigo==RIGHT) derecha=pulsada;
  }

  // Libero todas las teclas al reiniciar la ronda.
  void soltarTeclas(){ arriba=abajo=izquierda=derecha=false; }

  // Muevo el tanque sin atravesar paredes.
  void mover(){
    float vx=(derecha?2:0)-(izquierda?2:0);
    float vy=(abajo?2:0)-(arriba?2:0);
    if(vx!=0){ dx=vx/2; dy=0; }
    else if(vy!=0){ dx=0; dy=vy/2; }
    if(!choca(pos.x+vx,pos.y)) pos.x+=vx;
    if(!choca(pos.x,pos.y+vy)) pos.y+=vy;
  }

  // Reviso las esquinas del tanque contra el mapa.
  boolean choca(float x,float y){
    return hayPared(x-10,y-10)||hayPared(x+10,y-10)
      ||hayPared(x-10,y+10)||hayPared(x+10,y+10);
  }

  // Dibujo el tanque y apunto el cañón sin deformarlo.
  void dibujar(color colorTanque){
    rectMode(CENTER); noStroke(); fill(35);
    rect(pos.x-10,pos.y,7,26); rect(pos.x+10,pos.y,7,26);
    fill(colorTanque); rect(pos.x,pos.y,20,22);
    fill(25); rect(pos.x,pos.y,10,10);
    if(dy<0) rect(pos.x,pos.y-15,5,14);
    if(dy>0) rect(pos.x,pos.y+15,5,14);
    if(dx<0) rect(pos.x-15,pos.y,14,5);
    if(dx>0) rect(pos.x+15,pos.y,14,5);
    rectMode(CORNER);
  }

  // Creo una bala y la envío al rival si juego en red.
  void disparar(int id){
    float x=pos.x+dx*21, y=pos.y+dy*21;
    balas.add(new Bala(x,y,dx,dy,id));
    if(!modoOffline) enviarRed("BALA,"+id+","+x+","+y+","+dx+","+dy);
  }
}

// Clase Bala: mueve un disparo y revisa pared o tanque.
class Bala{
  PVector pos=new PVector(), vel=new PVector();
  int dueño;
  boolean muerta=false;

  // Creo una bala con posición, dirección y dueño.
  Bala(float x,float y,float dx,float dy,int id){
    pos.set(x,y); vel.set(dx*5,dy*5); dueño=id;
  }

  // Muevo la bala y compruebo sus impactos.
  void actualizar(){
    pos.add(vel);
    if(hayPared(pos.x,pos.y)){
      muerta=true;
      for(int i=0;i<4;i++) particulas.add(new Particula(pos.x,pos.y));
      return;
    }
    if(rondaTerminada) return;
    if(modoOffline){
      Tanque objetivo=dueño==SERVIDOR?jugador2:yo;
      if(dist(pos.x,pos.y,objetivo.pos.x,objetivo.pos.y)<18){
        muerta=true; cerrarRonda(dueño);
      }
    }else if(dueño==miId && dist(pos.x,pos.y,rival.pos.x,rival.pos.y)<18){
      muerta=true;
      if(soyServidor) terminarRonda(CLIENTE);
      else enviarRed("GOLPE,"+SERVIDOR);
    }
  }

  // Dibujo la bala en pantalla.\r\n  void dibujar(){ noStroke(); fill(255,220,80); ellipse(pos.x,pos.y,7,7); }
}

// Actualizo las balas y partículas y quito las que terminan.
void actualizarObjetos(){
  for(int i=balas.size()-1;i>=0;i--){
    Bala b=balas.get(i); b.actualizar(); b.dibujar();
    if(b.muerta) balas.remove(i);
  }
  for(int i=particulas.size()-1;i>=0;i--){
    Particula p=particulas.get(i); p.actualizar(); p.dibujar();
    if(p.vida<=0) particulas.remove(i);
  }
}
