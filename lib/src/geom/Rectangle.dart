part of dartflash;

class Rectangle
{
  num x;
  num y;
  num width;
  num height;

  Rectangle(this.x, this.y, this.width, this.height);

  Rectangle.zero() : this(0, 0, 0, 0);

  Rectangle.from(Rectangle r) : this(r.x, r.y, r.width, r.height);

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  num get left => this.x;
  num get top => this.y;
  num get right => this.x + this.width;
  num get bottom => this.y + this.height;

  Point get topLeft => new Point(this.x, this.y);
  Point get bottomRight => new Point(this.x + this.width, this.y + this.height);

  Point get size => new Point(this.width, this.height);

  //-------------------------------------------------------------------------------------------------

  void set bottom(num value)
  {
    this.height = value - this.y;
  }

  void set left(num value)
  {
    this.x = value;
  }

  void set right(num value)
  {
    this.width = value - this.x;
  }

  void set top(num value)
  {
    this.y = value;
  }

  void set bottomRight(Point value)
  {
    this.width = value.x - this.x;
    this.height = value.y - this.y;
  }

  void set topLeft(Point value)
  {
    this.width = this.width + this.x - value.x;
    this.height = this.height + this.y - value.y;
    this.x = value.x;
    this.y = value.y;
   }

  void set size(Point value)
  {
    this.width = value.x;
    this.height = value.y;
  }

  //-------------------------------------------------------------------------------------------------

  Rectangle clone() => new Rectangle(this.x, this.y, this.width, this.height);

  bool contains(num px, num py) => (this.x <= px && this.y <= py && this.right >= px && this.bottom >= py);
  bool containsPoint(Point p) => (this.left <= p.x && this.right <= p.y && this.right >= p.x && this.bottom >= p.y);
  bool containsRect(Rectangle r) => (this.left <= r.left && this.top <= r.top && this.right >= r.right && this.bottom >= r.bottom);
  bool equals(Rectangle r) => (this.x == r.x && this.y == r.y && this.width == r.width && this.height == r.height);
  bool intersects(Rectangle r) => (this.left < r.right && this.right > r.left && this.top < r.bottom && this.bottom > r.top);

  bool get isEmpty => (this.width == 0 && this.height == 0);

  void copyFrom(Rectangle r) { this.x = r.x; this.y = r.y; this.width = r.width; this.height = r.height; }
  void inflate(num dx, num dy) { this.width = this.width + dx; this.height = this.height + dy; }
  void inflatePoint(Point p) { this.width = this.width + p.x; this.height = this.height + p.y; }
  void offset(num dx, num dy) { this.x = this.x + dx; this.y = this.y + dy; }
  void offsetPoint(Point p) { this.x = this.x + p.x; this.y = this.y + p.y; }
  void setEmpty() { this.x = 0.0; this.y = 0.0; this.width = 0.0; this.height = 0.0; }
  void setTo(num rx, num ry, num rwidth, num rheight) { this.x = rx; this.y = ry; this.width = rwidth; this.height = rheight; }

  Rectangle intersection(Rectangle rect)
  {
    if (this.intersects (rect) == false)
      return new Rectangle(0.0, 0.0, 0.0, 0.0);

    num rLeft = max (this.left, rect.left);
    num rTop = max (this.top, rect.top);
    num rRight = min (this.right, rect.right);
    num rBottom = min (this.bottom, rect.bottom);

    return new Rectangle(rLeft, rRight, rRight - rLeft, rBottom - rTop);
  }

  Rectangle union(Rectangle rect)
  {
    num rLeft = min (this.left, rect.left);
    num rTop = min (this.top, rect.top);
    num rRight = max (this.right, rect.right);
    num rBottom = max (this.bottom, rect.bottom);

    return new Rectangle(rLeft, rRight, rRight - rLeft, rBottom - rTop);
  }

}
