// Poderes: cajas sorpresa, minas y kits de auxilio.

// Tipos de poder que puede traer una caja.
final int VELOCIDAD=0, DAÑO_DOBLE=1, ESCUDO=2, MINA=3;
final int DURACION_PODER=8000;       // velocidad y daño doble duran 8 segundos
final int CADA_CUANTO_CAJA=20000;    // aparece una caja cada 20 segundos
final int MAXIMO_CAJAS=2;
String[] nombresPoder={"VELOCIDAD","DAÑO X2","ESCUDO","MINA"};

ArrayList<Caja> cajas=new ArrayList<Caja>();
ArrayList<Mina> minas=new ArrayList<Mina>();
boolean[] kitDisponible=new boolean[3];   // posición 1: verde, posición 2: azul
int proximaCaja=0;

// Color que representa a cada poder.
color colorPoder(int tipo){
  if(tipo==VELOCIDAD) return color(255,210,60);
  if(tipo==DAÑO_DOBLE) return color(240,80,60);
  if(tipo==ESCUDO) return color(90,200,255);
  return color(150,150,155);
}

// Clase Caja: caja de madera con un "?" que esconde un poder al azar.
class Caja{
  int col,fila,tipo;
  PVector pos;

  // Crear la caja en el centro de una casilla.
  Caja(int col,int fila,int tipo){
    this.col=col; this.fila=fila; this.tipo=tipo;
    pos=centroCasilla(col,fila);
  }

  // Dibujar la caja flotando con un brillo dorado.
  void dibujar(){
    float flotar=sin(millis()*0.005+col)*2;
    pushMatrix();
    translate(pos.x,pos.y);
    rectMode(CENTER); noStroke();
    fill(0,60); ellipse(2,15,26,8);                              // sombra
    translate(0,flotar);
    fill(255,220,90,60+40*sin(millis()*0.006)); rect(0,0,36,36,9);  // brillo
    fill(105,65,32); rect(0,0,27,27,3);                          // marco
    fill(196,140,80); rect(0,0,22,22,2);                         // tablas
    stroke(140,92,50); strokeWeight(1.5);
    line(-11,-4,11,-4); line(-11,4,11,4);
    noStroke();
    textAlign(CENTER,CENTER); textSize(21);
    fill(70,40,15); text("?",1,0);
    fill(255,225,80); text("?",0,-2);
    popMatrix();
    rectMode(CORNER);
  }
}

// Clase Mina: explota cuando el rival pasa por encima.
class Mina{
  PVector pos;
  int dueño;
  boolean explotada=false;

  // Crear la mina en el lugar donde estaba el tanque.
  Mina(float x,float y,int id){ pos=new PVector(x,y); dueño=id; }

  // Revisar si el rival la pisó.
  void actualizar(){
    if(rondaTerminada) return;
    Tanque victima=tanqueDe(otroJugador(dueño));
    if(dist(pos.x,pos.y,victima.pos.x,victima.pos.y)<18){
      explotada=true;
      explotar(pos.x,pos.y,30,color(255,140,40),4);
      explotar(pos.x,pos.y,15,color(90),2);
      victima.recibirImpacto();
      if(modoOffline || dueño==miId) golpear(victima.id,DAÑO_MINA);
    }
  }

  // Dibujar la mina gris oscura con la luz roja titilando en el medio.
  void dibujar(){
    noStroke();
    fill(0,70); ellipse(pos.x+2,pos.y+3,22,22);
    fill(55); ellipse(pos.x,pos.y,22,22);
    fill(40);
    for(int i=0;i<4;i++){
      float a=QUARTER_PI+i*HALF_PI;
      ellipse(pos.x+cos(a)*8,pos.y+sin(a)*8,5,5);
    }
    fill(75); ellipse(pos.x,pos.y,12,12);
    boolean prendida=frameCount%40<20;
    if(prendida){ fill(255,40,40,90); ellipse(pos.x,pos.y,14,14); }
    fill(prendida?color(255,50,50):color(140,20,20)); ellipse(pos.x,pos.y,7,7);
  }
}

// Dibujar kits, cajas y minas (las minas también se revisan acá).
void dibujarPoderes(){
  dibujarKit(SERVIDOR);
  dibujarKit(CLIENTE);
  for(Caja c:cajas) c.dibujar();
  for(int i=minas.size()-1;i>=0;i--){
    Mina m=minas.get(i);
    m.actualizar();
    if(m.explotada) minas.remove(i);
    else m.dibujar();
  }
}

