// we need to import the TUIO library
// and declare a TuioProcessing client variable
import arb.soundcipher.*;
import TUIO.*;
TuioProcessing tuioClient;

static final int NUM_NOTES = 7;
static final int NUM_SC = 4;
SoundCipher[] sc_array = new SoundCipher[NUM_SC]; 
static int curr_sc = 0;

// these are some helper variables which are used
// to create scalable graphical feedback
float cursor_size = 15;
float object_size = 120;
float table_size = 760;
float scale_factor = 1;
PFont font;

ArrayList rippleList;
float obj_size;
final int MAX_RADIUS = 250;
final int RIPPLE_GROWTH_RATE = 2;
final int ONE_OVER_RIPPLE_FREQUENCY = 10; //HERE
int count; //HERE

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

void drawCircle()
{
   background(0);
   float radius= 0.9*min(screen.width/2,screen.height/2);
   stroke(70, 173, 237);
   fill(70, 173, 237);
   ellipseMode(CENTER);

   ellipse(screen.width/2, screen.height/2,2*radius,2*radius); 
     //  stroke(70, 173, 237);
    //fill(70, 173, 237);
   //ellipse(screen.width/2, screen.height/2,0.05*radius,0.05*radius);
   
} 

void setup()
{
  size(screen.width,screen.height);
  drawCircle();

  loop();
  frameRate(30);
  //noLoop();
  
  hint(ENABLE_NATIVE_FONTS);
  font = createFont("Arial", 18);
  scale_factor = height/table_size;
  
  //init sound
  init_sc_array();
  
  // we create an instance of the TuioProcessing client
  // since we add "this" class as an argument the TuioProcessing class expects
  // an implementation of the TUIO callback methods (see below)
  tuioClient  = new TuioProcessing(this);
  rippleList = new ArrayList();
  count = 0;
}


float getTransformedX(TuioObject tobj) {
  float x = tobj.getY() * screen.width;
  if(x < 650) x = x + ((650-x)/4);
  else x = x - ((x-650)/2);
  x = x +50;
  return x;
}

float getTransformedY(TuioObject tobj) {
  float y = screen.height - (tobj.getX() * screen.height);
  if(getTransformedX(tobj) > 500 && y < 450) y = y - 100;
  return y;
}

// within the draw method we retrieve a Vector (List) of TuioObject and TuioCursor (polling)
// from the TuioProcessing client and then loop over both lists to draw the graphical feedback.
void draw()
{
  drawCircle();
  textFont(font,18*scale_factor);
  obj_size = object_size*scale_factor; 
  float cur_size = cursor_size*scale_factor; 
   
  Vector tuioObjectList = tuioClient.getTuioObjects();
  for (int i=0;i<tuioObjectList.size();i++) {
     TuioObject tobj = (TuioObject)tuioObjectList.elementAt(i);
     stroke(136, 194, 13);
     fill(136, 194, 13);
     pushMatrix();
     translate(getTransformedX(tobj),getTransformedY(tobj));
     rotate(tobj.getAngle());
     rect(-obj_size/2,-obj_size/2,obj_size,obj_size);
     popMatrix();
     //fill(255);
     //text(""+tobj.getSymbolID(), tobj.getScreenX(width), tobj.getScreenY(height));
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
   
   Vector tuioCursorList = tuioClient.getTuioCursors();
   for (int i=0;i<tuioCursorList.size();i++) {
      TuioCursor tcur = (TuioCursor)tuioCursorList.elementAt(i);
      Vector pointList = tcur.getPath();
      
      if (pointList.size()>0) {
        stroke(0,0,255);
        TuioPoint start_point = (TuioPoint)pointList.firstElement();;
        for (int j=0;j<pointList.size();j++) {
           TuioPoint end_point = (TuioPoint)pointList.elementAt(j);
           line(start_point.getScreenX(width),start_point.getScreenY(height),end_point.getScreenX(width),end_point.getScreenY(height));
           start_point = end_point;
        }
        
        stroke(192,192,192);
        fill(192,192,192);
        ellipse( tcur.getScreenX(width), tcur.getScreenY(height),cur_size,cur_size);
        fill(0);
        text(""+ tcur.getCursorID(),  tcur.getScreenX(width)-5,  tcur.getScreenY(height)+5);
      }
   }
   
}

// these callback methods are called whenever a TUIO event occurs

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
  rippleList.add(new Ripple(obj_size/2, tobj.getScreenX(width) + obj_size/2,tobj.getScreenY(height) + obj_size/2, tobj.getSymbolID(), alreadyIntersected));
  //rippleList.add(new Ripple(6, tobj.getScreenX(width),tobj.getScreenY(height)));
  //rippleList.add(new Ripple(1, tobj.getScreenX(width),tobj.getScreenY(height)));
}

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


