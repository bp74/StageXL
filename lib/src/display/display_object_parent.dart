part of stagexl.display;

/// An abstract class implemented by containers for display objects.
///
/// This class defines the classic [addChild]/[removeChild] methods
/// from the well known Flash display list. It also contains a more
/// modern [children] iterable for advanced use cases.

abstract class DisplayObjectParent<T extends DisplayObject>
    extends DisplayObject {

  DisplayObjectChildren<T> get children;

  int get numChildren;

  T getChildAt(int index);
  T getChildByName(String name);
  int getChildIndex(T child);

  void addChild(T child);
  void addChildAt(T child, int index);

  void removeChild(T child);
  void removeChildAt(int index);
  void removeChildren([int beginIndex, int endIndex]);

  void replaceChildAt(T child, int index);
}
