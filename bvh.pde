BvhData bvhData; //<>//
int curFrame = 0;
float cx;
float cy;
float cz;
double t = 0;
double r = 1000;
boolean paused = false;
String[] bvhFiles;
int nextFile = 0;
boolean justStarted;
boolean drawLabels = false;
boolean drawJoints = false;

String readFile(String filename) {
  StringBuilder sb = new StringBuilder();
  for (String line : loadStrings(filename)) {
    sb.append(line);
    sb.append("\n");
  }
  return sb.toString();
}

String[] listFileNames(String dir) {
  File file = new File(dir);
  String names[] = file.list();
  for (int i=0; i < names.length; i++) {
    names[i] = dir + "/" + names[i];
  }
  return names;
}

void readNextFile() {
  try {
    println("Loading "+bvhFiles[nextFile]);
    bvhData = new BvhParser().load(readFile(bvhFiles[nextFile]));
  } 
  catch(Exception e) {
    e.printStackTrace();
    exit();
  }
  nextFile = (nextFile + 1) % bvhFiles.length;
  justStarted = true;
}

void setup() {
  bvhFiles = listFileNames("/Users/sambeck/Desktop/Male1_bvh");  
  readNextFile();

  size(800, 600, P3D);

  println("Frame rate: "+bvhData.motion.frameRate);
  frameRate(bvhData.motion.frameRate);
  fill(255);

  cx = 200;
  cy = 100;
  cz = 800;

  scale(1, -1, 1);
}

void keyPressed() {
  if (key == 'd') {
    bvhData.printJoints(curFrame);
  } else if (key == 'n') {
    curFrame = (curFrame + 1) % bvhData.motion.numFrames;
  } else if (key == 'p') {
    curFrame = (curFrame - 1) % bvhData.motion.numFrames;
  } else if (key == 'r') {
    r = 1000;
    cy = 100;
    t = 0;
  } else if (key == 'l') {
    drawLabels = !drawLabels;
  } else if (key == 'j') {
    drawJoints = !drawJoints;
  }
}

void draw() {
  //int start = millis();
  background(0);
  
  if (keyPressed) {
    if (key == 'x') {
      //cx += (mouseX - width /2) + (mouseY - height/2);
      t += mouseX < width/2 ? Math.toRadians(10.0) : Math.toRadians(-10.0);
    } else if (key == 'y') {
      cy +=(mouseX - width /2) + (mouseY - height/2);
    } else if (key == 'z') {
      r += 100;
    } else if (key =='a') {
      r -= 100;
    } else if (key == 'y') {
      cy += 100;
    } else if (key == 'u') {
      cy -= 100;
    }
  }

  cx = Math.round(r*Math.cos(t));
  cz = Math.round(r*Math.sin(t));  

  camera(cx, cy, cz, 0, -300, 0, 0, 1, 0);
  if (!paused) {
    curFrame = frameCount % bvhData.motion.numFrames;
    if (curFrame == 0 && !justStarted) {
      readNextFile();
    }
    justStarted = false;
  }

  scale(1, -1, 1);

  stroke(255, 0, 0);
  line(0, 0, 0, 100, 0, 0);
  stroke(0, 255, 0);
  line(0, 0, 0, 0, 100, 0);
  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, 100);
  stroke(255);

  bvhData.drawJoints(curFrame, drawLabels, drawJoints);
  //println("Elapsed time: "+(millis() - start));
}