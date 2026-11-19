// Particula: efecto breve cuando una bala golpea una pared.
class Particula{
  PVector pos=new PVector(), vel=PVector.random2D();
  int vida=15;

  Particula(float x,float y){ pos.set(x,y); vel.mult(2); }
  void actualizar(){ pos.add(vel); vida--; }
  void dibujar(){ noStroke(); fill(255,150,50); rect(pos.x,pos.y,4,4); }
}
