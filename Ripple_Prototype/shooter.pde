/*****************************
  class Shooter
 *******************************/
class Shooter{
  float x;
  float y;
  int tempo_ctrl; //PAOTODO:how to control this => make spinning a single action? Tap-tap?
  float angle;
  
  Shooter(TuioObject clear_block){
     x = clear_block.getX()*WIDTH;
     y = clear_block.getY()*HEIGHT;
     angle = clear_block.getAngle();  
     tempo_ctrl = 15;
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
    bubbles.add(new Bubble(x + (4*object_size/3)*cos(angle)/2,y + (4*object_size/3)*sin(angle)/2,angle));
  }
  
}


void drawTurtle(float x, float y, float angle){
  stroke(120);  
  fill(120); 
  float d = object_size*sqrt(2);
  //PAOTODO change the color of the code later
  //PAOTODO: Draw the legs + animation for the turtle!
  ellipseMode(CENTER);
  pushMatrix();
    translate(x,y);
    rotate(angle);
    ellipse(d/2, 0, d/3, d/3); //head
    ellipse(0,0,d,d); //body
    
    //legs
    pushMatrix();
      rotate(-PI/2);
      arc(0.15*d,0.10*d,d,0.6*d,0, PI);
    popMatrix();
    pushMatrix();
      rotate(-PI/2);
      arc(-0.15*d,0.1*d,d,0.6*d,0,PI);
    popMatrix();
    pushMatrix();
      rotate(-PI/3);
      arc(-0.15*d,-0.25*d,d,0.6*d,0,PI);
    popMatrix();
    pushMatrix();
      rotate(-2*PI/3);
      arc(0.15*d,-0.25*d,d,0.6*d,0,PI);
    popMatrix();
    //arc(d/4,-d/4,,,0, PI);
    //arc(-d/4,d/4,,,0, PI);
    //arc(-d/4,-d/4,,,0, PI);
  popMatrix();  
}
