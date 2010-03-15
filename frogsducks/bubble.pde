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

  float getX() {
    return location.x;
  }
  
  float getY() {
    return location.y;
  }

  void update() {
    velocity.add(acceleration);
    velocity.limit(topspeed);
    location.add(velocity);
  }

  void display() {
    int rand = int(random(0, 3));
    PImage toDraw = bubbleImages[rand];
   // stroke(119,173,175);
   // fill(119,173,175);
    //ellipse(location.x,location.y,BUBBLE_DIAM,BUBBLE_DIAM); 
    pushMatrix();

    imageMode(CENTER);
    image(toDraw, location.x,location.y,BUBBLE_DIAM,BUBBLE_DIAM);
    popMatrix();
  }
  
  boolean isOffScreen(){
     return ((location.x > WIDTH)||(location.x < 0)||(location.y >HEIGHT) ||(location.y<0));
  }
  
  boolean checkHitDuck() {
 
    if(shooter!=null) {
       if((location.x> shooter.getX()-BUBBLE_DIAM)
           &&(location.x< shooter.getX()+BUBBLE_DIAM)
           &&(location.y> shooter.getY()-BUBBLE_DIAM)
           &&(location.y< shooter.getY()+BUBBLE_DIAM)){
             playQuack();
             return true;
           }
    }
    if(shooter2!=null) {
         if((location.x> shooter2.getX()-BUBBLE_DIAM)
           &&(location.x< shooter2.getX()+BUBBLE_DIAM)
           &&(location.y> shooter2.getY()-BUBBLE_DIAM)
           &&(location.y< shooter2.getY()+BUBBLE_DIAM)){
             playQuack();
             return true;
           }
    }
    return false;
  }
  
  int hitFrogID(){
    for (int i=0;i<NUM_FROGS;i++) {
       Frog f = frogList[i];
       if(f.isOnScreen()) {
        
         if((location.x> f.getX()-BUBBLE_DIAM*2)
           &&(location.x< f.getX()+BUBBLE_DIAM*2)
           &&(location.y> f.getY()-BUBBLE_DIAM*2)
           &&(location.y< f.getY()+BUBBLE_DIAM*2)){
             return f.getID();
           }
       }
    }
    return -1;
  }
}

