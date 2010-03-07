import TUIO.*;
import jmetude.*;

//constants for instruments
static final int NUM_INSTRUMENTS = 5;

TuioProcessing tuioClient;
Etude e;

float notes[][] = {{e.E4,  e.SQ},
                   {e.FS4, e.SQ},
                   {e.B4,  e.SQ}, 
                   {e.CS5, e.SQ}, 
                   {e.D5,  e.SQ}, 
                   {e.FS4, e.SQ}, 
                   {e.E4,  e.SQ}, 
                   {e.CS5, e.SQ}, 
                   {e.B4,  e.SQ}, 
                   {e.FS4, e.SQ}, 
                   {e.D5,  e.SQ}, 
                   {e.CS5, e.SQ}};


void setup(){
  frameRate(100);
  //size(screen.width, screen.height); 
  size(screen.width/2, screen.height/2); //for debugging
  e = new Etude(this);
  e.createScore("main_score");
  e.createPart("piano");
  e.createPart("flute");
  e.createPart("church_organ");
  e.createPart("drum");
  e.createPart("clean_guitar");
  
  e.addScorePart("main_score", "piano");
  e.addScorePart("main_score", "flute");
  e.addScorePart("main_score", "church_organ");
  e.addScorePart("main_score", "drum");
  e.addScorePart("main_score", "clean_guitar");
  
  e.setPartInstrument("piano", e.PIANO);
  e.setPartInstrument("flute", e.FLUTE);
  e.setPartInstrument("church_organ", e.CHURCH_ORGAN);
  e.setPartInstrument("drum", e.DRUM);
  e.setPartInstrument("clean_guitar", e.CLEAN_GUITAR);
  
  e.setPartChannel("piano",0);
  e.setPartChannel("flute",1);
  e.setPartChannel("church_organ",2);
  e.setPartChannel("drum",3);
  e.setPartChannel("clean_guitar",4);
  
 
  
}

void draw(){
  background(0);
}

// called when an object is added to the scene
void addTuioObject(TuioObject tobj){
  //String key= nf(tobj.getSymbolID(),2);
  //tags.put(key,tobj);
  int symbol = tobj.getSymbolID()%NUM_INSTRUMENTS;
  
  //println("add object" + symbol);
  
}

// called when an object is removed from the scene
void removeTuioObject(TuioObject tobj){
  
}

//called when an object is moved
void updateTuioObject(TuioObject tobj){
  // println("update object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle()
 //        +" "+tobj.getMotionSpeed()+" "+tobj.getRotationSpeed()+" "+tobj.getMotionAccel()+" "+tobj.getRotationAccel());
}

// called after each message bundle representing the end of an image frame
void refresh(TuioTime bundleTime){
   redraw(); 
}
