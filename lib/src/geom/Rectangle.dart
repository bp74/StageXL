part of stagexl;

class Rectangle {
  
  num _x;
  num _y;
  num _width;
  num _height;

  Rectangle(num x, num y, num width, num height) : _x = x, _y = y, _width = width, _height = height;
  
  Rectangle.zero() : this(0, 0, 0, 0); 

  Rectangle.from(Rectangle r) : this(r.x, r.y, r.width, r.height);

  Rectangle clone() => new Rectangle(_x, _y, _width, _height);

  String toString() => "Rectangle [x=${_x}, y=${_y}, width=${_width}, height=${_height}]";
  
  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  num get x => _x;
  num get y => _y;
  num get width => _width;
  num get height => _height;
  
  num get left => _x;
  num get top => _y;
  num get right => _x + _width;
  num get bottom => _y + _height;

  Point get topLeft => new Point(_x, _y);
  Point get bottomRight => new Point(_x + _width, _y + _height);
  Point get center => new Point(_x + _width /2, _y + _height / 2);
  
  Point get size => new Point(_width, _height);
  
  //-----------------------------------------------------------------------------------------------
  
  set x(num value) {
    _x = value;
  }

  set y(num value) {
    _y = value;
  }

  set width(num value) {
    _width = value;
  }

  set height(num value) {
    _height = value;
  }

  set bottom(num value) {
    this.height = value - _y;
  }

  set left(num value) {
    _x = value;
  }

  set right(num value) {
    _width = value - _x;
  }

  set top(num value) {
    _y = value;
  }

  set bottomRight(Point value) {
    _width = value.x - _x;
    _height = value.y - _y;
  }

  set topLeft(Point value) {
    _width = _width + _x - value.x;
    _height = _height + _y - value.y;
    _x = value.x;
    _y = value.y;
   }

  void set size(Point value) {
    _width = value.x;
    _height = value.y;
  }

  //-----------------------------------------------------------------------------------------------

  bool contains(num px, num py) {
    return _x <= px && _y <= py && _x + _width >= px && _y + _height >= py;
  }
  
  bool containsPoint(Point p) {
    return _x <= p.x && _y <= p.y && _x + _width >= p.x && _y + _height >= p.y;
  }
  
  bool containsRect(Rectangle r) {
    return _x <= r.x && _y <= r.y && _x + _width >= r.right && _y + _height >= r.bottom;
  }
  
  bool equals(Rectangle r) {
    return _x == r.x && _y == r.y && _width == r.width && _height == r.height;
  }
  
  bool intersects(Rectangle r) {
    return this.left < r.right && this.right > r.left && this.top < r.bottom && this.bottom > r.top;
  }

  bool get isEmpty {
    return _width == 0 && _height == 0;
  }

  //-----------------------------------------------------------------------------------------------

  copyFrom(Rectangle r) { 
    _x = r.x;
    _y = r.y; 
    _width = r.width; 
    _height = r.height; 
  }
  
  inflate(num dx, num dy) { 
    _width = _width + dx; 
    _height = _height + dy; 
  }
  
  inflatePoint(Point p) { 
    _width = _width + p.x; 
    _height = _height + p.y; 
  }
  
  offset(num dx, num dy) { 
    _x = _x + dx; 
    _y = _y + dy; 
  }
  
  offsetPoint(Point p) { 
    _x = _x + p.x; 
    _y = _y + p.y; 
  }
  
  setEmpty() { 
    _x = 0; 
    _y = 0; 
    _width = 0; 
    _height = 0; 
  }
  
  setTo(num rx, num ry, num rwidth, num rheight) { 
    _x = rx; 
    _y = ry; 
    _width = rwidth; 
    _height = rheight; 
  }

  Rectangle intersection(Rectangle rect) {
    
    if (this.intersects (rect) == false)
      return new Rectangle.zero();

    num rLeft = max (this.left, rect.left);
    num rTop = max (this.top, rect.top);
    num rRight = min (this.right, rect.right);
    num rBottom = min (this.bottom, rect.bottom);

    return new Rectangle(rLeft, rRight, rRight - rLeft, rBottom - rTop);
  }

  Rectangle union(Rectangle rect) {
    
    num rLeft = min (this.left, rect.left);
    num rTop = min (this.top, rect.top);
    num rRight = max (this.right, rect.right);
    num rBottom = max (this.bottom, rect.bottom);

    return new Rectangle(rLeft, rTop, rRight - rLeft, rBottom - rTop);
  }
  
  Rectangle align() {
    int rLeft = this.left.floor();
    int rTop = this.top.floor();
    int rRight = this.right.ceil();
    int rBottom = this.bottom.ceil();

    return new Rectangle(rLeft, rTop, rRight - rLeft, rBottom - rTop);
  }
}
