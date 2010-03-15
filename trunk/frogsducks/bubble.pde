static final int BUBBLE_DIAM = 30;
/****************************************
 class Bubble
 **************************************/
class Bubble {
  PVector location;
  PVector velocity;
  PVector acceleration;
  float topspeed;
  
  
  Bubble(float x,float y,float angle) { //PAOTODO: Change this later -> need velocity
    location = new PVector(x,y);
    velocity = new PVector(5*cos(angle),5*sin(angle));
    acceleration = new PVector(cos(angle),sin(angle));
    acceleration.normalize();
    acceleration.mult(0.5);
    topspeed = 8;
  }

  void update() {
    velocity.add(acceleration);
    velocity.limit(topspeed);
    location.add(velocity);
  }

  void display() {
    PImage toDraw = bubble;
   // stroke(119,173,175);
   // fill(119,173,175);
    //ellipse(location.x,location.y,BUBBLE_DIAM,BUBBLE_DIAM); 
    image(toDraw, location.x,location.y,BUBBLE_DIAM,BUBBLE_DIAM);
  }
  
  boolean isOffScreen(){
     return ((location.x > WIDTH)||(location.x < 0)||(location.y >HEIGHT) ||(location.y<0));
  }
  
  int hitFrogID(){
    for (int i=0;i<NUM_FROGS;i++) {
       Frog f = frogList[i];
       if(f.isOnScreen()) {
         println(location.x + ":" + location.y + ":" + f.getX() + ":" + f.getY());
         if((location.x> f.getX()-2*obj_size)
           &&(location.x< f.getX()+2*obj_size)
           &&(location.y> f.getY()-2*obj_size)
           &&(location.y< f.getY()+2*obj_size)){
             return f.getID();
           }
       }
    }
    return -1;
  }
}

