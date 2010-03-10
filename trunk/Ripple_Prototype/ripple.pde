
/****************************
 class Ripple
 ****************************/
class Ripple {
  float radius;
  float x;
  float y;
  int id; //id of the block it came from
  int noteID; //id number of the note to play
  boolean activated;
  
  Ripple(float rad, float xPos, float yPos, int idTag, int note) {
    radius = rad;
    x = xPos;
    y = yPos;
    id = idTag;
    noteID = note;
    activated = true;
  }
  
  boolean update() {
    if (this.activated == false) return true;
    radius += RIPPLE_GROWTH_RATE;
    //x += RIPPLE_GROWTH_RATE/2;
    //y += RIPPLE_GROWTH_RATE/2;
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
           return true; 
        }
      }
    }
    return (radius > MAX_RADIUS);
  }
}
