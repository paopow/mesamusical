static final int MAX_TIMES_TO_DRAW= 300;
static final int MAX_TIMES_TO_DRAW_HIT = 30;
static final int MAX_TIMES_HIT_BEFORE_JUMP = 3;
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
  
  boolean checkCollisionWithShooter() {
    if(shooter!=null) {
       if((this.getX()> shooter.getX()-obj_size*1.1)
           &&(this.getX()< shooter.getX()+obj_size*1.1)
           &&(this.getY()> shooter.getY()-obj_size*1.1)
           &&(this.getY()< shooter.getY()+obj_size*1.1)){
             playRibbit();
             if(shooter.getX() < this.getX()) 
               x += obj_size * 1.1;
             else
               x -= obj_size * 1.1;
             if(shooter.getY() < this.getY())
               y += obj_size * 1.1;
             else
               y -= obj_size * 1.1;
             return true;
           }
    }
    if(shooter2!=null) {
         if((this.getX()> shooter2.getX()-obj_size*1.1)
           &&(this.getX()< shooter2.getX()+obj_size*1.1)
           &&(this.getY()> shooter2.getY()-obj_size*1.1)
           &&(this.getY()< shooter2.getY()+obj_size*1.1)){
             playRibbit();
             if(shooter2.getX() < this.getX()) 
               x += obj_size * 1.1;
             else
               x -= obj_size * 1.1;
             if(shooter2.getY() < this.getY())
               y += obj_size * 1.1;
             else
               y -= obj_size * 1.1;
             return true;
           }
    }
    return false;
  }
  void display() {
   checkCollisionWithShooter();
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
  
  void hit(float bubbleX, float bubbleY) {
      this.hit = true;
      this.numTimesHit++;
      numTimesDrawnSinceHit = 0;
      numTimesDrawn = 0;
      println(bubbleX + ":" + bubbleY+ ":" + getX() + ":" + getY());
      if(bubbleX < this.getX()) 
        this.x += 10;
      else
        this.x -= 10;
      if(bubbleY < this.getY())
        this.y += 10;
      else
         this.y -= 10;
      if(jumpingOff) {
        jumpingOff = false;
        this.x = currX;
        this.y = currY;
      }
      if(numTimesHit > MAX_TIMES_HIT_BEFORE_JUMP) {
        jumpingOff = true;
      }
      
  }
 
  
}