// Dibujar el kit de auxilio (cruz verde) con un anillo del color de su dueño.
void dibujarKit(int id){
  if(!kitDisponible[id]) return;
  PVector p=posicionKit(id);
  pushMatrix();
  translate(p.x,p.y);
  scale(1+sin(millis()*0.006)*0.06);
  rectMode(CENTER); noStroke();
  fill(0,60); rect(2,3,26,26,6);
  noFill(); stroke(colorJugador(id),150); strokeWeight(2); ellipse(0,0,36,36);
  noStroke();
  fill(245); rect(0,0,24,24,6);
  fill(40,170,70); rect(0,0,17,6,1); rect(0,0,6,17,1);
  popMatrix();
  rectMode(CORNER);
}

// Crear cajas cada 20 segundos y revisar si algún tanque agarra algo.
void revisarPoderes(){
  if((modoOffline || soyServidor) && millis()>=proximaCaja){
    crearCaja();
    proximaCaja=millis()+CADA_CUANTO_CAJA;
  }
  revisarRecogidas(yo);
  if(modoOffline) revisarRecogidas(jugador2);
}

// Poner una caja con un poder al azar en una casilla libre.
void crearCaja(){
  if(cajas.size()>=MAXIMO_CAJAS) return;
  for(int intento=0;intento<100;intento++){
    int col=int(random(15)), fila=int(random(15));
    if(casillaLibreParaCaja(col,fila)){
      int tipo=int(random(4));
      cajas.add(new Caja(col,fila,tipo));
      if(soyServidor) enviarRed("CAJA,"+col+","+fila+","+tipo);
      return;
    }
  }
}

// Una casilla sirve si es piso, no está encerrada y está lejos de los tanques y los kits.
boolean casillaLibreParaCaja(int col,int fila){
  if(esPared(col,fila) || buscarCaja(col,fila)!=null) return false;
  boolean encerrada=esPared(col+1,fila) && esPared(col-1,fila)
    && esPared(col,fila+1) && esPared(col,fila-1);
  if(encerrada) return false;
  PVector p=centroCasilla(col,fila);
  return p.dist(yo.pos)>100 && p.dist(otroTanque().pos)>100
    && p.dist(posicionKit(SERVIDOR))>1 && p.dist(posicionKit(CLIENTE))>1;
}

// Buscar la caja que está en una casilla.
Caja buscarCaja(int col,int fila){
  for(Caja c:cajas) if(c.col==col && c.fila==fila) return c;
  return null;
}

// Ver si el tanque toca una caja o su propio kit de auxilio.
void revisarRecogidas(Tanque t){
  for(int i=cajas.size()-1;i>=0;i--){
    Caja c=cajas.get(i);
    if(t.pos.dist(c.pos)<24){
      cajas.remove(i);
      aplicarPoder(t,c.tipo);
      if(!modoOffline) enviarRed("TOMA,"+t.id+","+c.col+","+c.fila);
    }
  }
  // El kit solo lo puede usar su dueño, y solo si le falta vida.
  if(kitDisponible[t.id] && t.vida<VIDA_MAXIMA && t.pos.dist(posicionKit(t.id))<24){
    usarKit(t.id);
    if(!modoOffline) enviarRed("KIT,"+t.id);
  }
}

// Darle al tanque el poder que salió en la caja.
void aplicarPoder(Tanque t,int tipo){
  if(tipo==VELOCIDAD) t.finVelocidad=millis()+DURACION_PODER;
  if(tipo==DAÑO_DOBLE) t.finDañoDoble=millis()+DURACION_PODER;
  if(tipo==ESCUDO) t.escudo=true;
  if(tipo==MINA) t.minaLista=true;
  t.mostrarAviso(nombresPoder[tipo]);
  explotar(t.pos.x,t.pos.y,12,colorPoder(tipo),2);
}

// Quitar el kit del mapa y curar al tanque (en red, la vida la pone el servidor).
void usarKit(int id){
  kitDisponible[id]=false;
  Tanque t=tanqueDe(id);
  t.mostrarAviso("+VIDA");
  explotar(t.pos.x,t.pos.y,14,color(80,220,110),2);
  if(modoOffline || soyServidor) t.vida=VIDA_MAXIMA;
  if(soyServidor) enviarVida();
}

// Dejar la mina guardada en el lugar donde está el tanque.
void ponerMina(Tanque t){
  t.minaLista=false;
  minas.add(new Mina(t.pos.x,t.pos.y,t.id));
  if(!modoOffline) enviarRed("MINA,"+t.id+","+t.pos.x+","+t.pos.y);
}
