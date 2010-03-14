class rock {
  int counter = 0;
  int[] noteArray;
  
  rock(int[] notes) {
    noteArray = notes;
  }
  
  int getNote() {
    return noteArray[counter++ % 3];
  }
}
