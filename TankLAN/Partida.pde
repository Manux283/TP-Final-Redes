// Partida: empezar, preparar rondas, daño y puntos.

// Preparar los dos jugadores en la misma computadora.
void iniciarOffline(){
  modoOffline=true; soyServidor=false; miId=SERVIDOR;
  yo=new Tanque(SERVIDOR);
  jugador2=new Tanque(CLIENTE);
  rival=null;
  reiniciarMarcador();
  prepararMapa();
  iniciado=true;
  mostrarRonda();
}

// Preparar los tanques para jugar por red.
void iniciarPartida(boolean servidorLocal){
  modoOffline=false;
  soyServidor=servidorLocal;
  esperandoSala=true;
  estadoConexion=soyServidor?"Esperando que se conecte un rival":"Conectando con el servidor";
  miId=soyServidor?SERVIDOR:CLIENTE;
  yo=new Tanque(miId);
  rival=new Tanque(otroJugador(miId));
  reiniciarMarcador();
  prepararMapa();
  iniciado=true;
  iniciarRed();
}

// Volver a cero el marcador y el mapa.
void reiniciarMarcador(){
  numeroRonda=1; numeroMapa=0;
  puntosVerde=0; puntosAzul=0;
  partidaTerminada=false; ganador=0;
}

// Dejar el mapa listo: tanques en su base, vida llena y objetos limpios.
void prepararMapa(){
  yo.reiniciar();
  otroTanque().reiniciar();
  balas.clear(); particulas.clear();
  cajas.clear(); minas.clear();
  kitDisponible[SERVIDOR]=true;
  kitDisponible[CLIENTE]=true;
  proximaCaja=millis()+CADA_CUANTO_CAJA;
  ganador=0;
}

// Mostrar el número de ronda durante dos segundos.
void mostrarRonda(){
  rondaTerminada=true;
  mostrarGanadorHasta=millis()+2000;
}

// Cuando termina el aviso, empezar la ronda o pasar al mapa siguiente.
void revisarFinDelAviso(){
  if(partidaTerminada || millis()<mostrarGanadorHasta) return;
  boolean primeraRonda=numeroRonda==1 && puntosVerde==0 && puntosAzul==0;
  if(primeraRonda) rondaTerminada=false;
  else if(modoOffline || soyServidor) siguienteRonda();
  // El cliente espera el mensaje NUEVA del servidor.
}

// Pasar al mapa siguiente. En red, el servidor le avisa al cliente.
void siguienteRonda(){
  numeroMapa=(numeroMapa+1)%mapas.length;
  prepararMapa();
  rondaTerminada=false;
  if(soyServidor) servidor.write("NUEVA,"+numeroMapa+","+numeroRonda+","+puntosVerde+","+puntosAzul+"\n");
}

// Dañar a un tanque. En red, la vida la decide solamente el servidor.
void golpear(int victimaId,int daño){
  if(modoOffline || soyServidor) aplicarDaño(victimaId,daño);
  else enviarRed("GOLPE,"+victimaId+","+daño);
}

// Restar vida y cerrar la ronda si el tanque queda sin vida. Con escudo no pasa nada.
void aplicarDaño(int victimaId,int daño){
  if(rondaTerminada) return;
  Tanque t=tanqueDe(victimaId);
  if(t.tieneEscudo()) return;
  t.vida=max(0,t.vida-daño);
  if(soyServidor) enviarVida();
  if(t.vida>0) return;
  if(modoOffline) cerrarRonda(otroJugador(victimaId));
  else terminarRonda(victimaId);
}

// Sumar el punto y revisar si alguien llegó a cinco.
void cerrarRonda(int idGanador){
  if(rondaTerminada) return;
  ganador=idGanador;
  if(ganador==SERVIDOR) puntosVerde++;
  else puntosAzul++;
  partidaTerminada=puntosVerde==5 || puntosAzul==5;
  if(!partidaTerminada) numeroRonda++;
  rondaTerminada=true;
  mostrarGanadorHasta=millis()+2000;
}

// Cerrar la conexión y volver al menú.
void volverAlMenu(){
  iniciado=false;
  esperandoSala=false;
  if(cliente!=null) cliente.stop();
  if(servidor!=null) servidor.stop();
  cliente=null; servidor=null;
  soyServidor=false; modoOffline=false;
  rondaTerminada=false;
  reiniciarMarcador();
  abrirMenu(false);
}
