/*
  Represents a 4x4 matrix.
 */
class Matrix44 {
  double[][] data;

  Matrix44(double[][] data) {
    this.data = data;
  }

  /*
    Adds (doesn't replace) translation values to the last column of
   the 4x4 transformation matrix.
   */
  void translate(double tx, double ty, double tz) {
    data[0][3] += tx;
    data[1][3] += ty;
    data[2][3] += tz;
  }

  /*
    Returns an array holding values of the desired column. 
   */
  double[] col(int index) {
    double[] r = new double[4];
    for (int i=0; i < 4; i++) {
      r[i] = data[i][index];
    }
    return r;
  }

  /*
    Multiply this by another matrix.
   */
  Matrix44 multiply(Matrix44 other) {
    double[][] result = new double[4][];
    for (int i=0; i < 4; i++) {
      result[i] = new double[4];
      for (int j=0; j < 4; j++) {
        for (int k=0; k < 4; k++) {
          result[i][j] = result[i][j] + data[i][k]*other.data[k][j];
        }
      }
    }
    return new Matrix44(result);
  }

  /*
    Print matrix to System.out.
   */
  void print() {
    for (int row=0; row < 4; row++) {
      println();
      for (int col=0; col < 4; col++) {
        System.out.print(""+data[row][col]+"\t");
      }
    }
    println();
  }
}

/*
  Helper class to create transformation matrices.
 */
class Matrices44 {
  Matrix44 identity() {
    return new Matrix44(new double[][] {
      {1.0, 0.0, 0.0, 0.0}, 
      {0.0, 1.0, 0.0, 0.0}, 
      {0.0, 0.0, 1.0, 0.0}, 
      {0.0, 0.0, 0.0, 1.0}
      });
  }

  Matrix44 scaling(double x, double y, double z) {
    return new Matrix44(new double[][] {
      {x, 0.0, 0.0, 0.0}, 
      {0.0, y, 0.0, 0.0}, 
      {0.0, 0.0, z, 0.0}, 
      {0.0, 0.0, 0.0, 1.0}
      });
  }

  Matrix44 xRotation(double r) {
    return new Matrix44(new double[][] {
      {1.0, 0.0, 0.0, 0.0}, 
      {0.0, Math.cos(r), -Math.sin(r), 0.0}, 
      {0.0, Math.sin(r), Math.cos(r), 0.0}, 
      {0.0, 0.0, 0.0, 1.0}
      });
  }

  Matrix44 yRotation(double r) {
    return new Matrix44(new double[][] {
      {Math.cos(r), 0.0, Math.sin(r), 0.0}, 
      {0.0, 1.0, 0.0, 0.0}, 
      {-Math.sin(r), 0.0, Math.cos(r), 0.0}, 
      {0.0, 0.0, 0.0, 1.0}
      });
  }

  Matrix44 zRotation(double r) {
    return new Matrix44(new double[][] {
      {Math.cos(r), -Math.sin(r), 0.0, 0.0}, 
      {Math.sin(r), Math.cos(r), 0.0, 0.0}, 
      {0.0, 0.0, 1.0, 0.0}, 
      {0.0, 0.0, 0.0, 1.0}
      });
  }

  Matrix44 translation(double x, double y, double z) {
    return new Matrix44(new double[][] {
      {1.0, 0.0, 0.0, x}, 
      {0.0, 1.0, 0.0, y}, 
      {0.0, 0.0, 1.0, z}, 
      {0.0, 0.0, 0.0, 1.0}
      });
  }
}