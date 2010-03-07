import TUIO.*;
import jmetude.*;

static final int NUM_INSTRUMENTS = 5;

TuioProcessing tuioClient;
Etude e;

// these are some helper variables which are used
// to create scalable graphical feedback
float cursor_size = 15;
float object_size = 60;
float table_size = 760;
float scale_factor = 0.5;

float screen_width;
float screen_height;

float notes1[][] = {{0,  e.Q},
                   {0, e.Q},
                   {0,  e.SQ}, 
                   {0, e.SQ}, 
                   {0,  e.SQ}, 
                   {e.FS4, e.SQ},{e.E4,  e.SQ}, 
                   {e.CS5, e.SQ}, 
                   {e.B4,  e.SQ}, 
                   {e.FS4, e.SQ}, 
                   {e.D5,  e.SQ}, 
                   {e.CS5, e.SQ}};
  
PFont font;
void setup(){
  frameRate(100);
  screen_width = screen.width/2;
  screen_height = screen.height/2;
  size((int)screen_width,(int) screen_height); //for debugging
  
  e = new Etude(this);
  e.createScore("score");
  
  
  tuioClient = new TuioProcessing(this);
  
}

void draw(){
  background(0);
  //drawMainCircle();
  drawWaves();
  markTags();
}

void drawMainCircle(){
  ellipseMode(CENTER);
  stroke(255);
  noFill();
  float diam = min(screen_width/12,screen_height/12);
  for(int i = 1; i <= 12; i++){
    ellipse(screen_width/2, screen_height/2, i*diam,i*diam);
  }
  
}

void markTags()
{
  float obj_size = object_size*scale_factor; 
  float cur_size = cursor_size*scale_factor; 
  Vector tuioObjectList = tuioClient.getTuioObjects();
  for(int i = 0; i < tuioObjectList.size();i++){
     TuioObject tobj = (TuioObject)tuioObjectList.elementAt(i); 
     stroke(255);
     fill(255);
     pushMatrix();
     translate(tobj.getScreenX(width),tobj.getScreenY(height));
     rotate(tobj.getAngle());
     rect(-obj_size/2,-obj_size/2,obj_size,obj_size);
     popMatrix();
     fill(0);
  }
}

void drawWaves(){
  float obj_size = object_size*scale_factor;
  float cur_size = cursor_size*scale_factor;
  Vector tuioObjectList = tuioClient.getTuioObjects();
  for(int i = 0; i < tuioObjectList.size(); i++){
     TuioObject tobj = (TuioObject)tuioObjectList.elementAt(i);  
  }
}
// called when an object is added to the scene
void addTuioObject(TuioObject tobj){
  //String key= nf(tobj.getSymbolID(),2);
  //tags.put(key,tobj);
  int symbol = tobj.getSymbolID()%NUM_INSTRUMENTS;
  //e.createScore(nf(tobj.getSymbolID(),2));
  e.createPart(nf(tobj.getSymbolID(),2));
  e.setPartChannel(nf(tobj.getSymbolID(),2),tobj.getSymbolID()%NUM_INSTRUMENTS);
  e.addScorePart("score",nf(tobj.getSymbolID(),2));
  //if(tobj.getSymbolID()%2 == 0){
  e.createPhrase(nf(tobj.getSymbolID(),2),notes1);
  e.repeatPhrase(nf(tobj.getSymbolID(),2), 200);
  //}else{
    // e.createPhrase("phrase1",notes2);
  //}
  
  e.addPartPhrase(nf(tobj.getSymbolID(),2),nf(tobj.getSymbolID(),2));
  e.stopMIDI();
  int inst = (int)random(0,127);
  e.setPartInstrument(nf(tobj.getSymbolID(),2),inst);
  e.playMIDI("score");
  //println("add object" + symbol);
  
}

// called when an object is removed from the scene
void removeTuioObject(TuioObject tobj){
  
}

//called when an object is moved
void updateTuioObject(TuioObject tobj){
  // println("update object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle()
 //        +" "+tobj.getMotionSpeed()+" "+tobj.getRotationSpeed()+" "+tobj.getMotionAccel()+" "+tobj.getRotationAccel());
  e.stopMIDI();
  e.setTempo("score", tobj.getAngle()*2);
  e.playMIDI("score");
  

}

// called after each message bundle representing the end of an image frame
void refresh(TuioTime bundleTime){
   redraw(); 
} 
