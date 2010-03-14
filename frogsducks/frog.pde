static final int MAX_TIMES_TO_DRAW= 200;

/****************************************
 class Frog
 **************************************/
class Frog {
  int id;
  float x;
  float y;
  float angle;
  boolean onScreen;
  int numTimesDrawn = 0;
  
  Frog(int id, float x, float y, float angle) {
    this.id = id;
    this.x = x;
    this.y = y;
    this.angle = angle;
    this.onScreen = false;
    this.numTimesDrawn = 0;
  }
  
  void moveTo(float x, float y, float angle) {
    this.x = x;
    this.y = y;
    this.angle = angle;
  }
  
  void display() {
    stroke(167, 148, 30);
    fill(167, 57, 30);
    pushMatrix();
    translate(x, y);
    rotate(angle);
    image(lily, -obj_size*1.1,-obj_size*1.1,obj_size*2.2,obj_size*2.2);
    image(frog, -obj_size*1.1,-obj_size*1.1,obj_size*2.2,obj_size*2.2);
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
  
 
  
}
