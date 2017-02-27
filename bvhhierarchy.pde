enum BvhChannel { //<>// //<>//
  XPOSITION, 
  YPOSITION, 
  ZPOSITION, 
  XROTATION, 
  YROTATION, 
  ZROTATION
};

class BvhOffset {
  int offset;
}

class BvhJoint {
  String name;
  double offsetX, offsetY, offsetZ;
  BvhChannel[] channels;
  int motionIndex;
  BvhJoint parent;
  ArrayList<BvhJoint> children;
  Matrix44[] transforms;

  BvhJoint(String name, double ox, double oy, double oz, BvhChannel[] channels, BvhJoint parent, BvhOffset offset) {
    this.parent = parent;
    this.name = name;
    this.offsetX = ox;
    this.offsetY = oy;
    this.offsetZ = oz;
    this.channels = channels;
    this.children = new ArrayList<BvhJoint>();
    this.motionIndex = offset.offset;
    offset.offset += channels.length;

    if (parent != null) {
      parent.children.add(this);
    }
  }

  void drawJoint(int curFrame, boolean drawLabels, boolean drawJoints) {  
    double[] lastRow = transforms[curFrame].col(3);

    if (drawLabels) {
      textSize(9);
      if (name != null) {
        text(name, (float)lastRow[0], (float)lastRow[1], (float)lastRow[2]);
      }
    }

    if (drawJoints) {
      pushMatrix();
      translate((float)lastRow[0], (float)lastRow[1], (float)lastRow[2]);
      sphere(2);
      popMatrix();
    }

    for (BvhJoint child : children) {
      double[] childLastRow = child.transforms[curFrame].col(3);
      line((float)lastRow[0], (float)lastRow[1], (float)lastRow[2], (float)childLastRow[0], (float)childLastRow[1], (float)childLastRow[2]);
      child.drawJoint(curFrame, drawLabels, drawJoints);
    }
  }

  void printJoint(int curFrame, BvhMotion motion) {
    int offset = curFrame * motion.stride;
    double[] lastRow = transforms[curFrame].col(3);
    print(name + ": xyz("+lastRow[0]+","+lastRow[1]+","+lastRow[2]+")  (ox, oy, oz): "+offsetX+","+offsetY+","+offsetZ+") channels: ");

    for (int i=0; i < channels.length; i++) {
      double value = motion.data[offset+motionIndex+i];
      BvhChannel channel = channels[i];
      print(channel+" = " + value+ " ");
    }

    print(" motion offset: "+motionIndex);
    println();
    transforms[curFrame].print();

    for (BvhJoint child : children) {
      child.printJoint(curFrame, motion);
    }
  }
}

class BvhHierarchy {
  BvhJoint[] roots;

  BvhHierarchy(BvhJoint[] roots) {
    this.roots = roots;
  }
}

class BvhMotion {
  int numFrames;
  double frameTime; // fps = 1 / frameTime

  double[] data; // 0: frame, 1: joint index x channel
  int stride;
  int frameRate;

  BvhMotion(int numFrames, double frameTime, double[] data) {
    this.numFrames = numFrames;
    this.frameTime = frameTime;
    this.data = data;
    this.stride = data.length / numFrames;
    this.frameRate = (int)(1.0/frameTime);
  }
}

class BvhData {
  BvhHierarchy hierarchy;
  BvhMotion motion;
  Matrices44 m;

  BvhData(BvhHierarchy hierarchy, BvhMotion motion) {
    this.hierarchy = hierarchy;
    this.motion = motion;
    this.m = new Matrices44();
    computeTransforms();
  }

  void computeTransforms() {
    println("Computing transforms for all frames");
    for (BvhJoint root : hierarchy.roots) {
      computeTransforms(root);
    }
    println("Done computing transforms");
  }

