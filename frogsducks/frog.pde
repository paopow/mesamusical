static final int MAX_TIMES_TO_DRAW= 300;
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
  boolean jumpingOff;
  float jumpX, jumpY;
  float currX, currY;
  
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
    this.jumpingOff = false;
  }
  
  float getX() {
    if(jumpingOff) return this.currX;
    else return this.x;
  }
  
  float getY() {
    if(jumpingOff) return this.currY;
    else return this.y;
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
   currX = this.x + jumpX;
   currY = this.y + jumpY;

   if(currX < 0 || currY < 0) {
     this.remove();
   }
   else {
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
    stroke(229, 0, 0);
    fill(229, 0, 0);
    pushMatrix();
    imageMode(CENTER);
    translate(x, y);
    rotate(angle);
    image(lily, 0, 0, obj_size*2.2,obj_size*2.2);
    if(this.jumpingOff) {
      jumpX -= 5;
      jumpY -= 5;
      translate(jumpX, jumpY);
      text("Bye!", -obj_size, -obj_size);
    }
    image(toDraw, 0, 0, obj_size*2.2,obj_size*2.2);
    textAlign(CENTER);
    textFont(font,24*scale_factor);
    text("" +idToNote.get(id), 0, 0);
    popMatrix();

    numTimesDrawn++;
    if(!this.jumpingOff) {
      if(numTimesDrawn > MAX_TIMES_TO_DRAW) {
       this.jumpingOff = true;
       this.jumpX = 0;
       this.jumpY = 0;
    }
    }
   }
  }
  
  void remove() {
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
      numTimesDrawn = 0;
      if(jumpingOff) {
        jumpingOff = false;
        this.x = currX;
        this.y = currY;
      }
  }
 
  
}
