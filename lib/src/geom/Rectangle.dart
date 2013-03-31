part of stagexl;

class Rectangle
{
  num _x;
  num _y;
  num _width;
  num _height;

  Rectangle(num x, num y, num width, num height) :
    _x = x.toDouble(), _y = y.toDouble(), _width = width.toDouble(), _height = height.toDouble();

  Rectangle.zero() : this(0.0, 0.0, 0.0, 0.0); 

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

  Point get size => new Point(_width, _height);

  //-----------------------------------------------------------------------------------------------
  
  set x(num value) {
    _x = value.toDouble();
  }

  set y(num value) {
    _y = value.toDouble();
  }

  set width(num value) {
    _width = value.toDouble();
  }

  set height(num value) {
    _height = value.toDouble();
  }

  set bottom(num value) {
    this.height = value - _y;
  }

  set left(num value) {
    this.x = value;
  }

  set right(num value) {
    this.width = value - _x;
  }

  set top(num value) {
    this.y = value;
  }

  set bottomRight(Point value) {
    this.width = value.x - _x;
    this.height = value.y - _y;
  }

  set topLeft(Point value) {
    this.width = _width + _x - value.x;
    this.height = _height + _y - value.y;
    this.x = value.x;
    this.y = value.y;
   }

  void set size(Point value) {
    this.width = value.x;
    this.height = value.y;
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
    this.x = r.x;
    this.y = r.y; 
    this.width = r.width; 
    this.height = r.height; 
  }
  
  inflate(num dx, num dy) { 
    this.width = _width + dx; 
    this.height = _height + dy; 
  }
  
  inflatePoint(Point p) { 
    this.width = _width + p.x; 
    this.height = _height + p.y; 
  }
  
  offset(num dx, num dy) { 
    this.x = _x + dx; 
    this.y = _y + dy; 
  }
  
  offsetPoint(Point p) { 
    this.x = _x + p.x; 
    this.y = _y + p.y; 
  }
  
  setEmpty() { 
    this.x = 0.0; 
    this.y = 0.0; 
    this.width = 0.0; 
    this.height = 0.0; 
  }
  
  setTo(num rx, num ry, num rwidth, num rheight) { 
    this.x = rx; 
    this.y = ry; 
    this.width = rwidth; 
    this.height = rheight; 
  }

  Rectangle intersection(Rectangle rect) {
    
    if (this.intersects (rect) == false)
      return new Rectangle(0.0, 0.0, 0.0, 0.0);

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

    return new Rectangle(rLeft, rRight, rRight - rLeft, rBottom - rTop);
  }
}
