library stagexl.errors;

/// An AggregateError contains a list of errors that occur during execution.
class AggregateError extends Error {

  final String message;
  final List<Error> errors = new List<Error>();
  AggregateError(this.message);

  @override
  String toString() {
    var result = "AggregateError: $message";
    errors.forEach((error) => result = "$result | $error");
    return result;
  }
}

/// A LoadError indicates a problem while loading a resource.
class LoadError extends Error {

  final String message;
  final dynamic error;

  LoadError(this.message, [this.error]);

  @override
  String toString() {
    var result = "LoadError: $message";
    if (error != null) result = "$result $error";
    return result;
  }
}
