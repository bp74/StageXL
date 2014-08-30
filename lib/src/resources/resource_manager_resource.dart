part of stagexl.resources;

class ResourceManagerResource {

  final String kind;
  final String name;
  final String url;
  dynamic _value = null;
  dynamic _error = null;
  final Completer _completer = new Completer();

  ResourceManagerResource(this.kind, this.name, this.url, Future loader) {

    loader.then((resource) {
      _value = resource;
    }).catchError((error) {
      _error = error;
    }).whenComplete(() {
      _completer.complete(this);
    });
  }

  String toString() => "ResourceManagerResource [kind=${kind}, name=${name}, url = ${url}]";

  //-----------------------------------------------------------------------------------------------

  dynamic get value => _value;
  dynamic get error => _error;

  Future get complete => _completer.future;
}
