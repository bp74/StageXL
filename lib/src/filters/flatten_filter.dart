part of stagexl.filters;

/// The FlattenFilter does not change the visual appearance of the BitmapData
/// or DisplayObject where it is applied to. This filter can be used to merge
/// the children of a DisplayObjectContainer to a flat texture. This is useful
/// for DisplayObjects with certain blend modes or alpha values.
///
/// Example:
///
///     var sprite = new Sprite();
///     sprite.addChild(background);
///     sprite.addChild(foreground);
///     sprite.addChild(text);
///     sprite.blendMode = BlendMode.ADD;
///     sprite.filters = [new FlattenFilter()];
///
class FlattenFilter extends BitmapFilter {
  BitmapFilter clone() => new FlattenFilter();
}