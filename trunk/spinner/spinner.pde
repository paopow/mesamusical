import TUIO.*;
import ddf.minim.*;
import ddf.minim.signals.*;

static final String A_SHARP = "../data/piano_A_sharp.mp3";
static final String G_SHARP = "../data/piano_G_sharp.mp3";
static final String F_SHARP = "../data/piano_F_sharp.mp3";
static final String F = "../data/piano_F.mp3";
static final String D_SHARP = "../data/piano_D_sharp.mp3";
static final String D = "../data/piano_D.mp3";
static final String A = "../data/piano_A.mp3";
static final String B = "../data/piano_B.mp3";
static final String C_SHARP = "../data/piano_C_sharp.mp3";
static final String C = "../data/piano_Cshort.mp3";
static final String E = "../data/piano_Eshort.mp3";
static final String G = "../data/piano_Gshort.mp3";

static final int TAG_DIMENSION = 10; //TODO: Need to calibrate this
static final int NUM_PLAYABLE_NOTES = 7;
static final int NUM_BLOCKS = 12;

TuioProcessing tuioClient;
Minim minim;
AudioOutput out;
HashMap tags = new HashMap(50);
float cursor_angle; //in rad
float d_angle = 0.06;
float radius;
boolean crossRadar = false;
HashMap notesPlaying = new HashMap(50);
AudioPlayer[] notePlayers; 

void setup()
{
  frameRate(100);
  size(screen.width, screen.height); //full screen 
  background(#000000); 
  minim = new Minim(this);
  out = minim.getLineOut(Minim.MONO, 512);
  tuioClient = new TuioProcessing(this);
  //tags[0] = null;
  cursor_angle = 0;
  init_notePlayers();

  
}

void draw()
{
   //update sound
   Iterator i = tags.entrySet().iterator();
   crossRadar = false;
   
  // println("Number of notes currently playing: " + notesPlaying.size());
   while(i.hasNext()){
      Map.Entry curr =  (Map.Entry)i.next();
      TuioObject curr_tag = (TuioObject)curr.getValue();
      String key = nf(curr_tag.getSymbolID(),2);
      int curr_note = curr_tag.getSymbolID()%NUM_PLAYABLE_NOTES; 
      if(isCrossRadar(curr_tag)) {
        crossRadar = true;
        String file;  
        if(!notePlayers[curr_note].isPlaying())
          //notePlayers[curr_note].rewind();
        //else
          notePlayers[curr_note].play();
        
      }
      else {
        crossRadar = false;
        if(!notePlayers[curr_note].isPlaying())
          notePlayers[curr_note].rewind();
        if(notesPlaying.containsKey(key)) {
          AudioPlayer player = (AudioPlayer)notesPlaying.get(key);
          println("Remove note " + key  + " in notesPlaying");
          
        }
      }
   }
   //update graphics
   drawCircle();
   drawRadar();
   markTags(); //for debugging
   //println(tags.size());
   
   //move the cursor
   cursor_angle = (cursor_angle + d_angle)%(2*PI);

}

void init_notePlayers()
{
    notePlayers = new AudioPlayer[NUM_BLOCKS];
  String file;
    for(int i = 0; i < NUM_BLOCKS; i++){
      switch(i % NUM_PLAYABLE_NOTES){
          case 0: file = G; break;
          case 1: file = A; break;
          case 2: file = B; break;
          case 3: file = C; break;
          case 4: file = D; break;
          case 5: file = E; break;
          case 6: file = F; break;
          default: file = C; break;
        }
    notePlayers[i] = minim.loadFile(file,2048);
    }
}

void drawCircle()
{
   radius= 0.9*min(screen.width/2,screen.height/2);
   stroke(136, 194, 13);
   fill(136, 194, 13);
   ellipseMode(CENTER);

   ellipse(screen.width/2, screen.height/2,2*radius,2*radius); 
   //stroke(0);
   //fill(0);
   //ellipse(screen.width/2, screen.height/2,0.2*radius,0.2*radius);
   
} 

void drawRadar()
{
  ellipseMode(CENTER);
  if(crossRadar) {
    stroke(255, 113, 113);
    fill(255, 113, 113);
    strokeWeight(10);
  } else {
    stroke(70, 173, 237);
    fill(70, 173, 237);
    strokeWeight(10);
  }
  //noFill();
  arc(screen.width/2, screen.height/2, radius*2, radius*2,(cursor_angle-0.2)%(2*PI), cursor_angle%(2*PI));
  //line(screen.width/2,screen.height/2,radius*cos(cursor_angle) + screen.width/2,radius*sin(cursor_angle)+screen.height/2);
}

boolean isCrossRadar(TuioObject tobj)
{
  //center of circle is 0,0
  //flip x and y since we invert projector
  float circle_x = 2 * (tobj.getY() - 0.50);
  float circle_y = -2 * (tobj.getX() - 0.50);
  //println("x: " + unit_x + ", y: " + unit_y);
  double tag_angle = (Math.atan2(circle_x,circle_y) + (3 * PI/2)) % (2 * PI);
  //println("Curr angle: " + tag_angle + ", cursor_angle: " + cursor_angle);
  if(abs((float)tag_angle - cursor_angle) < 0.2 ) return true;
  else return false;

}

void markTags()
{
   Iterator i = tags.entrySet().iterator();
   stroke(70, 173, 237);
   fill(136, 194, 13);
   ellipseMode(CENTER);
   synchronized(tags){
   while(i.hasNext()){
      Map.Entry curr =  (Map.Entry)i.next();
      TuioObject curr_tag = (TuioObject)curr.getValue();
      if(isCrossRadar(curr_tag)) {
          stroke(255, 113, 113);
          fill(136, 194, 13);
       }
      //flip x and y
   float x = curr_tag.getY() * screen.width;
        float y = screen.height - (curr_tag.getX() * screen.height);
        println(curr_tag + ":" + "(" + x + "," + y + ")");
      //  float x = 2 * (curr_tag.getX() - 0.50) * screen.width;
        //float y = -2 * (curr_tag.getY() - 0.50) * screen.height;
        //float new_x = 2 *
        //float new_y = y;
       //float new_x = -(x - 2 * (x - (3/10 * (y - 550))));
        //float new_y = y - 2 * (y - (10 * x/3 + 550));
        //println("Old x: " + x + ", new x: " + new_x + "; Old y: " + y + ", new y: " + new_y);
        pushMatrix();
         //rotate(-PI/30);
        //translate(-10,-110);
            
         rect(x, y ,120, 120);
        popMatrix();
   }
   }
}

// called when an object is added to the scene
void addTuioObject(TuioObject tobj){
  synchronized(tags){
  String key= nf(tobj.getSymbolID(),2);
  tags.put(key,tobj);
  //int symbol = tobj.getSymbolID();
  //println("add object" + symbol);
  }
}

// called when an object is removed from the scene
void removeTuioObject(TuioObject tobj) {
  synchronized(tags){
  String key=nf(tobj.getSymbolID(),2);
  tags.remove(key);
 // println("remove object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+")");
  }
}

// called when an object is moved
void updateTuioObject (TuioObject tobj) {
 // println("update object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle()
 //        +" "+tobj.getMotionSpeed()+" "+tobj.getRotationSpeed()+" "+tobj.getMotionAccel()+" "+tobj.getRotationAccel());
}

// called after each message bundle
// representing the end of an image frame
void refresh(TuioTime bundleTime) { 
  redraw();
}

