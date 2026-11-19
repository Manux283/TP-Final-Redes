// La escucha guarda mensajes para procesarlos luego en draw().
// Inicio el servidor o intento conectar el cliente.
void iniciarRed(){
  if(soyServidor){
    servidor=new Server(this,PUERTO);
    thread("escucharRed");
  }else{
    thread("conectarEnSegundoPlano");
  }
}

// Conecto al servidor sin frenar la pantalla.
void conectarEnSegundoPlano(){
  try{
    cliente=new Client(this,ipServidor,PUERTO);
    if(cliente!=null && cliente.active()){
      estadoConexion="Conectado. Esperando al servidor...";
      thread("escucharRed");
    }else estadoConexion="No conecta. Revisa la IP y el puerto.";
  }catch(Exception e){
    estadoConexion="No conecta. Revisa la IP y el puerto.";
  }
}

// Recibo mensajes en un hilo separado.
void escucharRed(){
  while(iniciado) try{
    if(soyServidor){
      Client conexion=servidor.available();
      if(conexion!=null){
        String linea=conexion.readStringUntil('\n');
        if(linea!=null){
          linea=trim(linea);
          synchronized(mensajesPendientes){ mensajesPendientes.add(linea); }
          if(!linea.startsWith("GOLPE")) servidor.write(linea+"\n");
        }
      }
    }else if(cliente!=null && cliente.active() && cliente.available()>0){
      String linea=cliente.readStringUntil('\n');
      if(linea!=null) synchronized(mensajesPendientes){ mensajesPendientes.add(trim(linea)); }
    }
    Thread.sleep(5);
  }catch(Exception e){}
}

// Interpreto los mensajes y actualizo el juego.
void procesarMensajes(){
  synchronized(mensajesPendientes){
    for(String linea:mensajesPendientes) try{
      String[] dato=split(linea,',');
      if(dato[0].equals("POS") && int(dato[1])!=miId){
        rival.pos.set(float(dato[2]),float(dato[3]));
        rival.dx=float(dato[4]); rival.dy=float(dato[5]);
        if(!soyServidor && esperandoSala){
          esperandoSala=false; numeroRonda=1; puntosVerde=0; puntosAzul=0;
          partidaTerminada=false; ganador=0; mostrarRonda();
        }
      }else if(dato[0].equals("BALA") && int(dato[1])!=miId){
        balas.add(new Bala(float(dato[2]),float(dato[3]),float(dato[4]),float(dato[5]),int(dato[1])));
      }else if(dato[0].equals("GOLPE") && soyServidor){
        terminarRonda(int(dato[1]));
      }else if(dato[0].equals("FIN")){
        ganador=int(dato[1]); puntosVerde=int(dato[2]); puntosAzul=int(dato[3]);
        numeroRonda=int(dato[4]); partidaTerminada=boolean(dato[5]); rondaTerminada=true;
      }else if(dato[0].equals("NUEVA")){
        numeroMapa=int(dato[1]); numeroRonda=int(dato[2]);
        puntosVerde=int(dato[3]); puntosAzul=int(dato[4]);
        reiniciarPosiciones(); rondaTerminada=false; partidaTerminada=false;
      }
    }catch(Exception e){}
    mensajesPendientes.clear();
  }
}

// Envío una línea de información al otro jugador.
void enviarRed(String linea){
  if(soyServidor && servidor!=null) servidor.write(linea+"\n");
  else if(cliente!=null && cliente.active()) cliente.write(linea+"\n");
}

// El servidor decide quién ganó la ronda.
void terminarRonda(int jugadorMuerto){
  if(rondaTerminada) return;
  ganador=jugadorMuerto==SERVIDOR?CLIENTE:SERVIDOR;
  cerrarRonda(ganador);
  servidor.write("FIN,"+ganador+","+puntosVerde+","+puntosAzul+","+numeroRonda+","+partidaTerminada+"\n");
}

// Sumo el punto y reviso si alguien llegó a cinco.
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

// Cambio de mapa y aviso al cliente de la ronda nueva.
void empezarNuevaRonda(){
  numeroMapa=(numeroMapa+1)%mapas.length;
  reiniciarPosiciones();
  rondaTerminada=false;
  ganador=0;
  servidor.write("NUEVA,"+numeroMapa+","+numeroRonda+","+puntosVerde+","+puntosAzul+"\n");
}

// Devuelvo los tanques a sus posiciones y limpio objetos.
void reiniciarPosiciones(){
  PVector inicioYo=posicionInicio(miId);
  PVector inicioRival=posicionInicio(miId==SERVIDOR?CLIENTE:SERVIDOR);
  yo.pos.set(inicioYo.x,inicioYo.y);
  rival.pos.set(inicioRival.x,inicioRival.y);
  balas.clear(); particulas.clear();
}
