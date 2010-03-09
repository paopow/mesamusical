// we need to import the TUIO library
// and declare a TuioProcessing client variable
import arb.soundcipher.*;
import TUIO.*;
TuioProcessing tuioClient;

static final int SHOOTER_ID = 0;
static final int NUM_NOTES = 7;
static final int NUM_SC = 4;

SoundCipher[] sc_array = new SoundCipher[NUM_SC]; 
SCScore score = new SCScore(); //may not need this
static int curr_sc = 0;

// these are some helper variables which are used
// to create scalable graphical feedback
float cursor_size = 15;
float object_size = 60;
float table_size = 760;
float scale_factor = 1;
PFont font;

ArrayList bubbles;

ArrayList rippleList;
float obj_size;
final int MAX_RADIUS = 250;
final int RIPPLE_GROWTH_RATE = 2;
final int ONE_OVER_RIPPLE_FREQUENCY = 10; //HERE
int count; //HERE

void setup()
{
  //size(screen.width,screen.height);
  size(640,480);
  noStroke();
  fill(0);
  
  loop();
  frameRate(30);
  //noLoop();
  
  hint(ENABLE_NATIVE_FONTS);
  font = createFont("Arial", 18);
  scale_factor = height/table_size;
  
  //init sound
  init_sc_array();
  
  bubbles = new ArrayList();
  // we create an instance of the TuioProcessing client
  // since we add "this" class as an argument the TuioProcessing class expects
  // an implementation of the TUIO callback methods (see below)
  tuioClient  = new TuioProcessing(this);
  rippleList = new ArrayList();
  count = 0;
}

// within the draw method we retrieve a Vector (List) of TuioObject and TuioCursor (polling)
// from the TuioProcessing client and then loop over both lists to draw the graphical feedback.
void draw()
{
  background(255);
  textFont(font,18*scale_factor);
  obj_size = object_size*scale_factor; 
  float cur_size = cursor_size*scale_factor; 
   
  Vector tuioObjectList = tuioClient.getTuioObjects();
  for (int i=0;i<tuioObjectList.size();i++) {
     TuioObject tobj = (TuioObject)tuioObjectList.elementAt(i);
     stroke(0);
     fill(0);
     pushMatrix();
     translate(tobj.getScreenX(width),tobj.getScreenY(height));
     rotate(tobj.getAngle());
     rect(-obj_size/2,-obj_size/2,obj_size,obj_size);
     popMatrix();
     fill(255);
     text(""+tobj.getSymbolID(), tobj.getScreenX(width), tobj.getScreenY(height));
   }
   
//DRAWING THE RIPPLES   
   for (int i = rippleList.size() - 1; i >= 0; i--) {
     Ripple temp = (Ripple) rippleList.get(i);
     
     stroke(0);
     pushMatrix();
     translate(temp.x, temp.y);
     noFill();
     ellipse(-temp.radius/2, -temp.radius/2, temp.radius, temp.radius);
     
     if (temp.update()) {
       rippleList.remove(i);
       println("Removed ripple");
     } else {
       println("Kept ripple. Radius:" + temp.radius);
     }
     
     popMatrix();  
   }
//END DRAW
   
//DRAW BUBBLES
  for (int i = 0; i < bubbles.size(); i++) {
    Bubble bubble = (Bubble) bubbles.get(i);
    bubble.update();
    bubble.checkEdges();
    bubble.display(); 
  }
//END DRAW

   
}

/**********************************
  Reactivision callbacks
 *********************************/

