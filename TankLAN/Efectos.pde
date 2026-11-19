// Particula: efecto breve cuando una bala golpea una pared.
class Particula{
  PVector pos=new PVector(), vel=PVector.random2D();
  int vida=15;

  // Creo una partícula con dirección aleatoria.
  Particula(float x,float y){ pos.set(x,y); vel.mult(2); }
  // Muevo la partícula y reduzco su duración.
  void actualizar(){ pos.add(vel); vida--; }
  // Dibujo la partícula como un cuadrado pequeño.
  void dibujar(){ noStroke(); fill(255,150,50); rect(pos.x,pos.y,4,4); }
}
