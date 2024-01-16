part of '../engine.dart';

class RenderTextureQuad {
  final RenderTexture renderTexture;
  final Rectangle<int> sourceRectangle;
  final Rectangle<int> offsetRectangle;
  final int rotation;
  final num pixelRatio;

  final Int16List ixListQuad = Int16List(6);
  final Float32List vxListQuad = Float32List(16);

  late Int16List _ixList;
  late Float32List _vxList;
  bool _hasCustomVertices = false;

  //---------------------------------------------------------------------------

  RenderTextureQuad(this.renderTexture, this.sourceRectangle,
      this.offsetRectangle, this.rotation, this.pixelRatio) {
    final sr = sourceRectangle;
    final or = offsetRectangle;
    final rt = renderTexture;
    final pr = pixelRatio;

    // Vertex list [x/y]

    if (rotation == 0 || rotation == 2) {
      vxListQuad[00] = vxListQuad[12] = (0 - or.left) / pr;
      vxListQuad[01] = vxListQuad[05] = (0 - or.top) / pr;
      vxListQuad[08] = vxListQuad[04] = (0 - or.left + sr.width) / pr;
      vxListQuad[09] = vxListQuad[13] = (0 - or.top + sr.height) / pr;
    } else if (rotation == 1 || rotation == 3) {
      vxListQuad[00] = vxListQuad[12] = (0 - or.left) / pr;
      vxListQuad[01] = vxListQuad[05] = (0 - or.top) / pr;
      vxListQuad[08] = vxListQuad[04] = (0 - or.left + sr.height) / pr;
      vxListQuad[09] = vxListQuad[13] = (0 - or.top + sr.width) / pr;
    } else {
      throw Error();
    }

    // Vertex list [u/v]

    if (rotation == 0) {
      vxListQuad[02] = vxListQuad[14] = sr.left / rt.width;
      vxListQuad[03] = vxListQuad[07] = sr.top / rt.height;
      vxListQuad[10] = vxListQuad[06] = sr.right / rt.width;
      vxListQuad[11] = vxListQuad[15] = sr.bottom / rt.height;
    } else if (rotation == 1) {
      vxListQuad[02] = vxListQuad[06] = sr.right / rt.width;
      vxListQuad[03] = vxListQuad[15] = sr.top / rt.height;
      vxListQuad[10] = vxListQuad[14] = sr.left / rt.width;
      vxListQuad[11] = vxListQuad[07] = sr.bottom / rt.height;
    } else if (rotation == 2) {
      vxListQuad[02] = vxListQuad[14] = sr.right / rt.width;
      vxListQuad[03] = vxListQuad[07] = sr.bottom / rt.height;
      vxListQuad[10] = vxListQuad[06] = sr.left / rt.width;
      vxListQuad[11] = vxListQuad[15] = sr.top / rt.height;
    } else if (rotation == 3) {
      vxListQuad[02] = vxListQuad[06] = sr.left / rt.width;
      vxListQuad[03] = vxListQuad[15] = sr.bottom / rt.height;
      vxListQuad[10] = vxListQuad[14] = sr.right / rt.width;
      vxListQuad[11] = vxListQuad[07] = sr.top / rt.height;
    } else {
      throw Error();
    }

    // Index list

    ixListQuad[0] = 0;
    ixListQuad[1] = 1;
    ixListQuad[2] = 2;
    ixListQuad[3] = 0;
    ixListQuad[4] = 2;
    ixListQuad[5] = 3;

    // set default vertices to quad vertices

    _vxList = vxListQuad;
    _ixList = ixListQuad;
    _hasCustomVertices = false;
  }

  //---------------------------------------------------------------------------