// called when an object is added to the scene
void addTuioObject(TuioObject tobj) {
  println("add object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle());
  ripple(tobj);
}

// called when an object is removed from the scene
void removeTuioObject(TuioObject tobj) {
  println("remove object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+")");
  ripple(tobj);
}

// called when an object is moved
void updateTuioObject (TuioObject tobj) {
  println("update object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle()
          +" "+tobj.getMotionSpeed()+" "+tobj.getRotationSpeed()+" "+tobj.getMotionAccel()+" "+tobj.getRotationAccel());
  if (count++ % ONE_OVER_RIPPLE_FREQUENCY == 0) ripple(tobj);
}

// called when a cursor is added to the scene
void addTuioCursor(TuioCursor tcur) {
  println("add cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY());
}

// called when a cursor is moved
void updateTuioCursor (TuioCursor tcur) {
  println("update cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY()
          +" "+tcur.getMotionSpeed()+" "+tcur.getMotionAccel());
}

// called when a cursor is removed from the scene
void removeTuioCursor(TuioCursor tcur) {
  println("remove cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+")");
}

// called after each message bundle
// representing the end of an image frame
void refresh(TuioTime bundleTime) { 
  redraw();
}

void ripple(TuioObject tobj) {
  stroke(0);
  pushMatrix();
  translate(tobj.getScreenX(width),tobj.getScreenY(height));
  noFill();
  ellipse(-obj_size/2,-obj_size/2,obj_size,obj_size);
  popMatrix();
  ArrayList alreadyIntersected = new ArrayList();
  rippleList.add(new Ripple(obj_size/2, tobj.getScreenX(width) + obj_size/2, tobj.getScreenY(height) + obj_size/2, tobj.getSymbolID(), alreadyIntersected));
  //rippleList.add(new Ripple(6, tobj.getScreenX(width),tobj.getScreenY(height)));
  //rippleList.add(new Ripple(1, tobj.getScreenX(width),tobj.getScreenY(height)));
}

/*************************
 Audio functions
 *************************/

void init_sc_array(){
 for(int i = 0; i < sc_array.length; i++){
   sc_array[i] = new SoundCipher(this);
 } 
}

void playNote(int[] id){
  float[] chord = new float[id.length];
  for(int i = 0; i < chord.length; i++){
   chord[0] = getNote(id[0]); 
  }
  //float note = getNote(id[0]);
  //sc_array[curr_sc].playNote(note, 100, 1.0);
  sc_array[curr_sc].playChord(chord,100,1.0);
  curr_sc = (curr_sc + 1)%NUM_SC;
}

float getNote(int id)
{
  float note;
  id = id%NUM_NOTES;
  switch (id){
    case 0:
      note = 60; // 'C'
      break;
    case 1:
      note = 62; // 'D'
      break;
    case 2:
      note = 64; // 'E'
      break;
    case 3:
      note = 65; // 'F'
      break;
    case 4:
      note = 67; // 'G'
      break;
    case 5:
      note = 69; // 'A'
      break;
    case 6:
      note = 71; // 'B'
      break; 
    default:
      note = 60; // just return middle C
      break;
  }
  return note;
}


/****************************************
 class Bubble
 **************************************/
class Bubble {
  PVector location;
  PVector velocity;
  PVector acceleration;
  float topspeed;
  
  
  Bubble(float x,float y) { //PAOTODO: Change this later -> need velocity
    location = new PVector(x,y);
    //location_original = new PVector(x,y);
    velocity = new PVector(0,0);
    topspeed = 4;
  }

  void update() {

    // Our algorithm for calculating acceleration:
    PVector blackHole = new PVector(screen.width/2, screen.height/2);
    PVector dir = PVector.sub(blackHole,location);  // Find vector pointing towards mouse
    dir.normalize();     // Normalize
    dir.mult(0.5);       // Scale 
    acceleration = dir;  // Set to acceleration

    // Motion 101!  Velocity changes by acceleration.  Location changes by velocity.
    velocity.add(acceleration);
    velocity.limit(topspeed);
    location.add(velocity);
  }

  void display() {
    stroke(119,173,175);
    fill(119,173,175);
    ellipse(location.x,location.y,16,16); 
  }

  void checkEdges() {

    if (location.x > width) {
      location.x = 0;
    } else if (location.x < 0) {
      location.x = width;
    }

    if (location.y > height) {
      location.y = 0;
    }  else if (location.y < 0) {
      location.y = height;
    }
  
  }
  /*
  boolean reachDest(){
    
     if (((location_original.x - screen.width/2)*(location.x - screen.width/2) <= 0)
            &&((location_original.x - screen.width/2)*(location.x - screen.width/2) <= 0)){
              println(curr_channel);
              sc_array[curr_channel].channel = curr_channel;
              sc_array[curr_channel].playNote(pitch,100,1.0);
              curr_channel = (curr_channel+1)%14;
               //score.addNote(startTime, channel, instrument, pitch, dynamic, duration, articulation, pan);
     // score.addNote(1, 11, 0,60, 100, 0.5, 0.8, 64);
//  score.addNote(0, 10, 0, 0, 72, 0.5, 0.8, 64);
              return true;
     }
     return false;
  }*/

}

/****************************
 class Ripple
 ****************************/
class Ripple {
  float radius;
  float x;
  float y;
  int id; //id of the block it came from
  ArrayList intersect; //associated with all of the ripples that overlap with it
  
  Ripple(float rad, float xPos, float yPos, int idTag, ArrayList aIntersect) {
    radius = rad;
    x = xPos;
    y = yPos;
    id = idTag;
    intersect = aIntersect;
  }
  
  boolean update() {
    radius += RIPPLE_GROWTH_RATE;
    x += RIPPLE_GROWTH_RATE/2;
    y += RIPPLE_GROWTH_RATE/2    ;
    for (int i = 0; i < rippleList.size(); i++) {
      Ripple thisRipple = (Ripple) rippleList.get(i);
      float xCoord = abs(x - thisRipple.x);
      float yCoord = abs(y - thisRipple.y);
      PVector v = new PVector(xCoord, yCoord);
      if (this.id != thisRipple.id) {
        if (thisRipple.radius + ((Ripple) rippleList.get(i)).radius > v.mag()) { //AND MAKE SURE THAT THE RIPPLE ISN'T INTERSECTING WITH ITSELF--Janelle
            if (!intersect.contains( ((Ripple) rippleList.get(i)).id )) {
              int[] id = new int[1];
              id[0] = thisRipple.id;
              playNote(id);
              intersect.add(((Ripple) rippleList.get(i)).id); 
            }
        }
      }
    }
    return (radius > MAX_RADIUS);
  }
}
