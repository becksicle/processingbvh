import peasy.*; //<>//

//QueasyCam cam;
PeasyCam cam;

// bvh file being played
BvhData bvhData;

// frame index in current bvhData.motion
int curFrame = 0;

// controls pause/playback of animation
boolean paused = false;

// the array of bvh files to loop through
String[] bvhFiles;

// next file to play
int nextFile = 0;

// true if first time playing first frame of a new animation
boolean justStarted;

// to label the joints or not
boolean drawLabels = false;

/* 
  Reads content of a file into one big String.
  This is to simplify the Tokenizer; but may change
  to pass a BufferedReader to Tokenizer instead.
*/
String readFile(String filename) {
  StringBuilder sb = new StringBuilder();
  for (String line : loadStrings(filename)) {
    sb.append(line);
    sb.append("\n");
  }
  return sb.toString();
}

/*
  Lists all the files in a directoy.
*/
String[] listFileNames(String dir) {  
  File file = new File(dataPath(""));
  
  String names[] = file.list();
  for (int i=0; i < names.length; i++) {    
    names[i] = dir + "/" + names[i];
  }
  return names;
}

/*
  Loads the bvh stored in bvhFiles[nextFile] and increments nextFile.
*/
void readNextFile() {
  try {
    println("Loading "+bvhFiles[nextFile]);
    bvhData = new BvhParser().load(readFile(bvhFiles[nextFile]));
    frameRate(bvhData.motion.frameRate);
    println("Frame rate: "+bvhData.motion.frameRate); 
  } 
  catch(Exception e) {
    e.printStackTrace();
    exit();
  }
  nextFile = (nextFile + 1) % bvhFiles.length;
  justStarted = true;
  curFrame = 0;
}

void refreshFileList() {
  // prime list of files from a directory that has only bvh files in it
  bvhFiles = listFileNames("data");
  nextFile = 0;
  readNextFile();
}

void setup() {
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(10);
  cam.setMaximumDistance(1000);
  cam.setDistance(500);
  cam.lookAt(0,0,0);
  
  refreshFileList();    

  size(800, 600, P3D);

  fill(255);  
}

void keyPressed() {
  if (key == 'd') {
    // prints the joints
    bvhData.printJoints(curFrame);
  } else if (key == 'n') {
    // advances to next frame (useful if paused)
    curFrame = (curFrame + 1) % bvhData.motion.numFrames;
  } else if (key == 'p') {
    // goes back to previous frame (useful if paused)
    curFrame = (curFrame - 1) % bvhData.motion.numFrames;  
  } else if (key == 'l') {
    // toggles whether to draw labels or not
    drawLabels = !drawLabels;
  } else if(key == 's') {
    // pause animation or not
    paused = !paused;
  } else if(key == 'j') {
    readNextFile();    
  } else if (key == 'f') {
    refreshFileList();      
  }
}

void draw() {
  background(0);

  if (!paused) {
    // advance to next frame
    curFrame = frameCount % bvhData.motion.numFrames;
    
    // don't loop - when we get to the end, move to next animation
    if (curFrame == 0 && !justStarted) {
      readNextFile();
    }
    
    // readNextFile sets justStarted to true
    justStarted = false;
  }

  // deal with processing having y axis inverted
  scale(1, -1, 1);

  // draw axes
  stroke(255, 0, 0);
  line(0, 0, 0, 100, 0, 0);
  stroke(0, 255, 0);
  line(0, 0, 0, 0, 100, 0);
  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, 100);
  stroke(255);
  
  // draw joint at current frame
  bvhData.drawJoints(curFrame, drawLabels); 
}
