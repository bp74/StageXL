part of stagexl.resources;

abstract class TextureAtlasFormat {

  static const TextureAtlasFormat JSON = const _TextureAtlasFormatJson();
  static const TextureAtlasFormat JSONARRAY = const _TextureAtlasFormatJson();
  static const TextureAtlasFormat LIBGDX = const _TextureAtlasFormatLibGDX();

  const TextureAtlasFormat();

  Future<TextureAtlas> load(String url, BitmapDataLoadOptions bitmapDataLoadOptions);
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class _TextureAtlasFormatJson extends TextureAtlasFormat {

  const _TextureAtlasFormatJson();

  Future<TextureAtlas> load(String url, BitmapDataLoadOptions bitmapDataLoadOptions) {

    Completer<TextureAtlas> completer = new Completer<TextureAtlas>();
    TextureAtlas textureAtlas = new TextureAtlas();

    HttpRequest.getString(url).then((textureAtlasJson) {

      var data = JSON.decode(textureAtlasJson);
      var frames = data["frames"];
      var meta = data["meta"];
      var imageUrl = replaceFilename(url, meta["image"]);

      if (frames is List) {
        for (var frame in frames) {
          var frameMap = frame as Map;
          var fileName = frameMap["filename"] as String;
          var frameName = getFilenameWithoutExtension(fileName);
          var taf = new TextureAtlasFrame._fromJson(textureAtlas, frameName, frameMap);
          textureAtlas.frames.add(taf);
        }
      }

      if (frames is Map) {
        for(String fileName in frames.keys) {
          var frameMap = frames[fileName] as Map;
          var frameName = getFilenameWithoutExtension(fileName);
          var taf = new TextureAtlasFrame._fromJson(textureAtlas, frameName, frameMap);
          textureAtlas.frames.add(taf);
        }
      }

      if (bitmapDataLoadOptions == null) {
        bitmapDataLoadOptions = BitmapData.defaultLoadOptions;
      }

      var autoHiDpi = bitmapDataLoadOptions.autoHiDpi;
      var webpAvailable = bitmapDataLoadOptions.webp;
      var corsEnabled = bitmapDataLoadOptions.corsEnabled;
      var loader = RenderTexture.load(imageUrl, autoHiDpi, webpAvailable, corsEnabled);

      loader.then((RenderTexture renderTexture) {
        textureAtlas.frames.forEach((f) => f.renderTexture = renderTexture);
        completer.complete(textureAtlas);
      }).catchError((error) {
        completer.completeError(new StateError("Failed to load image."));
      });

    }).catchError((error) {
      completer.completeError(new StateError("Failed to load json file."));
    });

    return completer.future;
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class _TextureAtlasFormatLibGDX extends TextureAtlasFormat {

  const _TextureAtlasFormatLibGDX();

  Future<TextureAtlas> load(String url, BitmapDataLoadOptions bitmapDataLoadOptions) {

    Completer<TextureAtlas> completer = new Completer<TextureAtlas>();
    TextureAtlas textureAtlas = new TextureAtlas();

    RegExp splitRexExp = new RegExp(r"\r\n|\r|\n");
    RegExp dataRexExp = new RegExp(r"^\s*([a-z]+):\s([A-Za-z0-9\s,]+)");
    Map<String, Future> renderTextures = new Map<String, Future>();
    Map<String, List> textureAtlasFrames = new Map<String, List>();

    if (bitmapDataLoadOptions == null) {
      bitmapDataLoadOptions = BitmapData.defaultLoadOptions;
    }

    HttpRequest.getString(url).then((atlasText) {

      var lines = atlasText.split(splitRexExp);
      var lineIndex = 0;

      var imageBlock = true;
      var imageName = "";

      while(lineIndex < lines.length) {

        var line = lines[lineIndex].trim();

        if (line.length == 0) {

          imageBlock = true;
          lineIndex++;

        } else if (imageBlock) {

          imageBlock = false;
          imageName = line;

          while(++lineIndex < lines.length) {

            var imageMatch = dataRexExp.firstMatch(lines[lineIndex]);
            if (imageMatch == null) break;

            // size: 355,139
            // format: RGBA8888
            // filter: Linear,Linear
            // repeat: none
          }

          var autoHiDpi = bitmapDataLoadOptions.autoHiDpi;
          var webpAvailable = bitmapDataLoadOptions.webp;
          var corsEnabled = bitmapDataLoadOptions.corsEnabled;
          var imageUrl = replaceFilename(url, imageName);
          var loader = RenderTexture.load(imageUrl, autoHiDpi, webpAvailable, corsEnabled);

          renderTextures[imageName] = loader;
          textureAtlasFrames[imageName] = new List();

        } else {

          var frameName = line;
          var frameRotation = 0;
          var frameX = 0, frameY = 0;
          var frameWidth = 0, frameHeight = 0;
          var frameOriginalWidth = 0, frameOriginalHeight = 0;
          var frameOffsetX = 0, frameOffsetY = 0;

          while(++lineIndex < lines.length) {

            var frameMatch = dataRexExp.firstMatch(lines[lineIndex]);
            if (frameMatch == null) break;

            var key = frameMatch[1];
            var values = frameMatch[2].split(",").map((s) => s.trim()).toList();

            if (key == "rotate" && values.length == 1) {
              frameRotation = (values[0] == "true") ? 3 : 0;
            } else if (key == "xy" && values.length == 2) {
              frameX = int.parse(values[0]);
              frameY = int.parse(values[1]);
            } else if (key == "size" && values.length == 2) {
              frameWidth = int.parse(values[0]);
              frameHeight = int.parse(values[1]);
            } else if (key == "orig" && values.length == 2) {
              frameOriginalWidth = int.parse(values[0]);
              frameOriginalHeight = int.parse(values[1]);
            } else if (key == "offset" && values.length == 2) {
              frameOffsetX = int.parse(values[0]);
              frameOffsetY = int.parse(values[1]);
            }
          }

          var taf = new TextureAtlasFrame(textureAtlas, frameName, frameRotation,
              frameOriginalWidth, frameOriginalHeight, frameOffsetX, frameOffsetY,
              frameX, frameY, frameWidth, frameHeight);

          textureAtlasFrames[imageName].add(taf);
        }
      }

      Future.wait(renderTextures.values).then((result) {
        renderTextures.forEach((imageName, Future<RenderTexture> future) {
          future.then((renderTexture) => textureAtlasFrames[imageName].forEach((frame) {
            frame.renderTexture = renderTexture;
            textureAtlas.frames.add(frame);
          }));
        });
        completer.complete(textureAtlas);
      }).catchError((error) {
        completer.completeError(new StateError("Failed to load image."));
      });

    }).catchError((error) {
      completer.completeError(new StateError("Failed to load atlas file."));
    });

    return completer.future;
  }
}
