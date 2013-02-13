part of dartflash;

class ResourceManagerResource {
  String _kind;
  String _name;
  String _url;
  Future _loader;
  
  dynamic _error;
  dynamic _resource;
  
  ResourceManagerResource(String kind, String name, String url) {
    _kind = kind;
    _name = name;
    _url = url;
    _error = null;
    _resource = null;
  }
  
  //-----------------------------------------------------------------------------------------------
  
  String get kind => _kind;
  String get name => _name;
  String get url => _url;
  
  dynamic get resource => _resource;
  dynamic get error => _error;

  //-----------------------------------------------------------------------------------------------
  
  _load(Future loader) {
    
    _loader = loader.then((value) {
      _resource = value;
      _error = null;
    }, onError: (AsyncError error) {
      _resource = null;
     _error = error.error;
    });
  }
}

