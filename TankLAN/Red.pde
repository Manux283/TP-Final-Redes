// Red: conexión, mensajes y decisiones del servidor.
// Cada mensaje es una línea con datos separados por comas:
//   POS,id,x,y,dx,dy          posición de un tanque
//   BALA,id,x,y,dx,dy,daño    disparo nuevo
//   GOLPE,victima,daño        el cliente avisa que pegó (lo resuelve el servidor)
//   VIDA,v1,v2,e1,e2          el servidor manda la vida y los escudos de los dos
//   CAJA,col,fila,tipo        el servidor crea una caja de poder
//   TOMA,id,col,fila          un tanque agarró una caja
//   MINA,id,x,y               un tanque dejó una mina
//   KIT,id                    un tanque usó su kit de auxilio
//   FIN,ganador,pv,pa,ronda,terminada   terminó una ronda
//   NUEVA,mapa,ronda,pv,pa    empieza la ronda siguiente

// Iniciar el servidor o conectar el cliente.
void iniciarRed(){
  if(soyServidor){
    servidor=new Server(this,PUERTO);
    thread("escucharRed");
  }else{
    thread("conectarEnSegundoPlano");
  }
}

// Conectar al servidor sin frenar la pantalla.
void conectarEnSegundoPlano(){
  try{
    cliente=new Client(this,ipServidor,PUERTO);
    if(cliente!=null && cliente.active()){
      estadoConexion="Conectado. Esperando al servidor";
      thread("escucharRed");
    }else estadoConexion="No conecta. Revisa la IP y el puerto.";
  }catch(Exception e){
    estadoConexion="No conecta. Revisa la IP y el puerto.";
  }
}

// Recibir mensajes en un hilo separado y guardarlos para procesarlos en draw().
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

// Procesar todos los mensajes que llegaron.
void procesarMensajes(){
  synchronized(mensajesPendientes){
    for(String linea:mensajesPendientes) try{
      procesarMensaje(split(linea,','));
    }catch(Exception e){}
    mensajesPendientes.clear();
  }
}

// Interpretar un mensaje y actualizar el juego.
// Los mensajes con id se ignoran si son míos (el servidor reenvía todo).
void procesarMensaje(String[] dato){
  String tipo=dato[0];
  if(tipo.equals("POS") && int(dato[1])!=miId){
    recibirPosicion(dato);
  }else if(tipo.equals("BALA") && int(dato[1])!=miId){
    balas.add(new Bala(float(dato[2]),float(dato[3]),float(dato[4]),float(dato[5]),int(dato[1]),int(dato[6])));
  }else if(tipo.equals("TOMA") && int(dato[1])!=miId){
    Caja c=buscarCaja(int(dato[2]),int(dato[3]));
    if(c!=null){ cajas.remove(c); aplicarPoder(tanqueDe(int(dato[1])),c.tipo); }
  }else if(tipo.equals("MINA") && int(dato[1])!=miId){
    minas.add(new Mina(float(dato[2]),float(dato[3]),int(dato[1])));
    tanqueDe(int(dato[1])).minaLista=false;
  }else if(tipo.equals("KIT") && int(dato[1])!=miId){
    usarKit(int(dato[1]));
  }else if(tipo.equals("CAJA") && !soyServidor){
    cajas.add(new Caja(int(dato[1]),int(dato[2]),int(dato[3])));
  }else if(tipo.equals("GOLPE") && soyServidor){
    aplicarDaño(int(dato[1]),int(dato[2]));
  }else if(tipo.equals("VIDA") && !soyServidor){
    tanqueDe(SERVIDOR).vida=int(dato[1]); tanqueDe(CLIENTE).vida=int(dato[2]);
    tanqueDe(SERVIDOR).escudo=boolean(dato[3]); tanqueDe(CLIENTE).escudo=boolean(dato[4]);
  }else if(tipo.equals("FIN")){
    ganador=int(dato[1]); puntosVerde=int(dato[2]); puntosAzul=int(dato[3]);
    numeroRonda=int(dato[4]); partidaTerminada=boolean(dato[5]);
    rondaTerminada=true; mostrarGanadorHasta=millis()+2000;
  }else if(tipo.equals("NUEVA")){
    numeroMapa=int(dato[1]); numeroRonda=int(dato[2]);
    puntosVerde=int(dato[3]); puntosAzul=int(dato[4]);
    prepararMapa(); rondaTerminada=false; partidaTerminada=false;
  }
}

// Mover al rival. El primer mensaje del otro jugador cierra la sala de espera.
void recibirPosicion(String[] dato){
  float x=float(dato[2]), y=float(dato[3]);
  rival.oruga=(rival.oruga+dist(rival.pos.x,rival.pos.y,x,y)*0.5)%5;
  rival.pos.set(x,y);
  rival.dx=float(dato[4]); rival.dy=float(dato[5]);
  if(esperandoSala){
    esperandoSala=false;
    prepararMapa();
    mostrarRonda();
  }
}

// Enviar una línea de información al otro jugador.
void enviarRed(String linea){
  if(soyServidor && servidor!=null) servidor.write(linea+"\n");
  else if(cliente!=null && cliente.active()) cliente.write(linea+"\n");
}

// En red, mandar la posición propia unas 20 veces por segundo.
void enviarPosicion(){
  if(modoOffline || millis()-yo.ultimoEnvio<50) return;
  enviarRed("POS,"+miId+","+yo.pos.x+","+yo.pos.y+","+yo.dx+","+yo.dy);
  yo.ultimoEnvio=millis();
}

// El servidor le manda al cliente la vida y los escudos de los dos tanques.
void enviarVida(){
  Tanque verde=tanqueDe(SERVIDOR), azul=tanqueDe(CLIENTE);
  enviarRed("VIDA,"+verde.vida+","+azul.vida+","+verde.escudo+","+azul.escudo);
}

// Decidir en el servidor quién ganó la ronda y avisarle al cliente.
void terminarRonda(int jugadorMuerto){
  if(rondaTerminada) return;
  cerrarRonda(otroJugador(jugadorMuerto));
  servidor.write("FIN,"+ganador+","+puntosVerde+","+puntosAzul+","+numeroRonda+","+partidaTerminada+"\n");
}
