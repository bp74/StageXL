// ignore_for_file: library_private_types_in_public_api

part of '../../drawing.dart';

class _GraphicsContextRender extends _GraphicsContextBase {
  final RenderState renderState;

  _GraphicsContextRender(this.renderState);

  //---------------------------------------------------------------------------

  @override
  void fillColor(int color) {
    final _GraphicsMesh mesh = _path;
    mesh.fillColor(renderState, color);
  }

  @override
  void fillGradient(GraphicsGradient gradient) {
    final _GraphicsMesh mesh = _path;
    mesh.fillGradient(renderState, gradient);
  }

  @override
  void fillPattern(GraphicsPattern pattern) {
    final _GraphicsMesh mesh = _path;
    mesh.fillPattern(renderState, pattern);
  }

  @override
  void strokeColor(
      int color, double width, JointStyle jointStyle, CapsStyle capsStyle) {
    final _GraphicsMesh mesh =
        _GraphicsStroke(_path, width, jointStyle, capsStyle);
    mesh.fillColor(renderState, color);
  }

  @override
  void strokeGradient(GraphicsGradient gradient, double width,
      JointStyle jointStyle, CapsStyle capsStyle) {
    final _GraphicsMesh mesh =
        _GraphicsStroke(_path, width, jointStyle, capsStyle);
    mesh.fillGradient(renderState, gradient);
  }

  @override
  void strokePattern(GraphicsPattern pattern, double width,
      JointStyle jointStyle, CapsStyle capsStyle) {
    final _GraphicsMesh mesh =
        _GraphicsStroke(_path, width, jointStyle, capsStyle);
    mesh.fillPattern(renderState, pattern);
  }

  @override
  void meshColor(_GraphicsCommandMeshColor command) {
    final mesh = command.mesh;
    mesh.fillColor(renderState, command.color);
  }

  @override
  void meshGradient(_GraphicsCommandMeshGradient command) {
    final mesh = command.mesh;
    mesh.fillGradient(renderState, command.gradient);
  }

  @override
  void meshPattern(_GraphicsCommandMeshPattern command) {
    final mesh = command.mesh;
    mesh.fillPattern(renderState, command.pattern);
  }
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

class GraphicsContextRenderMask extends _GraphicsContextRender {
  GraphicsContextRenderMask(super.renderState);

  @override
  void fillColor(int color) {
    final _GraphicsMesh mesh = _path;
    mesh.fillColor(renderState, 0xFFFF00FF);
  }

  @override
  void fillGradient(GraphicsGradient gradient) {
    final _GraphicsMesh mesh = _path;
    mesh.fillColor(renderState, 0xFFFF00FF);
  }

  @override
  void fillPattern(GraphicsPattern pattern) {
    final _GraphicsMesh mesh = _path;
    mesh.fillColor(renderState, 0xFFFF00FF);
  }

  @override
  void strokeColor(
      int color, double width, JointStyle jointStyle, CapsStyle capsStyle) {
    // do nothing
  }

  @override
  void strokeGradient(GraphicsGradient gradient, double width,
      JointStyle jointStyle, CapsStyle capsStyle) {
    // do nothing
  }

  @override
  void strokePattern(GraphicsPattern pattern, double width,
      JointStyle jointStyle, CapsStyle capsStyle) {
    // do nothing
  }

  @override
  void meshColor(_GraphicsCommandMeshColor command) {
    final mesh = command.mesh;
    if (mesh is _GraphicsStroke) return;
    mesh.fillColor(renderState, 0xFFFF00FF);
  }

  @override
  void meshGradient(_GraphicsCommandMeshGradient command) {
    final mesh = command.mesh;
    if (mesh is _GraphicsStroke) return;
    mesh.fillColor(renderState, 0xFFFF00FF);
  }

  @override
  void meshPattern(_GraphicsCommandMeshPattern command) {
    final mesh = command.mesh;
    if (mesh is _GraphicsStroke) return;
    mesh.fillColor(renderState, 0xFFFF00FF);
  }
}
