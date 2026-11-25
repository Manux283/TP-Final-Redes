// Particula: chispas, humo y explosiones que se desvanecen solas.
class Particula{
  PVector pos=new PVector(), vel=PVector.random2D();
  color tono;
  int vida, vidaInicial;

  // Crear una partícula con dirección aleatoria.
  Particula(float x,float y,color c,float rapidez){
    pos.set(x,y); vel.mult(random(0.3,1)*rapidez);
    tono=c; vidaInicial=int(random(12,26)); vida=vidaInicial;
  }
  // Mover la partícula, frenarla y reducir su duración.
  void actualizar(){ pos.add(vel); vel.mult(0.93); vida--; }
  // Dibujar un cuadradito que se achica y se vuelve transparente.
  void dibujar(){
    float t=vida/(float)vidaInicial;
    noStroke(); fill(tono,255*t);
    rectMode(CENTER); rect(pos.x,pos.y,2+3*t,2+3*t); rectMode(CORNER);
  }
}

// Crear varias partículas juntas (chispas, explosiones, polvo).
void explotar(float x,float y,int cantidad,color c,float rapidez){
  for(int i=0;i<cantidad;i++) particulas.add(new Particula(x,y,c,rapidez));
}
