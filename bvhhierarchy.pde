enum BvhChannel {
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
  Matrix44 transform;
    
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
    
    if(parent != null) {
      parent.children.add(this);
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
  
  BvhMotion(int numFrames, double frameTime, double[] data) {
    this.numFrames = numFrames;
    this.frameTime = frameTime;
    this.data = data;
    this.stride = data.length / numFrames;;
  }
}

class BvhData {
  BvhHierarchy hierarchy;
  BvhMotion motion;
  
  BvhData(BvhHierarchy hierarchy, BvhMotion motion) {
    this.hierarchy = hierarchy;
    this.motion = motion;
  }
}

class BvhParser {
  BvhData load(String bvh) throws Exception {
    BvhOffset offset = new BvhOffset();
    
    Tokenizer t = new Tokenizer(bvh);
    t.consume("HIERARCHY");
    
    ArrayList<BvhJoint> roots = new ArrayList<BvhJoint>();
    while(t.peek("ROOT")) {
      roots.add(readJoint(t, null, offset));
    }
    
    BvhJoint[] rootsArr = new BvhJoint[roots.size()];
    for(int i=0; i < roots.size(); i++) {
      rootsArr[i] = roots.get(i);
    }
    
    BvhHierarchy hierarchy = new BvhHierarchy(rootsArr);
    BvhMotion motion = readMotionData(t);
    
    return new BvhData(hierarchy, motion);
  }
  
  BvhMotion readMotionData(Tokenizer t) throws Exception{
    t.consume("MOTION");
    t.consume("Frames:");
    
    int numFrames = Integer.parseInt(t.nextToken());
    t.consume("Frame Time:");
    double frameTime = Double.parseDouble(t.nextToken());
    
    ArrayList<Double> data = new ArrayList<Double>();
    String token;
    while((token = t.nextToken()) != null) {
      data.add(Double.parseDouble(token));
    }
    
    double[] dataArr = new double[data.size()];
    for(int i=0; i < data.size(); i++) {
      dataArr[i] = data.get(i);
    }
    return new BvhMotion(numFrames, frameTime, dataArr);
  }
  
  BvhJoint readJoint(Tokenizer t, BvhJoint parent, BvhOffset offset) throws Exception {
    String name = null;
    if(t.peek("End Site")) {
      t.consume("End Site");
    }
    else if(t.peek("JOINT")) {
      t.consume("JOINT");
      name = t.nextToken();
    } else if(t.peek("ROOT")) {
      t.consume("ROOT");
      name = t.nextToken();
    } else {
      throw new Exception("reading joint but no JOINT, ROOT or End Site as next token");
    }
    
    t.consume("{");
    double xo = 0.0, yo = 0.0, zo = 0.0;
    
    if(t.peek("OFFSET")) {
      t.consume("OFFSET");
      xo = Double.parseDouble(t.nextToken());
      yo = Double.parseDouble(t.nextToken());
      zo = Double.parseDouble(t.nextToken());
    }
    
    BvhChannel[] channels = new BvhChannel[0];
    
    if(t.peek("CHANNELS")) {
      t.consume("CHANNELS");
       int numChannels = Integer.parseInt(t.nextToken());
       channels = new BvhChannel[numChannels];
       for(int i=0; i < numChannels; i++) {
         String channelName = t.nextToken();
         channels[i] = BvhChannel.valueOf(channelName.toUpperCase());
       }
    }
    
    BvhJoint j = new BvhJoint(name, xo, yo, zo, channels, parent, offset);
    
    while(t.peek("JOINT") || t.peek("End Site")) {
      readJoint(t, j, offset);
    }
    
    t.consume("}");
    
    return j;
  }
}