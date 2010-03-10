// we need to import the TUIO library
// and declare a TuioProcessing client variable
import arb.soundcipher.*;
import TUIO.*;
TuioProcessing tuioClient;

static final int SHOOTER_ID = 35;
static final int BUBBLE_DIAM = 16;
static final int NUM_NOTES = 36; //3 octaves include sharp and flat
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
PImage bg;

Shooter shooter = null;
ArrayList bubbles;

ArrayList rippleList;
float obj_size;
final int MAX_RADIUS = 250;
final int RIPPLE_GROWTH_RATE = 2;
final int ONE_OVER_RIPPLE_FREQUENCY = 10; 
int count; 

void setup()
{
  bg = loadImage("grass.jpg");
  //size(screen.width,screen.height);
  size(screen.width, screen.height);
 //println(screen.width + "," + screen.height);
  noStroke();
  //fill(0);
  
  loop();
  frameRate(30);
  //noLoop();
  
  hint(ENABLE_NATIVE_FONTS);
  font = createFont("Arial", 18);
  scale_factor = height/table_size;
  
  //init sound
  init_sc_array();
  
  bubbles = new ArrayList();

  tuioClient  = new TuioProcessing(this);
  rippleList = new ArrayList();
  count = 0;
}

void draw()
{

  //background(bg);
  background(136, 194, 13);
  drawCircle();
  textFont(font,18*scale_factor);
  obj_size = object_size*scale_factor; 
  float cur_size = cursor_size*scale_factor; 
  
  shooterMach();   

  
  drawReactTags();
  drawRipples();
  drawBubbles();

}

void shooterMach()
{
    if(shooter != null){
       shooter.display();
      if(frameCount%shooter.tempo_ctrl == 0){
         shooter.shootBubble();
      }
    }
}

void drawCircle()
{
   float radius= 0.9*min(screen.width/2,screen.height/2);
   stroke(70, 173, 237);
   fill(70, 173, 237);
   ellipseMode(CENTER);

   ellipse(screen.width/2, screen.height/2,2*radius,2*radius); 
   
} 

void drawReactTags(){
  Vector tuioObjectList = tuioClient.getTuioObjects();
  for (int i=0;i<tuioObjectList.size();i++) {
     TuioObject tobj = (TuioObject)tuioObjectList.elementAt(i);
     if(tobj.getSymbolID()!=SHOOTER_ID){ 
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
   }
}

void drawRipples(){  
   for (int i = rippleList.size() - 1; i >= 0; i--) {
     Ripple temp = (Ripple) rippleList.get(i);
     
     stroke(0);
     pushMatrix();
     translate(temp.x, temp.y);
     noFill();
     ellipse(-temp.radius/2, -temp.radius/2, temp.radius, temp.radius);
     
     if (temp.update()) {
       rippleList.remove(i);
       //println("Removed ripple");
     } else {
       //println("Kept ripple. Radius:" + temp.radius);
     }
     
     popMatrix();  
   }  
}

void drawBubbles(){
  for (int i = 0; i < bubbles.size(); i++) {
    Bubble bubble = (Bubble) bubbles.get(i);
    bubble.update();
    bubble.display(); 
    if(bubble.isOffScreen()){
      bubbles.remove(i);
      i--;
    }
  }
}

/**********************************
  Reactivision callbacks
 *********************************/

void addTuioObject(TuioObject tobj) {
  if(tobj.getSymbolID() == SHOOTER_ID){
    shooter = new Shooter(tobj);
     //add shooter 
  }else{
    //add a stone 
    ripple(tobj);
  }
}

void removeTuioObject(TuioObject tobj) {
  if(tobj.getSymbolID() == SHOOTER_ID){
   shooter = null; 
  }else{
   ripple(tobj); 
  }
  //println("remove object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+")");
}

void updateTuioObject (TuioObject tobj) {
  if(tobj.getSymbolID() == SHOOTER_ID){
    shooter.move(tobj.getX(),tobj.getY());
    shooter.set_angle(tobj.getAngle());
  }else{
     if (count++ % ONE_OVER_RIPPLE_FREQUENCY == 0) ripple(tobj);
  }
  //println("update object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle()
    //      +" "+tobj.getMotionSpeed()+" "+tobj.getRotationSpeed()+" "+tobj.getMotionAccel()+" "+tobj.getRotationAccel());
}

void addTuioCursor(TuioCursor tcur) {
  //println("add cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY());
}

void updateTuioCursor (TuioCursor tcur) {
  //println("update cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY()
        //  +" "+tcur.getMotionSpeed()+" "+tcur.getMotionAccel());
}

void removeTuioCursor(TuioCursor tcur) {
  //println("remove cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+")");
}

// called after each message bundle
// representing the end of an image frame
void refresh(TuioTime bundleTime) { 
  redraw();
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


//id%NUM_NOTES = 0 -> low C. id%NUM_NOTES = 35 -> high C
float getNote(int id)
{
  id = id%NUM_NOTES; //48 is low C, 60 is mid C, 72 is high C 
  return id + 48; 
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


