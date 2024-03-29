// we need to import the TUIO library
// and declare a TuioProcessing client variable
import arb.soundcipher.*;
import TUIO.*;
TuioProcessing tuioClient;
import ddf.minim.*;
import ddf.minim.signals.*;

static final String DUCK_MP3_FILE = "duck.mp3";
static final String FROG_MP3_FILE = "frog.mp3";
static final int SHOOTER_ID = 34;
static final int SHOOTER_ID2 = 33;
static final int NUM_NOTES = 36; //3 octaves include sharp and flat
static final int NUM_SC = 4;
static final int WIDTH = 1200;
static final int HEIGHT = 800;
static final int NUM_FROGS = 36;
SoundCipher[] sc_array = new SoundCipher[NUM_SC]; 
SCScore score = new SCScore(); //may not need this
static int curr_sc = 0;
HashMap idToNote;
// these are some helper variables which are used
// to create scalable graphical feedback
float cursor_size = 15;
float object_size = 60;
float table_size = 760;
float scale_factor = 1;
PFont font;
PImage bg;
PImage lily;
PImage frog;
PImage frogglow;
PImage duck;
PImage duck1;
PImage duck2;
PImage bubbleImages[];

Minim minim;
AudioOutput out;
AudioPlayer duckPlayer;
AudioPlayer frogPlayer;

Shooter shooter = null;
Shooter shooter2 = null;
ArrayList bubbles;

ArrayList rippleList;
float obj_size;

int count; 
Frog[] frogList = new Frog[NUM_FROGS];


void setup()
{
  //size(screen.width,screen.height);
  size(WIDTH, HEIGHT);//, screen.height);
 //println(WIDTH + "," + HEIGHT);
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
  initFrogList();
  loadImages();
  minim = new Minim(this);
  out = minim.getLineOut(Minim.MONO, 512);
  duckPlayer = minim.loadFile(DUCK_MP3_FILE,2048);
  frogPlayer = minim.loadFile(FROG_MP3_FILE,2048);
}

void loadImages() {
  bubbleImages = new PImage[3];
  imageMode(CENTER);
  //rock = loadImage("stone1.gif");
  lily = loadImage("lilypad.png");
  bg = loadImage("grass.png");
  frog = loadImage("frog.png");
  frogglow = loadImage("frogglow.png");
  duck = loadImage("duck.gif");
  duck1 = loadImage("duck1.gif");
  duck2 = loadImage("duck2.gif");
  bubbleImages[0] = loadImage("bubble1.png");
  bubbleImages[1] = loadImage("bubble2.png");
  bubbleImages[2] = loadImage("bubble3.png");
}


//This will init an array of rock objects, indexed by their id numbers, rockList.
void initFrogList() {
  
  for(int i = 0; i < NUM_FROGS; i++) {
    Frog temp = new Frog(i,0.0,0.0, 0.0);
    frogList[i] = temp;
  }
  idToNote = new HashMap();
  for(int i=0; i< NUM_FROGS; i++) {
    String note = "";
    switch(i%12) {
      case 0:
        note = "C"; break;
      case 1:
        note = "C#"; break;
      case 2:
        note = "D"; break;
      case 3:
        note = "E b"; break;
      case 4:
        note = "E"; break;
      case 5:
        note = "F"; break;
      case 6:
        note = "F #"; break; 
      case 7:
        note = "G"; break;
      case 8:
        note = "A b"; break;
      case 9:
        note = "A"; break; 
      case 10:
        note = "B b"; break;
      case 11:
        note = "B"; break;
      default:
        note = "C"; break;
    }
    idToNote.put(i, note);
  }
}

void draw()
{
  imageMode(CENTER);
  background(94, 167, 30);
  image(bg, WIDTH/2, HEIGHT/2, WIDTH, HEIGHT);
  //drawCircle();
  textFont(font,18*scale_factor);
  obj_size = object_size*scale_factor; 
  float cur_size = cursor_size*scale_factor; 
    drawFrogs();
   shooterMach();  
  //drawRipples();
 

  drawBubbles();

}

