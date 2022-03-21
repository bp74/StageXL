part of stagexl.resources;

class _TextureAtlasFormatJson extends TextureAtlasFormat {
  const _TextureAtlasFormatJson();

  @override
  Future<TextureAtlas> load(TextureAtlasLoader loader) async {
    final source = await loader.getSource();
    final pixelRatio = loader.getPixelRatio();
    final textureAtlas = TextureAtlas(pixelRatio);

    final json = jsonDecode(source) as Map;
    final frames = json['frames'];
    final meta = json['meta'] as Map;
    final image = meta['image'] as String;
    final renderTextureQuad = await loader.getRenderTextureQuad(image);

    //  Set texture info based on meta format
    _setTextureFormat(renderTextureQuad.renderTexture, meta['format'] as String);

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

  void _setTextureFormat(RenderTexture texture, String format) {
    switch (format) {
      case 'RGBA8888':
        texture.pixelFormat = gl.WebGL.RGBA;
        texture.pixelType = gl.WebGL.UNSIGNED_BYTE;
        break;

      case 'RGBA4444':
        texture.pixelFormat = gl.WebGL.RGBA;
        texture.pixelType = gl.WebGL.UNSIGNED_SHORT_4_4_4_4;
        break;

      case 'RGBA5551':
        texture.pixelFormat = gl.WebGL.RGBA;
        texture.pixelType = gl.WebGL.UNSIGNED_SHORT_5_5_5_1;
        break;

      case 'RGB888':
        texture.pixelFormat = gl.WebGL.RGB;
        texture.pixelType = gl.WebGL.UNSIGNED_BYTE;
        break;

      case 'RGB565':
        texture.pixelFormat = gl.WebGL.RGB;
        texture.pixelType = gl.WebGL.UNSIGNED_SHORT_5_6_5;
        break;

      case 'ALPHA':
        texture.pixelFormat = gl.WebGL.ALPHA;
        texture.pixelType = gl.WebGL.UNSIGNED_SHORT_4_4_4_4;
        break;

      case 'ALPHA_INTENSITY':
        texture.pixelFormat = gl.WebGL.LUMINANCE_ALPHA;
        texture.pixelType = gl.WebGL.UNSIGNED_SHORT_4_4_4_4;
        break;
    }
  }

  //---------------------------------------------------------------------------

  void _createFrame(
      TextureAtlas textureAtlas,
      RenderTextureQuad renderTextureQuad,
      String frameName,
      Map frameMap,
      Map metaMap) {
    final rotation = (frameMap['rotated'] as bool? ?? false) ? 1 : 0;

    final spriteSourceSize = frameMap['spriteSourceSize'] as Map;
    final offsetX = spriteSourceSize['x'] as int;
    final offsetY = spriteSourceSize['y'] as int;

    final sourceSize = frameMap['sourceSize'] as Map;
    final originalWidth = sourceSize['w'] as int;
    final originalHeight = sourceSize['h'] as int;

    final frame = frameMap['frame'] as Map;
    final frameX = frame['x'] as int;
    final frameY = frame['y'] as int;
    final frameWidth = frame[rotation == 0 ? 'w' : 'h'] as int;
    final frameHeight = frame[rotation == 0 ? 'h' : 'w'] as int;

    Float32List? vxList;
    Int16List? ixList;

    if (frameMap.containsKey('vertices')) {
      final vertices = frameMap['vertices'] as List;
      final verticesUV = frameMap['verticesUV'] as List;
      final triangles = frameMap['triangles'] as List;

      final size = metaMap['size'] as Map;
      final width = (size['w'] as num).toInt();
      final height = (size['h'] as num).toInt();

      vxList = Float32List(vertices.length * 4);
      ixList = Int16List(triangles.length * 3);

      for (var i = 0, j = 0; i <= vxList.length - 4; i += 4, j += 1) {
        final vj = vertices[j] as List;
        vxList[i + 0] = (vj[0] as num).toDouble();
        vxList[i + 1] = (vj[1] as num).toDouble();

        final vuvj = verticesUV[j] as List;
        vxList[i + 2] = (vuvj[0] as num) / width;
        vxList[i + 3] = (vuvj[1] as num) / height;
      }

      for (var i = 0, j = 0; i <= ixList.length - 3; i += 3, j += 1) {
        final tj = triangles[j] as List;
        ixList[i + 0] = tj[0] as int;
        ixList[i + 1] = tj[1] as int;
        ixList[i + 2] = tj[2] as int;
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
