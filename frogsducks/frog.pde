static final int MAX_TIMES_TO_DRAW= 10000;
static final int MAX_TIMES_TO_DRAW_HIT = 30;
/****************************************
 class Frog
 **************************************/
class Frog {
  int id;
  float x;
  float y;
  float angle;
  boolean onScreen;
  boolean hit;
  int numTimesHit; //so we can make it leave the screen after its been hit x times
  int numTimesDrawnSinceHit; //draw glowing for a few times
  int numTimesDrawn; //leaves screen after a while
  
  Frog(int id, float x, float y, float angle) {
    this.id = id;
    this.x = x;
    this.y = y;
    this.angle = angle;
    this.onScreen = false;
    this.hit = false;
    this.numTimesDrawn = 0;
    this.numTimesHit = 0;
    this.numTimesDrawnSinceHit = 0;
  }
  
  float getX() {
    return this.x;
  }
  
  float getY() {
    return this.y;
  }
  
  int getID() {
    return this.id;
  }
  
  void moveTo(float x, float y, float angle) {
    this.x = x;
    this.y = y;
    this.angle = angle;
  }
  
  void display() {
    PImage toDraw = frog;
   if(this.hit) {
      if(this.numTimesDrawnSinceHit < MAX_TIMES_TO_DRAW_HIT) {
        this.numTimesDrawnSinceHit++;
        toDraw = frogglow;
      }
      else {
        this.hit = false;
        toDraw = frog;
      }
    }
    stroke(167, 148, 30);
    fill(167, 57, 30);
    pushMatrix();
    translate(x, y);
    rotate(angle);
    image(lily, -obj_size*1.1,-obj_size*1.1,obj_size*2.2,obj_size*2.2);
    image(toDraw, -obj_size*1.1,-obj_size*1.1,obj_size*2.2,obj_size*2.2);
    popMatrix();
    text(""+id, x, y);
    numTimesDrawn++;
    if(numTimesDrawn > MAX_TIMES_TO_DRAW) {
      this.remove();
    }
  }
  
  void remove() {
     text("Bye!", x, y);
     this.setOnScreen(false);
  }
  
  void setOnScreen(boolean onScreen) {
    this.onScreen = onScreen;
    numTimesDrawn = 0; //do we want to reset here?
  }
  
  boolean isOnScreen() {
    return onScreen;
  }
  
  void hit() {
    this.hit = true;
    numTimesDrawnSinceHit = 0;
  }
 
  
}
