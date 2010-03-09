/*****************************
  class Shooter
 *******************************/
class Shooter{
  float x;
  float y;
  double tempo; //PAOTODO:how to control this => make spinning a single action? Tap-tap?
  float angle;
  
  Shooter(TuioObject clear_block){
     x = clear_block.getX()*width;
     y = clear_block.getY()*height;
     angle = clear_block.getAngle();
  } 
  
  void move(float new_x, float new_y){
    x = new_x*width;
    y = new_y*height;
  }
  
  void set_angle(float tag_angle){
     angle = tag_angle;
  }
  
  void display(){
    //draw the shooter => what should it be?
    drawTurtle(x,y,angle);
  }
  
  void shootBubble(){
      bubbles.add(new Bubble(x,y,angle));
  }
  
}
