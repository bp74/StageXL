part of stagexl.resources;

class ResourceManager {

  final Map<String, ResourceManagerResource> _resourceMap =
      new Map<String, ResourceManagerResource>();

  final _progressEvent = new StreamController<num>.broadcast();
  Stream<num> get onProgress => _progressEvent.stream;

  //-----------------------------------------------------------------------------------------------

  bool _containsResource(String kind, String name) {
    var key = "$kind.$name";
    return _resourceMap.containsKey(key);
  }

  ResourceManagerResource _removeResource(String kind, String name) {
    var key = "$kind.$name";
    return _resourceMap.remove(key);
  }

  void _addResource(String kind, String name, String url, Future loader) {

    var key = "$kind.$name";
    var resource = new ResourceManagerResource(kind, name, url, loader);

    if (_resourceMap.containsKey(key)) {
      throw new StateError("ResourceManager already contains a resource called '$name'");
    } else {
      _resourceMap[key] = resource;
    }

    resource.complete.then((_) {
      var finished = this.finishedResources.length;
      var progress = finished / _resourceMap.length;
      _progressEvent.add(progress);
    });
  }

  dynamic _getResourceValue(String kind, String name) {

    var key = "$kind.$name";
    var resource = _resourceMap[key];

    if (resource == null) {
      throw new StateError("Resource '$name' does not exist.");
    } else if (resource.value != null) {
      return resource.value;
    } else if (resource.error != null) {
      throw resource.error;
    } else {
      throw new StateError("Resource '$name' has not finished loading yet.");
    }
  }

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  Future<ResourceManager> load() async {
    var futures = this.pendingResources.map((r) => r.complete);
    await Future.wait(futures);
    var errors = this.failedResources.length;
    if (errors > 0) {
      throw new StateError("Failed to load $errors resource(s).");
    } else {
      return this;
    }
  }

  void dispose() {
    for (var resource in _resourceMap.values.toList(growable: false)) {
      if (resource.kind == "BitmapData") {
        this.removeBitmapData(resource.name, dispose: true);
      } else {
        _removeResource(resource.kind, resource.name);
      }
    }
  }

  //-----------------------------------------------------------------------------------------------

  List<ResourceManagerResource> get finishedResources {
    return _resourceMap.values.where((r) => r.value != null).toList();
  }

  List<ResourceManagerResource> get pendingResources {
    return _resourceMap.values.where((r) => r.value == null && r.error == null).toList();
  }

  List<ResourceManagerResource> get failedResources {
    return _resourceMap.values.where((r) => r.error != null).toList();
  }

  List<ResourceManagerResource> get resources {
    return _resourceMap.values.toList();
  }

  //-----------------------------------------------------------------------------------------------

  bool containsBitmapData(String name) => _containsResource("BitmapData", name);
  bool containsSound(String name) => _containsResource("Sound", name);
  bool containsVideo(String name) => _containsResource("Video", name);
  bool containsSoundSprite(String name) => _containsResource("SoundSprite", name);
  bool containsTextureAtlas(String name) => _containsResource("TextureAtlas", name);
  bool containsTextFile(String name) => _containsResource("TextFile", name);
  bool containsText(String name) => _containsResource("Text", name);
  bool containsCustomObject(String name) => _containsResource("CustomObject", name);

  //-----------------------------------------------------------------------------------------------

  void addBitmapData(String name, String url, [BitmapDataLoadOptions bitmapDataLoadOptions = null]) {
    _addResource("BitmapData", name, url, BitmapData.load(url, bitmapDataLoadOptions));
  }

  void addSound(String name, String url, [SoundLoadOptions soundLoadOptions = null]) {
    _addResource("Sound", name, url, Sound.load(url, soundLoadOptions));
  }

  void addVideo(String name, String url, [VideoLoadOptions videoLoadOptions = null]) {
    _addResource("Video", name, url, Video.load(url, videoLoadOptions));
  }

  void addSoundSprite(String name, String url) {
    _addResource("SoundSprite", name, url, SoundSprite.load(url));
  }

  void addTextureAtlas(String name, String url, [
      TextureAtlasFormat textureAtlasFormat = TextureAtlasFormat.JSONARRAY,
      BitmapDataLoadOptions bitmapDataLoadOptions = null]) {

    _addResource("TextureAtlas", name, url,
        TextureAtlas.load(url, textureAtlasFormat, bitmapDataLoadOptions));
  }

  void addTextFile(String name, String url) {
    _addResource("TextFile", name, url,
        HttpRequest.getString(url).then((text) => text, onError: (error) {
          throw new StateError("Failed to load text file.");
        }));
  }

  void addText(String name, String text) {
    _addResource("Text", name, "", new Future.value(text));
  }

  void addCustomObject(String name, Future loader) {
    _addResource("CustomObject", name, "", loader);
  }

  //-----------------------------------------------------------------------------------------------

  void removeBitmapData(String name, {bool dispose:true}) {
    var resourceManagerResource = _removeResource("BitmapData", name);
    var bitmapData = resourceManagerResource?.value;
    if (bitmapData is BitmapData && dispose) {
      bitmapData.renderTexture.dispose();
    }
  }

  void removeSound(String name) {
    _removeResource("Sound", name);
  }

  void removeVideo(String name) {
    _removeResource("Video", name);
  }

  void removeSoundSprite(String name) {
    _removeResource("SoundSprite", name);
  }

  void removeTextureAtlas(String name) {
    _removeResource("TextureAtlas", name);
  }

  void removeTextFile(String name) {
    _removeResource("TextFile", name);
  }

  void removeText(String name) {
    _removeResource("Text", name);
  }

  void removeCustomObject(String name) {
    _removeResource("CustomObject", name);
  }

  //-----------------------------------------------------------------------------------------------

  BitmapData getBitmapData(String name) {
    var value = _getResourceValue("BitmapData", name);
    if (value is! BitmapData) throw "dart2js_hint";
    return value;
  }

  Sound getSound(String name) {
    var value = _getResourceValue("Sound", name);
    if (value is! Sound) throw "dart2js_hint";
    return value;
  }

  Video getVideo(String name) {
    var value = _getResourceValue("Video", name);
    if (value is! Video) throw "dart2js_hint";
    return value;
  }

  SoundSprite getSoundSprite(String name) {
    var value = _getResourceValue("SoundSprite", name);
    if (value is! SoundSprite) throw "dart2js_hint";
    return value;
  }

  TextureAtlas getTextureAtlas(String name) {
    var value = _getResourceValue("TextureAtlas", name);
    if (value is! TextureAtlas) throw "dart2js_hint";
    return value;
  }

  String getTextFile(String name) {
    var value = _getResourceValue("TextFile", name);
    if (value is! String) throw "dart2js_hint";
    return value;
  }

  String getText(String name) {
    var value = _getResourceValue("Text", name);
    if (value is! String) throw "dart2js_hint";
    return value;
  }

  dynamic getCustomObject(String name) {
    return _getResourceValue("CustomObject", name);
  }

}
