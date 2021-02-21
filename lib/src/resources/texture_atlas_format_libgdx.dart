part of stagexl.resources;

class _TextureAtlasFormatLibGDX extends TextureAtlasFormat {
  const _TextureAtlasFormatLibGDX();

  @override
  Future<TextureAtlas> load(TextureAtlasLoader loader) async {
    final source = await loader.getSource();
    final pixelRatio = loader.getPixelRatio();
    final textureAtlas = TextureAtlas(pixelRatio);

    final splitRexExp = RegExp(r'\r\n|\r|\n');
    final dataRexExp = RegExp(r'^\s*([a-z]+):\s([A-Za-z0-9\s,]+)');

    final lines = source.split(splitRexExp);
    var lineIndex = 0;
    var imageBlock = true;
    RenderTextureQuad? renderTextureQuad;

    //-----------------------------------------------------

    while (lineIndex < lines.length) {
      final line = lines[lineIndex].trim();

      if (line.isEmpty) {
        imageBlock = true;
        lineIndex++;
      } else if (imageBlock) {
        imageBlock = false;
        renderTextureQuad = await loader.getRenderTextureQuad(line);

        while (++lineIndex < lines.length) {
          final imageMatch = dataRexExp.firstMatch(lines[lineIndex]);
          if (imageMatch == null) break;
          // size: 355,139
          // format: RGBA8888
          // filter: Linear,Linear
          // repeat: none
        }
      } else {
        final frameName = line;
        var frameRotation = 0;
        var frameX = 0, frameY = 0;
        var frameWidth = 0, frameHeight = 0;
        var originalWidth = 0, originalHeight = 0;
        var offsetX = 0, offsetY = 0;

        while (++lineIndex < lines.length) {
          final frameMatch = dataRexExp.firstMatch(lines[lineIndex]);
          if (frameMatch == null) break;

          final key = frameMatch[1];
          final values =
              frameMatch[2]!.split(',').map((s) => s.trim()).toList();

          if (key == 'rotate' && values.length == 1) {
            frameRotation = (values[0] == 'true') ? 3 : 0;
          } else if (key == 'xy' && values.length == 2) {
            frameX = int.parse(values[0]);
            frameY = int.parse(values[1]);
          } else if (key == 'size' && values.length == 2) {
            frameWidth = int.parse(values[frameRotation == 0 ? 0 : 1]);
            frameHeight = int.parse(values[frameRotation == 0 ? 1 : 0]);
          } else if (key == 'orig' && values.length == 2) {
            originalWidth = int.parse(values[0]);
            originalHeight = int.parse(values[1]);
          } else if (key == 'offset' && values.length == 2) {
            offsetX = int.parse(values[0]);
            offsetY = int.parse(values[1]);
          }
        }

        final textureAtlasFrame = TextureAtlasFrame(
            textureAtlas,
            renderTextureQuad!,
            frameName,
            frameRotation,
            offsetX,
            offsetY,
            originalWidth,
            originalHeight,
            frameX,
            frameY,
            frameWidth,
            frameHeight,
            null,
            null);

        textureAtlas.frames.add(textureAtlasFrame);
      }
    }

    return textureAtlas;
  }
}