  factory RenderTextureQuad.slice(RenderTextureQuad renderTextureQuad,
      Rectangle<int> sourceRectangle, Rectangle<int> offsetRectangle,
      [int rotation = 0]) {
    final renderTexture = renderTextureQuad.renderTexture;
    final pixelRatio = renderTextureQuad.pixelRatio;

    final oldRotation = renderTextureQuad.rotation;
    final oldSourceL = renderTextureQuad.sourceRectangle.left;
    final oldSourceT = renderTextureQuad.sourceRectangle.top;
    final oldSourceR = renderTextureQuad.sourceRectangle.right;
    final oldSourceB = renderTextureQuad.sourceRectangle.bottom;
    final oldOffsetL = renderTextureQuad.offsetRectangle.left;
    final oldOffsetT = renderTextureQuad.offsetRectangle.top;

    rotation = (renderTextureQuad.rotation + rotation) % 4;
    var sourceL = sourceRectangle.left;
    var sourceT = sourceRectangle.top;
    var sourceR = sourceRectangle.right;
    var sourceB = sourceRectangle.bottom;
    var offsetL = offsetRectangle.left;
    var offsetT = offsetRectangle.top;
    final offsetW = offsetRectangle.width;
    final offsetH = offsetRectangle.height;

    var tmpSourceL = 0;
    var tmpSourceT = 0;
    var tmpSourceR = 0;
    var tmpSourceB = 0;

    if (oldRotation == 0) {
      tmpSourceL = oldSourceL + oldOffsetL + sourceL;
      tmpSourceT = oldSourceT + oldOffsetT + sourceT;
      tmpSourceR = oldSourceL + oldOffsetL + sourceR;
      tmpSourceB = oldSourceT + oldOffsetT + sourceB;
    } else if (oldRotation == 1) {
      tmpSourceL = oldSourceR - oldOffsetT - sourceB;
      tmpSourceT = oldSourceT + oldOffsetL + sourceL;
      tmpSourceR = oldSourceR - oldOffsetT - sourceT;
      tmpSourceB = oldSourceT + oldOffsetL + sourceR;
    } else if (oldRotation == 2) {
      tmpSourceL = oldSourceR - oldOffsetL - sourceR;
      tmpSourceT = oldSourceB - oldOffsetT - sourceB;
      tmpSourceR = oldSourceR - oldOffsetL - sourceL;
      tmpSourceB = oldSourceB - oldOffsetT - sourceT;
    } else if (oldRotation == 3) {
      tmpSourceL = oldSourceL + oldOffsetT + sourceT;
      tmpSourceT = oldSourceB - oldOffsetL - sourceR;
      tmpSourceR = oldSourceL + oldOffsetT + sourceB;
      tmpSourceB = oldSourceB - oldOffsetL - sourceL;
    }

    sourceL = tmpSourceL.clamp(oldSourceL, oldSourceR);
    sourceT = tmpSourceT.clamp(oldSourceT, oldSourceB);
    sourceR = tmpSourceR.clamp(oldSourceL, oldSourceR);
    sourceB = tmpSourceB.clamp(oldSourceT, oldSourceB);

    if (rotation == 0) {
      offsetL += tmpSourceL - sourceL;
      offsetT += tmpSourceT - sourceT;
    } else if (rotation == 1) {
      offsetL += tmpSourceT - sourceT;
      offsetT += sourceR - tmpSourceR;
    } else if (rotation == 2) {
      offsetL += sourceR - tmpSourceR;
      offsetT += tmpSourceB - sourceB;
    } else if (rotation == 3) {
      offsetL += sourceB - tmpSourceB;
      offsetT += sourceL - tmpSourceL;
    }

    final sourceW = sourceR - sourceL;
    final sourceH = sourceB - sourceT;

    return RenderTextureQuad(
        renderTexture,
        Rectangle<int>(sourceL, sourceT, sourceW, sourceH),
        Rectangle<int>(offsetL, offsetT, offsetW, offsetH),
        rotation,
        pixelRatio);
  }

  //---------------------------------------------------------------------------

  bool get isEquivalentToSource =>
      (rotation == 0) &&
      !_hasCustomVertices &&
      (sourceRectangle.left == 0 &&
          sourceRectangle.top == 0 &&
          sourceRectangle.width == renderTexture.width &&
          sourceRectangle.height == renderTexture.height);

  //---------------------------------------------------------------------------

  num get targetWidth => offsetRectangle.width / pixelRatio;

  num get targetHeight => offsetRectangle.height / pixelRatio;

  Float32List get vxList => _vxList;

  Int16List get ixList => _ixList;

  bool get hasCustomVertices => _hasCustomVertices;

  Rectangle<num> get targetRectangle {
    final num l = offsetRectangle.left / pixelRatio;
    final num t = offsetRectangle.top / pixelRatio;
    final num w = offsetRectangle.width / pixelRatio;
    final num h = offsetRectangle.height / pixelRatio;
    return Rectangle<num>(l, t, w, h);
  }

  RenderTextureQuad withPixelRatio(num pixelRatio) => RenderTextureQuad(
      renderTexture, sourceRectangle, offsetRectangle, rotation, pixelRatio);

  //---------------------------------------------------------------------------

  void setQuadVertices() {
    _vxList = vxListQuad;
    _ixList = ixListQuad;
    _hasCustomVertices = false;
  }

  void setCustomVertices(Float32List vxList, Int16List ixList) {
    _vxList = vxList;
    _ixList = ixList;
    _hasCustomVertices = true;
  }

  //---------------------------------------------------------------------------

  /// The matrix transformation for this RenderTextureQuad to
  /// transform target coordinates to texture coordinates.
  ///
  /// Texture coordinates are in the range from (0, 0) to (width, height).
  /// Target coordinates take the [pixelRatio] into account.

