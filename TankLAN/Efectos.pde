// Particula: efecto breve cuando una bala golpea una pared.
class Particula{
  PVector pos=new PVector(), vel=PVector.random2D();
  int vida=15;

  // Crear una partícula con dirección aleatoria.
  Particula(float x,float y){ pos.set(x,y); vel.mult(2); }
  // Mover la partícula y reducir su duración.
  void actualizar(){ pos.add(vel); vida--; }
  // Dibujar la partícula como un cuadrado pequeño.
  void dibujar(){ noStroke(); fill(255,150,50); rect(pos.x,pos.y,4,4); }
}
