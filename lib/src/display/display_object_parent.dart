part of stagexl.display;

/// An abstract class implemented by containers for display objects.
///
/// This class defines the classic [addChild]/[removeChild] methods
/// from the well known Flash display list. It also contains a more
/// modern [children] iterable for advanced use cases.

abstract class DisplayObjectParent extends DisplayObject {

  DisplayObjectChildren get children;

  int get numChildren;

  DisplayObject getChildAt(int index);
  DisplayObject getChildByName(String name);
  int getChildIndex(DisplayObject child);

  void addChild(DisplayObject child);
  void addChildAt(DisplayObject child, int index);

  void removeChild(DisplayObject child);
  void removeChildAt(int index);
  void removeChildren([int beginIndex, int endIndex]);

  void replaceChildAt(DisplayObject child, int index);
}
