// bvh file being played //<>//
BvhData bvhData;

// frame index in current bvhData.motion
int curFrame = 0;

// camera position
float cx;
float cy;
float cz;

// camera angle around the y axis
double t = 0;

// camera distance away from the origin
double r = 1000;

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
  refreshFileList();    

  size(800, 600, P3D);

  println("Frame rate: "+bvhData.motion.frameRate);
  
  
  fill(255);
  
  // initialize camera position
  cx = 200;
  cy = 100;
  cz = 800;
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
  } else if (key == 'r') {
    // reset camera position, kind of
    r = 1000;
    cy = 100;
    t = 0;
  } else if (key == 'l') {
    // toggles whether to draw labels or not
    drawLabels = !drawLabels;
  } else if(key == 's') {
    // pause animation or not
    paused = !paused;
  } else if(key == 'j') {
    readNextFile();    
  } else if (key == 'r') {
    refreshFileList();      
  }

int ty = 0;
void draw() {
  background(0);

  if (keyPressed) {
    if (key == 'x') {
      // rotates around the y axis in the direction
      t += mouseX < width/2 ? Math.toRadians(10.0) : Math.toRadians(-10.0);
    } else if (key == 'z') {
      // advances camera in the z direction
      r += 100;
    } else if (key =='a') {
      // retracts camera in the z direction
      r -= 100;
    } else if (key == 'y') {
      ty += 100;
    } else if (key == 'u') {
      ty -= 100;
    } 
  }

  // camera x and z position is determined by rotation around y at an angle t, with radius r
  cx = Math.round(r*Math.cos(t));
  cz = Math.round(r*Math.sin(t));  

  // camera points to root joint at every frame
  double[] col = bvhData.hierarchy.roots[0].transforms[curFrame].col(3);
  camera(cx, ty+(int)col[2], cz, (int)col[0], (int)col[1], (int)col[2], 0, 1, 0);

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
  translate(0, -height/2, 0);

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
