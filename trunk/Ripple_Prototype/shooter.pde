/*****************************
  class Shooter
 *******************************/
class Shooter{
  float x;
  float y;
  int tempo_ctrl; //PAOTODO:how to control this => make spinning a single action? Tap-tap?
  float angle;
  
  Shooter(TuioObject clear_block){
     x = clear_block.getX()*width;
     y = clear_block.getY()*height;
     angle = clear_block.getAngle();  
     tempo_ctrl = 20;
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
    bubbles.add(new Bubble(x + object_size*cos(angle)/2,y + object_size*sin(angle)/2,angle));
  }
  
}


void drawTurtle(float x, float y, float angle){
  stroke(120);  
  fill(120); 
  //PAOTODO change the color of the code later
  //PAOTODO: Draw the legs + animation for the turtle!
  ellipseMode(CENTER);
  pushMatrix();
    translate(x,y);
    rotate(angle);
    ellipse(object_size*sqrt(2)/2, 0, object_size*sqrt(2)/3, object_size*sqrt(2)/3);
    ellipse(0,0,object_size*sqrt(2), object_size*sqrt(2));
  popMatrix();  
}
