part of example11;

class Dot extends Sprite
{
  int touchPointID;

  Dot(int touchPointID, bool primaryTouchPoint)
  {
    this.touchPointID = touchPointID;

    var shape = new Shape();
    shape.graphics.beginPath();
    shape.graphics.circle(0, 0, 45);
    shape.graphics.closePath();
    shape.graphics.fillColor(primaryTouchPoint ? 0xFFA0F0A0 : 0xFFF0A0A0);
    shape.graphics.strokeColor(Color.Blue, 2);
    addChild(shape);

    var textField = new TextField();
    textField.defaultTextFormat = new TextFormat('Helvetica,Arial', 18, Color.Black, bold:true, align:TextFormatAlign.CENTER);
    textField.width = 80;
    textField.height = 20;
    textField.x = -40;
    textField.y = -70;
    textField.text = this.touchPointID.toString();
    addChild(textField);
  }
}
