// we need to import the TUIO library
// and declare a TuioProcessing client variable
import arb.soundcipher.*;
import TUIO.*;
TuioProcessing tuioClient;

static final int SHOOTER_ID = 35;
static final int SHOOTER_ID2 = 34;
static final int BUBBLE_DIAM = 16;
static final int NUM_NOTES = 36; //3 octaves include sharp and flat
static final int NUM_SC = 4;
static final int WIDTH = 1200;
static final int HEIGHT = 800;

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
PImage rock;

Shooter shooter = null;
Shooter shooter2 = null;
ArrayList bubbles;

ArrayList rippleList;
float obj_size;

int count; 
rock[] rockList = new rock[36];


void setup()
{
  rock = loadImage("stone1.gif");
  bg = loadImage("grass.jpg");
  //size(screen.width,screen.height);
  size(WIDTH, HEIGHT);//, screen.height);
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
  initRockList();
}

//This will init an array of rock objects, indexed by their id numbers, rockList.
void initRockList() {
  
  int index = 0;
 int[] noteList = {12, 16, 19,
                    14, 18, 21,
                    16, 20, 23,
                    17, 21, 24,
                    19, 23, 26,
                    21, 25, 28,
                    23, 27, 30,
                    24, 28, 31,
                    16, 19, 24,
                    14, 19, 23,
                    14, 19, 20,
                    12, 17, 21,
                    17, 19, 23,
                    14, 16, 17,
                    12, 24, 36,
                    12, 12, 19,
                    16, 20, 16,
                    24, 19, 24,
                    16, 35, 20,
                    16, 23, 32,
                    14, 15, 16,
                    21, 22, 23,
                    23, 20, 23,
                    14, 15, 29,
                    17, 22, 24,
                    21, 24, 26,
                    21, 22, 36,
                    23, 14, 19,
                    21, 30, 26,
                    16, 31, 36,
                    24, 21, 12,
                    19, 36, 16,
                    17, 22, 20,
                    19, 16, 12,
                    14, 17, 21,
                    12, 15, 19};
  
  for(int i = 0; i < 36; i++) {
    int[] tempArr = new int[3];
    for (int j = 0; j < 3; j++) {
      tempArr[j] = noteList[index++];
    }
    rock temp = new rock(tempArr);
    rockList[i] = temp;
  }
  
  /*
  int[] tempArr = new int[3];
  tempArr[0] = 1; tempArr[1] = 2; tempArr[2] = 3;
  rock temp = new rock(tempArr);
  rockList[0] = temp;
  */
}

void draw()
{

  //background(bg);
  background(94, 167, 30);
  drawCircle();
  textFont(font,18*scale_factor);
  obj_size = object_size*scale_factor; 
  float cur_size = cursor_size*scale_factor; 
  
  shooterMach();   

  drawRipples();
  drawReactTags();
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
    if(shooter2 != null){
       shooter2.display();
      if(frameCount%shooter2.tempo_ctrl == 0){
         shooter2.shootBubble();
      }
    }
}

void drawCircle()
{
   float radius= 0.9*min(WIDTH/2,HEIGHT/2);
   stroke(30, 167, 148);
   fill(30, 167, 148);
   ellipseMode(CENTER);

   ellipse(WIDTH/2, HEIGHT/2,2*radius,2*radius); 
   
} 

void drawReactTags(){
  Vector tuioObjectList = tuioClient.getTuioObjects();
  for (int i=0;i<tuioObjectList.size();i++) {
     TuioObject tobj = (TuioObject)tuioObjectList.elementAt(i);
     if((tobj.getSymbolID()!=SHOOTER_ID)&&(tobj.getSymbolID()!=SHOOTER_ID2)){ 
       stroke(167, 148, 30);
       fill(167, 148, 30);
       pushMatrix();
       translate(tobj.getScreenX(WIDTH), tobj.getScreenY(HEIGHT));
       rotate(tobj.getAngle());
       image(rock, -obj_size*1.1,-obj_size*1.1,obj_size*2.2,obj_size*2.2);
       popMatrix();
       fill(167, 57, 30);
       text(""+tobj.getSymbolID(), tobj.getScreenX(WIDTH), tobj.getScreenY(HEIGHT));
     }
   }
}

void drawRipples(){  
  strokeWeight(2);
   for (int i = rippleList.size() - 1; i >= 0; i--) {
     Ripple temp = (Ripple) rippleList.get(i);
     if(temp.activated == true){
       stroke(30, 94, 167);
       noFill();
       ellipseMode(CENTER);
       ellipse(temp.x,temp.y, 2*temp.radius, 2*temp.radius);
     }else{
       stroke(166, 59, 59);
       noFill();
       ellipseMode(CENTER);
       ellipse(temp.x,temp.y, 2*temp.radius, 2*temp.radius);
     }
     if (temp.update()) {
       rippleList.remove(i);
       
       //println("Removed ripple");
     } else {
       //println("Kept ripple. Radius:" + temp.radius);
     } 
   }  
   strokeWeight(1);
}

void drawBubbles(){
  for (int i = 0; i < bubbles.size(); i++) {
    Bubble bubble = (Bubble) bubbles.get(i);
    bubble.update();
    bubble.display(); 
    int id = bubble.hitRockID();
    if(id != -1){
      int[] tag_id = new int[1];
      tag_id[0] = id;
      playNote(tag_id);
      //DAVIDTODO: updatedisplay here
      bubbles.remove(i);
      i--;
    }else if(bubble.isOffScreen()){
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
    shooter = new Shooter(tobj,1);
     //add shooter 
  }else if(tobj.getSymbolID() == SHOOTER_ID2){
      shooter2 = new Shooter(tobj,2);
  }else{
    //add a stone 
    ripple(tobj);
    
    //play the note when added
    int[] thisInt = new int[2];
    thisInt[0] = tobj.getSymbolID();
    playNote(thisInt);
  }
}

void removeTuioObject(TuioObject tobj) {
   if(tobj.getSymbolID() == SHOOTER_ID2){
   shooter2 = null; 
  }
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
  }else if(tobj.getSymbolID() == SHOOTER_ID2){
    shooter2.move(tobj.getX(),tobj.getY());
    shooter2.set_angle(tobj.getAngle());
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
  sc_array[curr_sc].channel = curr_sc;
  sc_array[curr_sc].playChord(chord,100,2.0);
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
  translate(tobj.getScreenX(WIDTH),tobj.getScreenY(HEIGHT));
  noFill();
  ellipse(-obj_size/2,-obj_size/2,obj_size,obj_size);
  popMatrix();
  Ripple new_ripple = new Ripple(1.1*obj_size, tobj.getX()*width, tobj.getY()*height, tobj.getSymbolID(), rockList[tobj.getSymbolID()].getNote());
  rippleList.add(new_ripple);

}


