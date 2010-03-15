/*****************************
  class Shooter
 *******************************/
public static final int MAX_REMOVE_TIME = 100;
 
class Shooter{
  float x;
  float y;
  int tempo_ctrl; //PAOTODO:how to control this => make spinning a single action? Tap-tap?
  float angle;
  int duck_no;
  PImage duckImage;
  boolean blockRemoved;
  int removeTimer;
  
  Shooter(TuioObject clear_block, int duck_id ){
     x = clear_block.getX()*WIDTH - 100;
     y = clear_block.getY()*HEIGHT - 100;
     angle = clear_block.getAngle();  
     tempo_ctrl = 15;
     duck_no = duck_id;
     duckImage = loadImage("duck.gif");
     removeTimer = 0;
     blockRemoved = false;
  } 
  
  float getX() {
    return this.x;
  }
  
  float getY() {
    return this.y;
  }
  
  void remove() {
    blockRemoved = true;
  }
  
  void resetRemove() {
    blockRemoved = false;
  }
  
  void move(float new_x, float new_y){
    x = new_x*WIDTH - 100;
    y = new_y*HEIGHT - 100;
  }
  
  void set_angle(float tag_angle){
     angle = tag_angle;
  }
  
  void display(){
    //draw the shooter => what should it be?
    //drawTurtle(x,y,angle,turtle_no);
    drawDuck(x, y, angle, duck_no);
  }
  
  void shootBubble(){
    bubbles.add(new Bubble(x+ (4*object_size/2)*cos(angle)/2,y+ (4*object_size/2)*sin(angle)/2,angle));
  }
  


  boolean isReallyRemoved() {
    if(blockRemoved && removeTimer > MAX_REMOVE_TIME) {
      return true;
    }
    else return false;
  }

void drawDuck(float x, float y, float angle, int duck_id) {
    pushMatrix();
    translate(x,y);
    rotate(angle);
    int frame = frameCount%10;
    if(blockRemoved) {
      removeTimer++;
    }
    else {
      removeTimer = 0;
    }
    if((frame >= 0)&&(frame <= 4)){
      image(duck1, 0, 0, object_size*3 , object_size*3);
    }else{
      image(duck2, 0, 0, object_size*3 , object_size*3);
    }
    popMatrix();
}

}