  void computeTransforms(BvhJoint joint) {
    joint.transforms = new Matrix44[motion.numFrames];
    for (int frame=0; frame < motion.numFrames; frame++) {
      int offset = frame * motion.stride;
      joint.transforms[frame] = m.translation(joint.offsetX, joint.offsetY, joint.offsetZ);

      for (int i=0; i < joint.channels.length; i++) {
        double value = motion.data[offset+joint.motionIndex+i];
        BvhChannel channel = joint.channels[i];
        Matrix44 op = null;

        if (channel == BvhChannel.XPOSITION) joint.transforms[frame].translate(value, 0, 0);
        if (channel == BvhChannel.YPOSITION) joint.transforms[frame].translate(0, value, 0);
        if (channel == BvhChannel.ZPOSITION) joint.transforms[frame].translate(0, 0, value);

        if (channel == BvhChannel.XROTATION) op = m.xRotation(Math.toRadians(value));
        if (channel == BvhChannel.YROTATION) op = m.yRotation(Math.toRadians(value));
        if (channel == BvhChannel.ZROTATION) op = m.zRotation(Math.toRadians(value));

        if (op != null) {
          joint.transforms[frame] = joint.transforms[frame].multiply(op);
        }
      }

      if (joint.parent != null) {
        joint.transforms[frame] = joint.parent.transforms[frame].multiply(joint.transforms[frame]);
      }
    }

    for (BvhJoint child : joint.children) {
      computeTransforms(child);
    }
  }

  void drawJoints(int curFrame, boolean drawLabels, boolean drawJoints) {
    BvhJoint[] roots = hierarchy.roots;
    for (int i=0; i < roots.length; i++) {
      roots[i].drawJoint(curFrame, drawLabels, drawJoints);
    }
  }

  void printJoints(int curFrame) {  
    BvhJoint[] roots = hierarchy.roots;
    for (int i=0; i < roots.length; i++) {
      roots[i].printJoint(curFrame, motion);
    }
    println();
  }
}

class BvhParser {
  BvhData load(String bvh) throws Exception {
    BvhOffset offset = new BvhOffset();

    Tokenizer t = new Tokenizer(bvh);
    t.consume("HIERARCHY");

    ArrayList<BvhJoint> roots = new ArrayList<BvhJoint>();
    while (t.peek("ROOT")) {
      roots.add(readJoint(t, null, offset));
    }

    BvhJoint[] rootsArr = new BvhJoint[roots.size()];
    for (int i=0; i < roots.size(); i++) {
      rootsArr[i] = roots.get(i);
    }

    BvhHierarchy hierarchy = new BvhHierarchy(rootsArr);
    BvhMotion motion = readMotionData(t);

    return new BvhData(hierarchy, motion);
  }

  BvhMotion readMotionData(Tokenizer t) throws Exception {
    t.consume("MOTION");
    t.consume("Frames:");

    int numFrames = Integer.parseInt(t.nextToken());
    t.consume("Frame Time:");
    double frameTime = Double.parseDouble(t.nextToken());

    ArrayList<Double> data = new ArrayList<Double>();
    String token;
    while ((token = t.nextToken()) != null) {
      data.add(Double.parseDouble(token));
    }

    double[] dataArr = new double[data.size()];
    for (int i=0; i < data.size(); i++) {
      dataArr[i] = data.get(i);
    }
    return new BvhMotion(numFrames, frameTime, dataArr);
  }

  BvhJoint readJoint(Tokenizer t, BvhJoint parent, BvhOffset offset) throws Exception {
    String name = null;
    if (t.peek("End Site")) {
      t.consume("End Site");
    } else if (t.peek("JOINT")) {
      t.consume("JOINT");
      name = t.nextToken();
    } else if (t.peek("ROOT")) {
      t.consume("ROOT");
      name = t.nextToken();
    } else {
      throw new Exception("reading joint but no JOINT, ROOT or End Site as next token");
    }

    t.consume("{");
    double xo = 0.0, yo = 0.0, zo = 0.0;

    if (t.peek("OFFSET")) {
      t.consume("OFFSET");
      xo = Double.parseDouble(t.nextToken());
      yo = Double.parseDouble(t.nextToken());
      zo = Double.parseDouble(t.nextToken());
    }

    BvhChannel[] channels = new BvhChannel[0];

    if (t.peek("CHANNELS")) {
      t.consume("CHANNELS");
      int numChannels = Integer.parseInt(t.nextToken());
      channels = new BvhChannel[numChannels];
      for (int i=0; i < numChannels; i++) {
        String channelName = t.nextToken();
        channels[i] = BvhChannel.valueOf(channelName.toUpperCase());
      }
    }

    BvhJoint j = new BvhJoint(name, xo, yo, zo, channels, parent, offset);

    while (t.peek("JOINT") || t.peek("End Site")) {
      readJoint(t, j, offset);
    }

    t.consume("}");

    return j;
  }
}