
/****************************
 class Ripple
 ****************************/
 
final int MAX_RADIUS = 200;
final int RIPPLE_GROWTH_RATE = 2;
final int ONE_OVER_RIPPLE_FREQUENCY = 10; 

class Ripple {
  float radius;
  float x;
  float y;
  int id; //id of the block it came from
  int noteID; //id number of the note to play
  boolean activated;
  int glow_counter;
  
  Ripple(float rad, float xPos, float yPos, int idTag, int note) {
    radius = rad;
    x = xPos;
    y = yPos;
    id = idTag;
    noteID = note;
    activated = true;
    glow_counter = 3;
  }
  
  boolean update() {
    if (this.activated == false){
      if(glow_counter == 0) return true;
      glow_counter--;
      return false;
    }
    radius += RIPPLE_GROWTH_RATE;
    for (int i = 0; i < rippleList.size(); i++) {
      Ripple testRipple = (Ripple) rippleList.get(i);
      
      if (this.id != testRipple.id) {
        float xCoord = abs(this.x - testRipple.x);
        float yCoord = abs(this.y - testRipple.y);
        PVector v = new PVector(xCoord, yCoord);
      
        if (testRipple.radius + this.radius > v.mag()) { 
           int[] thisInt = new int[2];
           thisInt[0] = this.id;
           thisInt[1] = testRipple.id;
           playNote(thisInt);
           testRipple.activated = false;
           this.activated = false;
        }
      }
    }
    return (radius > MAX_RADIUS);
  }
}
