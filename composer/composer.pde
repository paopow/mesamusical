  import TUIO.*;
  import jmetude.*;
  
  static final int TAG_DIMENSION = 10; //TODO: Need to calibrate this
  static final int NUM_PLAYABLE_NOTES = 7;
  static final int NUM_BLOCKS = 12;
  
  TuioProcessing tuioClient;
  HashMap tags = new HashMap(50);
  float cursor_angle; //in rad
  float d_angle = 0.06;
  float radius;
  boolean crossRadar = false;
  HashMap tagsToNotes = new HashMap(50);
  boolean isPlaying;
  
  Etude e;
  float quarter_c[][] = {{60.0, 0.5f}};
  float quarter_a[][] = {{69.0, 0.5f}};
  
  void setup()
  {
    isPlaying = false;
    frameRate(100);
    size(screen.width, screen.height); //full screen 
    background(#000000); 
    e = new Etude(this);
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
          //e.stopMIDI();
          if(!isPlaying) {
            //e.playMIDI("quarter_c");        
            isPlaying = true;
          }
        }
        else {
          isPlaying = false;
          //e.stopMIDI();
          crossRadar = false;
          
            
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
     e.createScore("main_score");
     e.createPhrase("quarter_c");
     e.addPhraseNoteList("quarter_c", quarter_c);
  }
  
  void drawCircle()
  {
     radius= 0.9*min(screen.width/2,screen.height/2);
     stroke(136, 194, 13);
     fill(136, 194, 13);
     ellipseMode(CENTER);
  
     ellipse(screen.width/2, screen.height/2,2*radius,2*radius); 
       stroke(70, 173, 237);
      fill(70, 173, 237);
      
     //rect(screen.width/2, screen.height/2,0.2*radius,0.2*radius);
     //rect(300,0,100,100);
     stroke(70, 173, 237);
     strokeWeight(5);
     //println(screen.height);
     //println(screen.width/2);
   //  line (screen.width/2 - 90, 0, screen.width/2 + 150, screen.height);
   //println(screen.width/2 - 90 + ", " + 0);
   //println(screen.width/2 + 150 + ", " + screen.height);
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
    float circle_x = 2 * (tobj.getX() - 0.50);
    float circle_y = -2 * (tobj.getY() - 0.50);
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
    // ellipseMode(CENTER);
     synchronized(tags){
     while(i.hasNext()){
        Map.Entry curr =  (Map.Entry)i.next();
        TuioObject curr_tag = (TuioObject)curr.getValue();
        //flip x and y
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
        //SineWave test= playNote(curr_tag.getSymbolID(),0.5);
       // println("tags mark: " + curr_tag.getX() + " " + curr_tag.getY());
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
