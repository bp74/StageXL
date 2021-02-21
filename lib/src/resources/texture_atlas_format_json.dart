part of stagexl.resources;

class _TextureAtlasFormatJson extends TextureAtlasFormat {
  const _TextureAtlasFormatJson();

  @override
  Future<TextureAtlas> load(TextureAtlasLoader loader) async {
    final source = await loader.getSource();
    final pixelRatio = loader.getPixelRatio();
    final textureAtlas = TextureAtlas(pixelRatio);

    final json = jsonDecode(source);
    final frames = json['frames'];
    final meta = json['meta'] as Map;
    final image = meta['image'] as String;
    final renderTextureQuad = await loader.getRenderTextureQuad(image);

    if (frames is List) {
      for (var frame in frames) {
        final frameMap = frame as Map;
        final fileName = frameMap['filename'] as String;
        final frameName = getFilenameWithoutExtension(fileName);
        _createFrame(
            textureAtlas, renderTextureQuad, frameName, frameMap, meta);
      }
    }

    if (frames is Map) {
      for (var fileName in frames.keys as Iterable<String>) {
        final frameMap = frames[fileName] as Map;
        final frameName = getFilenameWithoutExtension(fileName);
        _createFrame(
            textureAtlas, renderTextureQuad, frameName, frameMap, meta);
      }
    }

    return textureAtlas;
  }

  //---------------------------------------------------------------------------

  void _createFrame(
      TextureAtlas textureAtlas,
      RenderTextureQuad renderTextureQuad,
      String frameName,
      Map frameMap,
      Map metaMap) {
    final rotation = (frameMap['rotated'] as bool? ?? false) ? 1 : 0;
    final offsetX = frameMap['spriteSourceSize']['x'] as int;
    final offsetY = frameMap['spriteSourceSize']['y'] as int;
    final originalWidth = frameMap['sourceSize']['w'] as int;
    final originalHeight = frameMap['sourceSize']['h'] as int;
    final frameX = frameMap['frame']['x'] as int;
    final frameY = frameMap['frame']['y'] as int;
    final frameWidth = frameMap['frame'][rotation == 0 ? 'w' : 'h'] as int;
    final frameHeight = frameMap['frame'][rotation == 0 ? 'h' : 'w'] as int;

    Float32List? vxList;
    Int16List? ixList;

    if (frameMap.containsKey('vertices')) {
      final vertices = frameMap['vertices'] as List;
      final verticesUV = frameMap['verticesUV'] as List;
      final triangles = frameMap['triangles'] as List;
      final width = (metaMap['size']['w'] as num).toInt();
      final height = (metaMap['size']['h'] as num).toInt();

      vxList = Float32List(vertices.length * 4);
      ixList = Int16List(triangles.length * 3);

      for (var i = 0, j = 0; i <= vxList.length - 4; i += 4, j += 1) {
        vxList[i + 0] = (vertices[j][0] as num).toDouble();
        vxList[i + 1] = (vertices[j][1] as num).toDouble();
        vxList[i + 2] = (verticesUV[j][0] as num) / width;
        vxList[i + 3] = (verticesUV[j][1] as num) / height;
      }

      for (var i = 0, j = 0; i <= ixList.length - 3; i += 3, j += 1) {
        ixList[i + 0] = triangles[j][0] as int;
        ixList[i + 1] = triangles[j][1] as int;
        ixList[i + 2] = triangles[j][2] as int;
      }
    }

    final taf = TextureAtlasFrame(
        textureAtlas,
        renderTextureQuad,
        frameName,
        rotation,
        offsetX,
        offsetY,
        originalWidth,
        originalHeight,
        frameX,
        frameY,
        frameWidth,
        frameHeight,
        vxList,
        ixList);

    textureAtlas.frames.add(taf);
  }
}
