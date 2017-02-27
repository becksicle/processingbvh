BvhData bvhData; //<>//
Matrices44 m = new Matrices44();
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
boolean drawLabels = true;

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

  println("Frame rate: "+(int)(1.0/bvhData.motion.frameTime));
  frameRate((int)(1.0/bvhData.motion.frameTime));
  fill(255);

  cx = 200;
  cy = 100;
  cz = 800;

  scale(1, -1, 1);
}

void keyPressed() {
  if (key == 'd') {
    BvhJoint[] roots = bvhData.hierarchy.roots;
    for (int i=0; i < roots.length; i++) {
      printJoints(roots[i], curFrame*bvhData.motion.stride);
    }
    println();
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
  }
}

void draw() {
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

  BvhJoint[] roots = bvhData.hierarchy.roots;
  for (int i=0; i < roots.length; i++) {
    transformJoint(roots[i], curFrame*bvhData.motion.stride);
    drawJoint(roots[i]);
  }
}

void printJoints(BvhJoint joint, int offset) {
  double[] lastRow = joint.transform.col(3);
  print(joint.name + ": xyz("+lastRow[0]+","+lastRow[1]+","+lastRow[2]+")  (ox, oy, oz): "+joint.offsetX+","+joint.offsetY+","+joint.offsetZ+") channels: ");

  for (int i=0; i < joint.channels.length; i++) {
    double value = bvhData.motion.data[offset+joint.motionIndex+i];
    BvhChannel channel = joint.channels[i];
    print(channel+" = " + value+ " ");
  }

  print(" motion offset: "+joint.motionIndex);
  println();
  joint.transform.print();

  for (BvhJoint child : joint.children) {
    printJoints(child, offset);
  }
}

void drawJoint(BvhJoint joint) {  
  double[] lastRow = joint.transform.col(3);

  if(drawLabels) {
    textSize(9);
    if (joint.name != null) {
      text(joint.name, (float)lastRow[0], (float)lastRow[1], (float)lastRow[2]);
    }
  }

  pushMatrix();
  translate((float)lastRow[0], (float)lastRow[1], (float)lastRow[2]);
  sphere(2);
  popMatrix();

  for (BvhJoint child : joint.children) {
    double[] childLastRow = child.transform.col(3);
    line((float)lastRow[0], (float)lastRow[1], (float)lastRow[2], (float)childLastRow[0], (float)childLastRow[1], (float)childLastRow[2]);
    drawJoint(child);
  }
}

void transformJoint(BvhJoint joint, int offset) {  
  joint.transform = m.translation(joint.offsetX, joint.offsetY, joint.offsetZ);

  for (int i=0; i < joint.channels.length; i++) {
    double value = bvhData.motion.data[offset+joint.motionIndex+i];
    BvhChannel channel = joint.channels[i];
    Matrix44 op = null;

    if (channel == BvhChannel.XPOSITION) joint.transform.translate(value, 0, 0);
    if (channel == BvhChannel.YPOSITION) joint.transform.translate(0, value, 0);
    if (channel == BvhChannel.ZPOSITION) joint.transform.translate(0, 0, value);

    if (channel == BvhChannel.XROTATION) op = m.xRotation(Math.toRadians(value));
    if (channel == BvhChannel.YROTATION) op = m.yRotation(Math.toRadians(value));
    if (channel == BvhChannel.ZROTATION) op = m.zRotation(Math.toRadians(value));


    if (op != null) {
      joint.transform = joint.transform.multiply(op);
    }
  }

  if (joint.parent != null) {
    joint.transform = joint.parent.transform.multiply(joint.transform);
  }

  for (BvhJoint child : joint.children) {
    transformJoint(child, offset);
  }
}