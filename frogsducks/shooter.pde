/*****************************
  class Shooter
 *******************************/
class Shooter{
  float x;
  float y;
  int tempo_ctrl; //PAOTODO:how to control this => make spinning a single action? Tap-tap?
  float angle;
  int duck_no;
  PImage duckImage;
  
  Shooter(TuioObject clear_block, int duck_id ){
     x = clear_block.getX()*WIDTH;
     y = clear_block.getY()*HEIGHT;
     angle = clear_block.getAngle();  
     tempo_ctrl = 15;
     duck_no = duck_id;
     duckImage = loadImage("duck.gif");
  } 
  
  void move(float new_x, float new_y){
    x = new_x*WIDTH;
    y = new_y*HEIGHT;
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
    bubbles.add(new Bubble(x + (4*object_size/2)*cos(angle)/2,y + (4*object_size/2)*sin(angle)/2,angle));
  }
  
}

void drawDuck(float x, float y, float angle, int duck_id) {
    pushMatrix();
    translate(x,y);
    rotate(angle);
    int frame = frameCount%10;
    if((frame >= 0)&&(frame <= 4)){
      image(duck1, 0, 0, object_size*3 , object_size*3);
    }else{
      image(duck2,0,0,object_size*3 , object_size*3);
    }
    popMatrix();
}

/*XXX keep for reference
void drawTurtle(float x, float y, float angle, int turtle_id){
  if(turtle_id == 1){
    stroke(66,87,166);  
    fill(66,87,166); 
  }else if(turtle_id ==2){
    stroke(157,57,166);
    fill(157,57,166);
  }
  float d = 1.5*object_size*sqrt(2);
  //PAOTODO change the color of the code later
  //PAOTODO: Draw the legs + animation for the turtle!
  ellipseMode(CENTER);
  pushMatrix();
    translate(x,y);fuio
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
}*/
