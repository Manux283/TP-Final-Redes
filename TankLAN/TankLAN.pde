import processing.net.*;
import java.util.*;

// 1. Configuracion
final int TAM_CASILLA=40;
final int PUERTO=12345;
final int SERVIDOR=1, CLIENTE=2;
String ipServidor="127.0.0.1";

// 2. Red
Server servidor;
Client cliente;
boolean soyServidor=false, iniciado=false;
boolean modoOffline=false, menuMultijugador=false;
boolean esperandoSala=false;
String estadoConexion="Conectando con el servidor...";
boolean enterPulsado=false;
int[][] fondoCamuflaje=new int[15][15];
ArrayList<String> mensajesPendientes=new ArrayList<String>();

// 3. Partida
int miId, numeroMapa=0, ganador=0;
int numeroRonda=1, puntosVerde=0, puntosAzul=0;
boolean partidaTerminada=false;
boolean rondaTerminada=false, espacioPulsado=false;
int mostrarGanadorHasta=0;
Tanque yo, rival, jugador2;
ArrayList<Bala> balas=new ArrayList<Bala>();
ArrayList<Particula> particulas=new ArrayList<Particula>();

void setup(){
  size(600,600);
  frameRate(60);
  textFont(createFont("IMPACT",16));
  generarCamuflaje();
  generarCamuflajeDesierto();
}

// 4. Bucle principal: red, juego, dibujos
void draw(){
  background(25);
  if(!iniciado){ dibujarMenu(); return; }

  procesarMensajes();
  if(esperandoSala){ dibujarSalaEspera(); return; }
  dibujarMapa();

  dibujarMarcador();
  if(!rondaTerminada){
    if(modoOffline){
      yo.mover(); jugador2.mover();
      yo.dibujar(color(70,220,95));
      jugador2.dibujar(color(80,135,250));
    }else{
      yo.mover();
      yo.dibujar(miId==SERVIDOR?color(70,190,95):color(80,145,230));
      rival.dibujar(miId==SERVIDOR?color(80,145,230):color(70,190,95));
    }
    
    actualizarObjetos();
    
  }else{
    if(partidaTerminada){
      dibujarOverlay(ganador==SERVIDOR?"VERDE GANA":"AZUL GANA");
    }else{
      dibujarOverlay("RONDA "+numeroRonda);
      if(modoOffline && millis()>=mostrarGanadorHasta){
        if(numeroRonda==1 && puntosVerde==0 && puntosAzul==0) rondaTerminada=false;
        else iniciarRondaLocal();
      }else if(soyServidor && millis()>=mostrarGanadorHasta){
        if(numeroRonda==1 && puntosVerde==0 && puntosAzul==0) rondaTerminada=false;
        else empezarNuevaRonda();
      }else if(!soyServidor && !modoOffline && numeroRonda==1
          && puntosVerde==0 && puntosAzul==0 && millis()>=mostrarGanadorHasta){
        rondaTerminada=false;
      }
    }
  }
  

  if(!modoOffline && !esperandoSala && millis()-yo.ultimoEnvio>50){
    enviarRed("POS,"+miId+","+yo.pos.x+","+yo.pos.y+","+yo.dx+","+yo.dy);
    yo.ultimoEnvio=millis();
  }
}


void dibujarMarcador(){
  for(int i=0;i<5;i++){
    if(i<puntosVerde) fill(70,220,95); else noFill();
    stroke(70,220,95); ellipse(175+i*27,20,20,20);
  }
  for(int i=0;i<5;i++){
    if(i<puntosAzul) fill(80,135,250); else noFill();
    stroke(80,135,250); ellipse(425-i*27,20,20,20);
  }
}

void dibujarOverlay(String mensaje){
  noStroke(); fill(0,190); rectMode(CORNER); rect(0,0,width,height);
  fill(255); textAlign(CENTER); textSize(38); text(mensaje,300,300);
  if(partidaTerminada){
    textSize(18); text(puntosVerde+" - "+puntosAzul,300,340);
    textSize(15); text("ENTER o ESC para volver al menu",300,385);
  }
  textAlign(LEFT);
}

void generarCamuflaje(){
  color[] verdes={color(65,105,57),color(87,128,68),color(111,145,78),color(47,83,49)};
  for(int fila=0;fila<15;fila++) for(int col=0;col<15;col++)
    fondoCamuflaje[fila][col]=verdes[int(random(verdes.length))];
}


void dibujarFondoCamuflaje(){
  for(int fila=0;fila<15;fila++) for(int col=0;col<15;col++){
    fill(fondoCamuflaje[fila][col]);
    rect(col*40,fila*40,40,40);
  }
}

void dibujarMenu(){
  dibujarFondoCamuflaje();
  fill(255); textAlign(CENTER); textSize(56); text("TankLAN",300,190);
  if(!menuMultijugador){
    dibujarBoton("JUGAR",275,color(112,165,96));
    dibujarBoton("MULTIJUGADOR",355,color(83,143,91));
    textSize(15); textAlign(RIGHT); textLeading(22);textAlign(CENTER);
    text("CONTROLES:\nJUGADOR 1: WASD | ESPACIO\nJUGADOR 2: FLECHAS | ENTER",505,545);
  }else{
    textSize(24); text("MULTIJUGADOR",300,275);
    textSize(18); text("Pulsa S para crear la partida",300,335);
    text("Pulsa C para conectarte",300,375);
    text("ESC para volver",300,425);
  }
  textAlign(LEFT);
}

