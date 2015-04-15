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

  Future<TextureAtlas> load(String url, BitmapDataLoadOptions bitmapDataLoadOptions) async {

    if (bitmapDataLoadOptions == null) {
      bitmapDataLoadOptions = BitmapData.defaultLoadOptions;
    }

    var pixelRatio = 1.0;
    var pixelRatioRegexp = new RegExp(r"@(\d)x");
    var pixelRatioMatch = pixelRatioRegexp.firstMatch(url);
    var maxPixelRatio = bitmapDataLoadOptions.maxPixelRatio;
    var webpAvailable = bitmapDataLoadOptions.webp;
    var corsEnabled = bitmapDataLoadOptions.corsEnabled;

    if (pixelRatioMatch != null) {
      var match = pixelRatioMatch;
      var originPixelRatio = int.parse(match.group(1));
      var devicePixelRatio = env.devicePixelRatio.round();
      var loaderPixelRatio = minInt(devicePixelRatio, maxPixelRatio);
      pixelRatio = loaderPixelRatio / originPixelRatio;
      url = url.replaceRange(match.start, match.end, "@${loaderPixelRatio}x");
    }

    var json = await HttpRequest.getString(url);
    var data = JSON.decode(json);
    var frames = data["frames"];
    var meta = data["meta"];

    var imageUrl = replaceFilename(url, meta["image"]);
    var imageLoader = new ImageLoader(imageUrl, webpAvailable, corsEnabled);
    var imageElement = await imageLoader.done;
    var renderTexture = new RenderTexture.fromImageElement(imageElement);
    var textureAtlas = new TextureAtlas();

    if (frames is List) {
      for (var frame in frames) {
        var frameMap = frame as Map;
        var fileName = frameMap["filename"] as String;
        var frameName = getFilenameWithoutExtension(fileName);
        var taf = _createFrame(textureAtlas, pixelRatio, frameName, frameMap);
        textureAtlas.frames.add(taf..renderTexture = renderTexture);
      }
    }

    if (frames is Map) {
      for(String fileName in frames.keys) {
        var frameMap = frames[fileName] as Map;
        var frameName = getFilenameWithoutExtension(fileName);
        var taf = _createFrame(textureAtlas, pixelRatio, frameName, frameMap);
        textureAtlas.frames.add(taf..renderTexture = renderTexture);
      }
    }

    return textureAtlas;
  }

  TextureAtlasFrame _createFrame(TextureAtlas texturAtlas, num pixelRatio,
                                 String frameName, Map frameMap) {

    int rotation = ensureBool(frameMap["rotated"]) ? 1 : 0;
    int offsetX = ensureInt(frameMap["spriteSourceSize"]["x"]);
    int offsetY = ensureInt(frameMap["spriteSourceSize"]["y"]);
    int originalWidth = ensureInt(frameMap["sourceSize"]["w"]);
    int originalHeight = ensureInt(frameMap["sourceSize"]["h"]);
    int frameX = ensureInt(frameMap["frame"]["x"]);
    int frameY = ensureInt(frameMap["frame"]["y"]);
    int frameWidth = ensureInt(frameMap["frame"][rotation == 0 ? "w" : "h"]);
    int frameHeight = ensureInt(frameMap["frame"][rotation == 0 ? "h" : "w"]);

    return new TextureAtlasFrame(
        texturAtlas, frameName, rotation, pixelRatio,
        offsetX, offsetY, originalWidth, originalHeight,
        frameX, frameY, frameWidth, frameHeight);
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class _TextureAtlasFormatLibGDX extends TextureAtlasFormat {

  const _TextureAtlasFormatLibGDX();

  Future<TextureAtlas> load(String url, BitmapDataLoadOptions bitmapDataLoadOptions) async {

    if (bitmapDataLoadOptions == null) {
      bitmapDataLoadOptions = BitmapData.defaultLoadOptions;
    }

    var pixelRatio = 1.0;
    var pixelRatioRegexp = new RegExp(r"@(\d)x");
    var pixelRatioMatch = pixelRatioRegexp.firstMatch(url);
    var maxPixelRatio = bitmapDataLoadOptions.maxPixelRatio;
    var webpAvailable = bitmapDataLoadOptions.webp;
    var corsEnabled = bitmapDataLoadOptions.corsEnabled;

    if (pixelRatioMatch != null) {
      var match = pixelRatioMatch;
      var originPixelRatio = int.parse(match.group(1));
      var devicePixelRatio = env.devicePixelRatio.round();
      var loaderPixelRatio = minInt(devicePixelRatio, maxPixelRatio);
      pixelRatio = loaderPixelRatio / originPixelRatio;
      url = url.replaceRange(match.start, match.end, "@${loaderPixelRatio}x");
    }

    RegExp splitRexExp = new RegExp(r"\r\n|\r|\n");
    RegExp dataRexExp = new RegExp(r"^\s*([a-z]+):\s([A-Za-z0-9\s,]+)");
    Map<String, Future> imageElementFutures = new Map<String, Future>();
    Map<String, List> textureAtlasFrames = new Map<String, List>();
    TextureAtlas textureAtlas = new TextureAtlas();

    var atlasText = await HttpRequest.getString(url);
    var lines = atlasText.split(splitRexExp);
    var lineIndex = 0;
    var imageBlock = true;
    var imageName = "";

    //-----------------------------------------------------

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

        var imageUrl = replaceFilename(url, imageName);
        var imageLoader = new ImageLoader(imageUrl, webpAvailable, corsEnabled);
        imageElementFutures[imageName] = imageLoader.done;
        textureAtlasFrames[imageName] = new List();

      } else {

        var frameName = line;
        var frameRotation = 0;
        var frameX = 0, frameY = 0;
        var frameWidth = 0, frameHeight = 0;
        var originalWidth = 0, originalHeight = 0;
        var offsetX = 0, offsetY = 0;

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
            frameWidth = int.parse(values[frameRotation == 0 ? 0 : 1]);
            frameHeight = int.parse(values[frameRotation == 0 ? 1 : 0]);
          } else if (key == "orig" && values.length == 2) {
            originalWidth = int.parse(values[0]);
            originalHeight = int.parse(values[1]);
          } else if (key == "offset" && values.length == 2) {
            offsetX = int.parse(values[0]);
            offsetY = int.parse(values[1]);
          }
        }

        var taf = new TextureAtlasFrame(
            textureAtlas, frameName, frameRotation, pixelRatio,
            offsetX, offsetY, originalWidth, originalHeight,
            frameX, frameY, frameWidth, frameHeight);

        textureAtlasFrames[imageName].add(taf);
        textureAtlas.frames.add(taf);
      }
    }

    //-----------------------------------------------------

    for(var imageName in imageElementFutures.keys) {
      var imageElement = await imageElementFutures[imageName];
      var renderTexture = new RenderTexture.fromImageElement(imageElement);
      for(var textureAtlasFrame in textureAtlasFrames[imageName]) {
        textureAtlasFrame.renderTexture = renderTexture;
      }
    }

    return textureAtlas;
  }
}
