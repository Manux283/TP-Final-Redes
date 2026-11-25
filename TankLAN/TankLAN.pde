import processing.net.*;
import java.util.*;

// 1. Configuracion
final int TAM_CASILLA=40;
final int PUERTO=12345;
final int SERVIDOR=1, CLIENTE=2;
final int VIDA_MAXIMA=100, DAÑO_BALA=25, DAÑO_MINA=50;
final int RECARGA_DISPARO=500;   // medio segundo entre disparos
String ipServidor="127.0.0.1";

// 2. Pantalla completa: todo se dibuja como si el mapa midiera 600x600
//    y después se agranda hasta ocupar el alto de la pantalla.
float escala, anchoVirtual, mapaX;

// 3. Red
Server servidor;
Client cliente;
boolean soyServidor=false, iniciado=false;
boolean modoOffline=false, esperandoSala=false;
String estadoConexion="";
ArrayList<String> mensajesPendientes=new ArrayList<String>();

// 4. Partida
int miId, numeroMapa=0, ganador=0;
int numeroRonda=1, puntosVerde=0, puntosAzul=0;
boolean partidaTerminada=false, rondaTerminada=false;
boolean espacioPulsado=false, enterPulsado=false;
int mostrarGanadorHasta=0;
Tanque yo, rival, jugador2;
ArrayList<Bala> balas=new ArrayList<Bala>();
ArrayList<Particula> particulas=new ArrayList<Particula>();

// Preparar la pantalla completa y los fondos iniciales.
void setup(){
  fullScreen();
  frameRate(60);
  noCursor();
  textFont(createFont("Impact",48,true));
  escala=height/600.0;
  anchoVirtual=width/escala;
  mapaX=(anchoVirtual-600)/2;
  generarCamuflaje();
  generarCamuflajeDesierto();
  crearTanquesDelMenu();
}

// 5. Bucle principal: red, juego, dibujos
// Actualizar y dibujar cada cuadro de la partida.
void draw(){
  background(15);
  scale(escala);
  if(!iniciado){ dibujarMenu(); return; }

  procesarMensajes();
  enviarPosicion();
  if(esperandoSala){ dibujarSalaEspera(); return; }

  // Paneles a los costados y el mapa centrado
  dibujarPanel(SERVIDOR,0);
  dibujarPanel(CLIENTE,mapaX+600);
  translate(mapaX,0);
  dibujarMapa();
  dibujarPoderes();

  if(!rondaTerminada){
    yo.mover();
    if(modoOffline) jugador2.mover();
    revisarPoderes();
  }
  yo.dibujar();
  otroTanque().dibujar();
  actualizarObjetos();
  dibujarMarcoMapa();

  if(rondaTerminada){
    dibujarAvisoRonda();
    revisarFinDelAviso();
  }
}

// Responder a las teclas del menú y del juego.
void keyPressed(){
  boolean esEnter=key==ENTER||key==RETURN;
  boolean enter=esEnter && !enterPulsado;
  boolean espacio=key==' ' && !espacioPulsado;
  boolean esc=key==ESC;
  if(esEnter) enterPulsado=true;
  if(key==' ') espacioPulsado=true;
  if(esc) key=0;   // que ESC no cierre el programa por su cuenta

  if(!iniciado){ teclaMenu(esc,enter); return; }
  if(esc || (partidaTerminada && enter)){ volverAlMenu(); return; }
  if(esperandoSala || partidaTerminada) return;

  if(modoOffline){
    yo.cambiarWASD(key,true);
    jugador2.cambiarFlechas(keyCode,true);
    if(espacio && !rondaTerminada) yo.disparar();
    if(enter && !rondaTerminada) jugador2.disparar();
  }else{
    yo.cambiarTecla(key,keyCode,true);
    if(espacio && !rondaTerminada) yo.disparar();
  }
}

// Registrar cuándo se sueltan las teclas.
void keyReleased(){
  if(key==' ') espacioPulsado=false;
  if(key==ENTER||key==RETURN) enterPulsado=false;
  if(!iniciado) return;
  if(modoOffline){
    yo.cambiarWASD(key,false);
    jugador2.cambiarFlechas(keyCode,false);
  }else yo.cambiarTecla(key,keyCode,false);
}
