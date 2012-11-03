part of example11;

class Dot extends Sprite
{
  int touchPointID;

  Dot(int touchPointID)
  {
    this.touchPointID = touchPointID;

    var shape = new Shape();
    shape.graphics.beginPath();
    shape.graphics.circle(0, 0, 40);
    shape.graphics.closePath();
    shape.graphics.fillColor(0xFF00FF);
    addChild(shape);

    var textField = new TextField();
    textField.defaultTextFormat = new TextFormat('Helvetica,Arial', 14, Color.Black);
    textField.width = 80;
    textField.height = 20;
    textField.x = -40;
    textField.y = -10;
    textField.text = this.touchPointID.toString();
    addChild(textField);
  }
}