void shooterMach()
{
    if(shooter != null && shooter.isReallyRemoved()) shooter = null;
    if(shooter2 !=null && shooter2.isReallyRemoved()) shooter2= null;
    if(shooter != null){
       shooter.display(); //can make it null?
      if(shooter != null) {
      if(frameCount%shooter.tempo_ctrl == 0){
         shooter.shootBubble();
      }
      }
    }
    if(shooter2 != null){
       shooter2.display();
      if(shooter2 != null) {
        if(frameCount%shooter2.tempo_ctrl == 0){
           shooter2.shootBubble();
        }
      }
    }
}


void drawFrogs(){
  for(int i=0; i<NUM_FROGS; i++) {
    if(frogList[i].isOnScreen()) {
      frogList[i].display();
    }
  }
}

//inefficient to loop through, but TUIOClient can only retrieve by SessID
TuioObject getTObjForSymbolID(int symbolID) {
  Vector tuioObjectList = tuioClient.getTuioObjects();
  for (int i=0;i<tuioObjectList.size();i++) {
    TuioObject tobj = (TuioObject)tuioObjectList.elementAt(i);
    if(tobj.getSymbolID() == symbolID)
      return tobj;
  }
  return null;
}

void drawBubbles(){
  for (int i = 0; i < bubbles.size(); i++) {
    Bubble bubble = (Bubble) bubbles.get(i);
    bubble.update();
    bubble.display(); 
    if(bubble.checkHitDuck()) {
      println("removing");
      bubbles.remove(i);
      i--;
    }
    int id = bubble.hitFrogID();
    if(id != -1){
      int[] tag_id = new int[1];
      tag_id[0] = id;
      playNote(tag_id);
      frogList[id].hit(bubble.getX(), bubble.getY());
      bubbles.remove(i);
      i--;
    }else if(bubble.isOffScreen()){
      bubbles.remove(i);
      i--;
    }
  }
}

void playQuack() {
  if(!duckPlayer.isPlaying()) {
    duckPlayer.play();
    duckPlayer.rewind();
  }
}

void playRibbit() {
  if(!frogPlayer.isPlaying()) {
    frogPlayer.play();
    frogPlayer.rewind();
  }
}

/**********************************
  Reactivision callbacks
 *********************************/

void addTuioObject(TuioObject tobj) {
  int id = tobj.getSymbolID() % NUM_NOTES;
  switch(id) {
    case SHOOTER_ID:
    if(shooter !=null) shooter.resetRemove();
    else
      shooter = new Shooter(tobj, 1); 
    break;
    case SHOOTER_ID2:
    if(shooter2 !=null) shooter2.resetRemove();
    else
      shooter2 = new Shooter(tobj, 2); 
     break;
    default: 
      frogList[id] = new Frog(id, tobj.getScreenX(WIDTH), tobj.getScreenY(HEIGHT), tobj.getAngle());
      frogList[id].setOnScreen(true);
      frogList[id].display();
      int[] thisInt = new int[2];
      thisInt[0] = id % NUM_NOTES; //xxx I THINK THIS WAS CAUSING CRASHES BEFORE... MOD IT to make sure
      playNote(thisInt);
  }
}

void removeTuioObject(TuioObject tobj) {
   if(tobj.getSymbolID() == SHOOTER_ID2){
     if(shooter != null) {
       shooter2.remove();
     }
  }
  if(tobj.getSymbolID() == SHOOTER_ID){
    if(shooter != null) {
      shooter.remove();
    }
  }//else{
  // ripple(tobj); 
  //}
  //println("remove object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+")");
}

void updateTuioObject (TuioObject tobj) {
  if(tobj.getSymbolID() == SHOOTER_ID && shooter != null){
    shooter.move(tobj.getX(),tobj.getY());
    shooter.set_angle(tobj.getAngle());
    println(tobj.getAngle());
  }else if(tobj.getSymbolID() == SHOOTER_ID2 && shooter2 != null){
    shooter2.move(tobj.getX(),tobj.getY());
    shooter2.set_angle(tobj.getAngle());
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
  return id + 60; 
}
/*
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
*/