void dibujarSalaEspera(){
  dibujarFondoCamuflaje();
  noStroke(); fill(0,140); rect(0,0,width,height);
  fill(255); textAlign(CENTER); textSize(30);
  text("SALA DE ESPERA",300,245);
  textSize(18); text(estadoConexion,300,295);
  text("ESC para volver al menú",300,345);
  textAlign(LEFT);
}

void dibujarBoton(String etiqueta,int y,color tono){
  rectMode(CENTER); noStroke(); fill(tono);
  rect(300,y,260,58,12); fill(255); textAlign(CENTER);
  textSize(21); text(etiqueta,300,y+7); rectMode(CORNER);
}

void mousePressed(){
  if(iniciado || menuMultijugador) return;
  if(mouseX>170 && mouseX<430 && mouseY>246 && mouseY<304) iniciarOffline();
  else if(mouseX>170 && mouseX<430 && mouseY>326 && mouseY<384) menuMultijugador=true;
}

void iniciarPartida(boolean servidorLocal){
  modoOffline=false;
  numeroRonda=1; puntosVerde=0; puntosAzul=0;
  partidaTerminada=false; ganador=0;
  soyServidor=servidorLocal;
  esperandoSala=!servidorLocal;
  estadoConexion="Conectando con el servidor...";
  miId=soyServidor?SERVIDOR:CLIENTE;
  PVector inicioYo=posicionInicio(miId);
  PVector inicioRival=posicionInicio(soyServidor?CLIENTE:SERVIDOR);
  yo=new Tanque(inicioYo.x,inicioYo.y);
  rival=new Tanque(inicioRival.x,inicioRival.y);
  iniciado=true;
  iniciarRed();
  if(soyServidor) mostrarRonda();
}

void iniciarOffline(){
  modoOffline=true; soyServidor=false; miId=SERVIDOR;
  numeroRonda=1; puntosVerde=0; puntosAzul=0;
  partidaTerminada=false; ganador=0;
  PVector inicioVerde=posicionInicio(SERVIDOR);
  PVector inicioAzul=posicionInicio(CLIENTE);
  yo=new Tanque(inicioVerde.x,inicioVerde.y);
  jugador2=new Tanque(inicioAzul.x,inicioAzul.y);
  rival=null; iniciado=true;
  mostrarRonda();
}

void mostrarRonda(){
  rondaTerminada=true;
  mostrarGanadorHasta=millis()+2000;
}

void iniciarRondaLocal(){
  numeroMapa=(numeroMapa+1)%mapas.length;
  PVector inicioVerde=posicionInicio(SERVIDOR);
  PVector inicioAzul=posicionInicio(CLIENTE);
  yo.pos.set(inicioVerde.x,inicioVerde.y);
  jugador2.pos.set(inicioAzul.x,inicioAzul.y);
  yo.soltarTeclas(); jugador2.soltarTeclas();
  balas.clear(); particulas.clear(); ganador=0; partidaTerminada=false; rondaTerminada=false;
  espacioPulsado=false; enterPulsado=false;
}

void keyPressed(){
  if(partidaTerminada){
    if(key==ENTER||key==RETURN||keyCode==ENTER||keyCode==RETURN||key==ESC){
      if(key==ESC) key=0;
      volverAlMenu();
    }
    return;
  }
  if(!iniciado){
    if(menuMultijugador){
      if(key=='s'||key=='S') iniciarPartida(true);
      if(key=='c'||key=='C') iniciarPartida(false);
      if(key==ESC){ key=0; menuMultijugador=false; }
    }
    return;
  }
  if(esperandoSala && key==ESC){ key=0; iniciado=false; esperandoSala=false; return; }
  if(modoOffline){
    yo.cambiarWASD(key,true);
    jugador2.cambiarFlechas(keyCode,true);
    if(key==' '){
      if(!espacioPulsado && !rondaTerminada) yo.disparar(SERVIDOR);
      espacioPulsado=true;
    }
    if((key==ENTER||key==RETURN||keyCode==ENTER||keyCode==RETURN)){
      if(!enterPulsado && !rondaTerminada) jugador2.disparar(CLIENTE);
      enterPulsado=true;
    }
  }else{
    if(key==' '){
      if(!espacioPulsado && !rondaTerminada) yo.disparar(miId);
      espacioPulsado=true;
    }
    yo.cambiarTecla(key,keyCode,true);
  }
}


void volverAlMenu(){
  iniciado=false;
  esperandoSala=false;
  if(cliente!=null) cliente.stop();
  if(servidor!=null) servidor.stop();
  cliente=null; servidor=null;
  soyServidor=false; modoOffline=false; menuMultijugador=false;
  rondaTerminada=false; partidaTerminada=false;
  numeroRonda=1; numeroMapa=0; puntosVerde=0; puntosAzul=0; ganador=0;
}

void keyReleased(){
  if(key==' ') espacioPulsado=false;
  if(key==ENTER||key==RETURN||keyCode==ENTER||keyCode==RETURN) enterPulsado=false;
  if(!iniciado) return;
  if(modoOffline){
    yo.cambiarWASD(key,false);
    jugador2.cambiarFlechas(keyCode,false);
  }else yo.cambiarTecla(key,keyCode,false);
}

