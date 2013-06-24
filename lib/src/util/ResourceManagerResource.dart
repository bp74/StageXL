part of stagexl;

class ResourceManagerResource {

  String _kind;
  String _name;
  String _url;
  dynamic _error;
  dynamic _resource;
  Completer _completer;

  ResourceManagerResource(String kind, String name, String url, Future loader) {
    _kind = kind;
    _name = name;
    _url = url;
    _resource = null;
    _error = null;
    _completer = new Completer();

    loader.then((resource) {
      _resource = resource;
    }).catchError((error) {
      _error = error;
    }).whenComplete(() {
      _completer.complete(this);
    });
  }

  String toString() => "ResourceManagerResource [kind=${_kind}, name=${_name}, url = ${_url}]";

  //-----------------------------------------------------------------------------------------------

  String get kind => _kind;
  String get name => _name;
  String get url => _url;

  dynamic get resource => _resource;
  dynamic get error => _error;

  Future get complete => _completer.future;
}

