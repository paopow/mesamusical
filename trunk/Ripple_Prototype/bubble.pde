
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

    // Our algorithm for calculating acceleration:
    PVector blackHole = new PVector(WIDTH/2, HEIGHT/2);
   // PVector dir = PVector.sub(blackHole,location);  // Find vector pointing towards mouse
    //dir.normalize();     // Normalize
    //dir.mult(0.5);       // Scale 
    //acceleration = dir;  // Set to acceleration

    // Motion 101!  Velocity changes by acceleration.  Location changes by velocity.
    velocity.add(acceleration);
    velocity.limit(topspeed);
    location.add(velocity);
  }

  void display() {
    stroke(119,173,175);
    fill(119,173,175);
    ellipse(location.x,location.y,BUBBLE_DIAM,BUBBLE_DIAM); 
  }
  
  boolean isOffScreen(){
     return ((location.x > WIDTH)||(location.x < 0)||(location.y >HEIGHT) ||(location.y<0));
  }
  
  int hitRockID(){
    Vector tuioObjectList = tuioClient.getTuioObjects();
    for (int i=0;i<tuioObjectList.size();i++) {
       TuioObject tobj = (TuioObject)tuioObjectList.elementAt(i);
       if(tobj.getSymbolID() != SHOOTER_ID){
         println(location.x + ":" + location.y + ":" + tobj.getX() + ":" + tobj.getY());
         println(1.1*obj_size);
         if((location.x> tobj.getX()*width-1.1*obj_size)
           &&(location.x< tobj.getX()*width+1.1*obj_size)
           &&(location.y> tobj.getY()*height-1.1*obj_size)
           &&(location.y< tobj.getY()*height+1.1*obj_size)){
             return tobj.getSymbolID();
           }
       }
    }
    return -1;
  }
}

