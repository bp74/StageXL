part of stagexl.events;

class KeyLocation {

  final int _ordinal;
  const KeyLocation._(this._ordinal);

  static const KeyLocation STANDARD = const KeyLocation._(0);
  static const KeyLocation LEFT = const KeyLocation._(1);
  static const KeyLocation RIGHT = const KeyLocation._(2);
  static const KeyLocation NUM_PAD = const KeyLocation._(3);
  static const KeyLocation D_PAD = const KeyLocation._(4);
}
