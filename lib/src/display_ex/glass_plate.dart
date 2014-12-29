part of stagexl.display_ex;

/// An invisible and rectangular display object to catch input events.
///
/// You can use the GlassPlate to cover up other display objects to catch
/// all interactive inputs like mouse and touch inputs. This is useful if
/// the covered display objects has an undetermined size but you need
/// a rectangular hit area. It may also improve the performance if you
/// cover many display objects with one GlassPlate, this way the engine
/// does not need to check for hits on the covered display objects.

class GlassPlate extends InteractiveObject {

  num width;
  num height;

  GlassPlate(this.width, this.height);

  //---------------------------------------------------------------------------

  @override
  Rectangle<num> get bounds {
    return new Rectangle<num>(0.0, 0.0, width, height);
  }

  @override
  DisplayObject hitTestInput(num localX, num localY) {
    if (localX < 0.0 || localX >= width) return null;
    if (localY < 0.0 || localY >= height) return null;
    return this;
  }

  @override
  void render(RenderState renderState) {
    // A GlassPlate is inherently invisible.
  }
}
