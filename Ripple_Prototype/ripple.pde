
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
