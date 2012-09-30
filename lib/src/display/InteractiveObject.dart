abstract class InteractiveObject extends DisplayObject
{
  bool doubleClickEnabled = false;
  bool mouseEnabled = true;
  bool tabEnabled = true;
  int tabIndex = 0;
  
  InteractiveObjectEvents get on => new InteractiveObjectEvents(this);
}
