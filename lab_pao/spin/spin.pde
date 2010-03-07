import arb.soundcipher.*;
import TUIO.*;

TuioProcessing tuioClient;
SoundCipher[] sc_array = new SoundCipher[14]; 
SoundCipher sc = new SoundCipher(this);
SCScore score = new SCScore();
float[] pitches = {0, 4, 7, 9};
static int curr_channel = 0;
float object_size = 60;
float table_size = 760;
float scale_factor = 1;
PFont font;

static float main_radius;
ArrayList bubbles;
Vector tuioObjectList;

void setup()
{
 // noLoop(); 
  //set graphic variable
  size(screen.width, screen.height);
  background(0);
  font = createFont("Arial", 18);
  textFont(font,18*scale_factor);
  main_radius = min(screen.width/2, screen.height/2);
  drawMainCircle();
  bubbles = new ArrayList();
  
  initBgMusic();
  for(int i = 0; i < sc_array.length; i++){
   sc_array[i] = new SoundCipher(this); 
  }

  tuioClient = new TuioProcessing(this);
  tuioObjectList = tuioClient.getTuioObjects();
  
}

void draw()
{
  frameRate(100);
  noStroke();
  fill(0,50);
  rect(0,0,screen.width,screen.height);
   // Calling functions of all of the objects in the array.
  for (int i = 0; i < bubbles.size(); i++) {
    Bubble bubble = (Bubble) bubbles.get(i);
    bubble.update();
    bubble.checkEdges();
    bubble.display(); 
    if(bubble.reachDest()){
      bubbles.remove(i);
      i--; 
    }
  }
  
  float obj_size = object_size*scale_factor; 
  Vector tuioObjectList = tuioClient.getTuioObjects();
  for (int i=0;i<tuioObjectList.size();i++) {
     TuioObject tobj = (TuioObject)tuioObjectList.elementAt(i);
     stroke(255);
     fill(0);
     pushMatrix();
     translate(tobj.getScreenX(width),tobj.getScreenY(height));
     rotate(tobj.getAngle());
     rect(-obj_size/2,-obj_size/2,obj_size,obj_size);
     popMatrix();
     fill(255);
     text(""+tobj.getSymbolID(), tobj.getScreenX(width), tobj.getScreenY(height));
   }
}

void initBgMusic()
{
  score.addCallbackListener(this);  
  score.tempo(120);
  for(int i=0; i<2; i++) {
    score.addCallback(i / (int)(random(2) + 1), 3);
  }
 
  // kick drum
  //score.addNote(startTime, channel, instrument, pitch, dynamic, duration, articulation, pan);
  score.addNote(0, 15, 0, 36, 100, 0.5, 0.8, 64);
  score.addNote(3.5, 15, 0, 36, 100, 0.5, 0.8, 64);
  
  // bass
  float[] bassPitches = new float[4];
  float[] bassDynamics = new float[4];
  float[] bassDurations = new float[4];
  float[] bassArticulations = new float[4];
  float[] bassPans = new float[4];
  for (int i=0; i<4; i++) {
    if (i<1) {
      bassDurations[i] = 1;  
      bassPitches[i] = 36;  
    } else {
      bassDurations[i] = random(1) * 0.5 + 0.5;
      bassPitches[i] = 36 + pitches[(int)(random(pitches.length))];
    }
    bassDynamics[i] = random(30) + 50;
    bassArticulations[i] = 0.8;
    bassPans[i] = 64;
  }
  score.addPhrase(0, 14, 34, bassPitches, bassDynamics, bassDurations, bassArticulations, bassPans);
  score.play(-1);  
}


void drawMainCircle()
{
   ellipseMode(CENTER);
   stroke(255);
   fill(0);
   ellipse(screen.width/2, screen.height/2, 2*main_radius-100,2*main_radius-100); 
}

void addNewBubbles()
{
   tuioObjectList = tuioClient.getTuioObjects();
  for(int i = 0; i < tuioObjectList.size();i++){
    TuioObject tobj = (TuioObject)tuioObjectList.elementAt(i);
    bubbles.add(new Bubble(tobj.getX()*screen.width,tobj.getY()*screen.height,tobj.getSymbolID(),tobj.getAngle(),tobj.getRotationSpeed())); 
  }
}

public void handleCallbacks(int callbackID) {
  if(callbackID == 3) {
   // y = random(100);
    redraw();
    addNewBubbles();
  }
}

// these callback methods are called whenever a TUIO event occurs

// called when an object is added to the scene
void addTuioObject(TuioObject tobj) {
 // bubbles.add(new Bubble(tobj.getX()*screen.width,tobj.getY()*screen.height));
  println("add object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle());
}

// called when an object is removed from the scene
void removeTuioObject(TuioObject tobj) {
  println("remove object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+")");
}

// called when an object is moved
void updateTuioObject (TuioObject tobj) {
  int id = tobj.getSymbolID();
  //if(tobj.getRotationSpeed() == 0){
     // find tobj
     // update the size
  //}
  //bubbles.add(new Bubble(tobj.getX()*screen.width,tobj.getY()*screen.height,tobj.getSymbolID()));
  println("update object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle()
          +" "+tobj.getMotionSpeed()+" "+tobj.getRotationSpeed()+" "+tobj.getMotionAccel()+" "+tobj.getRotationAccel());
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


/*************************************
 class: Tag
 *************************************/
class Tag{
  
  
  
}
 
/****************************************
  class Bubble
 **************************************/
class Bubble {

  PVector location_original;
  PVector location;
  PVector velocity;
  PVector acceleration;
  float topspeed;
  float pitch;
  float instrument;
  
  Bubble(float x,float y,float id, float angle, float rotation_speed) { //PAOTODO: Change this later
    location = new PVector(x,y);
    location_original = new PVector(x,y);
    velocity = new PVector(0,0);
    topspeed = 4;
    pitch = id + 60;
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
    stroke(0);
    fill(175);
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
  
  boolean reachDest(){
    
     if (((location_original.x - screen.width/2)*(location.x - screen.width/2) <= 0)
            &&((location_original.x - screen.width/2)*(location.x - screen.width/2) <= 0)){
              println(curr_channel);
              sc_array[curr_channel].channel = curr_channel;
              sc_array[curr_channel].playNote(pitch,100,1.0);
              //sc_array[0].playNote(pitch,100,1.0);
              curr_channel = (curr_channel+1)%14;
             // sc.channel = curr_channel;
             // 
              //println(curr_channel);
              //sc.playNote(pitch, 100, 1.0);
               //score.addNote(startTime, channel, instrument, pitch, dynamic, duration, articulation, pan);
     // score.addNote(1, 11, 0,60, 100, 0.5, 0.8, 64);
//  score.addNote(0, 10, 0, 0, 72, 0.5, 0.8, 64);
              return true;
     }
     return false;
  }

}

