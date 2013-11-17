part of stagexl;

class Warp extends DisplayObjectContainer {
  
  Matrix _matrix = new Matrix.fromIdentity();

  //-------------------------------------------------------------------------------------------------

  Matrix get transformationMatrix => _matrix;

  Matrix get matrix => _matrix;
  
  set matrix(Matrix value) {
    _matrix = value;
  }

}
