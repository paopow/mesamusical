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
     println("angle " + angle);
  } 
  
  void move(float new_x, float new_y){
    x = new_x*width;
    y = new_y*height;
  }
  
  void set_angle(float tag_angle){
     angle = tag_angle;
     shootBubble();
  }
  
  void display(){
    //draw the shooter => what should it be?
    drawTurtle(x,y,angle);
  }
  
  void shootBubble(){
      println("Bubble " + angle);
      bubbles.add(new Bubble(x,y,angle));
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
    ellipse(object_size/2, 0, object_size/3, object_size/3);
    ellipse(0,0,object_size, object_size);
  popMatrix();  
}