  Matrix get drawMatrix {
    final pr = pixelRatio;

    if (rotation == 0) {
      final tx = sourceRectangle.left + offsetRectangle.left;
      final ty = sourceRectangle.top + offsetRectangle.top;
      return Matrix(pr, 0.0, 0.0, pr, tx, ty);
    } else if (rotation == 1) {
      final tx = sourceRectangle.right - offsetRectangle.top;
      final ty = sourceRectangle.top + offsetRectangle.left;
      return Matrix(0.0, pr, 0.0 - pr, 0.0, tx, ty);
    } else if (rotation == 2) {
      final tx = sourceRectangle.right - offsetRectangle.left;
      final ty = sourceRectangle.bottom - offsetRectangle.top;
      return Matrix(0.0 - pr, 0.0, 0.0, 0.0 - pr, tx, ty);
    } else if (rotation == 3) {
      final tx = sourceRectangle.left + offsetRectangle.top;
      final ty = sourceRectangle.bottom - offsetRectangle.left;
      return Matrix(0.0, 0.0 - pr, pr, 0.0, tx, ty);
    } else {
      throw Error();
    }
  }

  //---------------------------------------------------------------------------

  /// The matrix transformation for this RenderTextureQuad to
  /// transform target coordinates to sampler coordinates.
  ///
  /// Sampler coordinate are in the range from (0, 0) to (1, 1).
  /// Target coordinates take the [pixelRatio] into account.

  Matrix get samplerMatrix {
    final pr = pixelRatio;
    final sx = 1.0 / renderTexture.width;
    final sy = 1.0 / renderTexture.height;

    if (rotation == 0) {
      final tx = sourceRectangle.left + offsetRectangle.left;
      final ty = sourceRectangle.top + offsetRectangle.top;
      return Matrix(sx * pr, 0.0, 0.0, sy * pr, sx * tx, sy * ty);
    } else if (rotation == 1) {
      final tx = sourceRectangle.right - offsetRectangle.top;
      final ty = sourceRectangle.top + offsetRectangle.left;
      return Matrix(0.0, sy * pr, 0.0 - sx * pr, 0.0, sx * tx, sy * ty);
    } else if (rotation == 2) {
      final tx = sourceRectangle.right - offsetRectangle.left;
      final ty = sourceRectangle.bottom - offsetRectangle.top;
      return Matrix(0.0 - sx * pr, 0.0, 0.0, 0.0 - sy * pr, sx * tx, sy * ty);
    } else if (rotation == 3) {
      final tx = sourceRectangle.left + offsetRectangle.top;
      final ty = sourceRectangle.bottom - offsetRectangle.left;
      return Matrix(0.0, 0.0 - sy * pr, sx * pr, 0.0, sx * tx, sy * ty);
    } else {
      throw Error();
    }
  }

  //---------------------------------------------------------------------------

  /// Clips a RenderTextureQuad from this RenderTextureQuad. The offset
  /// of the RenderTextureQuad will be adjusted to match the origin of
  /// this RenderTextureQuad.
  ///
  /// The [rectangle] is in target coordinates. Those coordinates take the
  /// [pixelRatio] into account. Please read more about HiDpi textures to
  /// learn more about this topic.

  RenderTextureQuad clip(Rectangle<num> rectangle) {
    final rL = (rectangle.left * pixelRatio).round();
    final rT = (rectangle.top * pixelRatio).round();
    final rR = (rectangle.right * pixelRatio).round();
    final rB = (rectangle.bottom * pixelRatio).round();
    final ow = this.offsetRectangle.width;
    final oh = this.offsetRectangle.height;
    final sourceRectangle = Rectangle<int>(rL, rT, rR - rL, rB - rT);
    final offsetRectangle = Rectangle<int>(0 - rL, 0 - rT, ow, oh);
    return RenderTextureQuad.slice(this, sourceRectangle, offsetRectangle);
  }

  /// Cuts a RenderTextureQuad out of this RenderTextureQuad. The offset
  /// of the RenderTextureQuad will be adjusted to match the origin of
  /// the [rectangle].
  ///
  /// The [rectangle] is in target coordinates. Those coordinates take the
  /// [pixelRatio] into account. Please read more about HiDpi textures to
  /// learn more about this topic.

  RenderTextureQuad cut(Rectangle<num> rectangle) {
    final rL = (rectangle.left * pixelRatio).round();
    final rT = (rectangle.top * pixelRatio).round();
    final rR = (rectangle.right * pixelRatio).round();
    final rB = (rectangle.bottom * pixelRatio).round();
    final sourceRectangle = Rectangle<int>(rL, rT, rR - rL, rB - rT);
    final offsetRectangle = Rectangle<int>(0, 0, rR - rL, rB - rT);
    return RenderTextureQuad.slice(this, sourceRectangle, offsetRectangle);
  }

  //---------------------------------------------------------------------------

  ImageData createImageData() {
    final rect = sourceRectangle;
    final context = renderTexture.canvas.context2D;
    return context.createImageData(rect.width, rect.height);
  }

  ImageData getImageData() {
    final rect = sourceRectangle;
    final context = renderTexture.canvas.context2D;
    return context.getImageData(rect.left, rect.top, rect.width, rect.height);
  }

  void putImageData(ImageData imageData) {
    final rect = sourceRectangle;
    final context = renderTexture.canvas.context2D;
    context.putImageData(imageData, rect.left, rect.top);
  }
}
