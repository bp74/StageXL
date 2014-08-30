part of stagexl.events;

class KeyLocation {

  final String name;
  const KeyLocation(this.name);

  static const KeyLocation STANDARD = const KeyLocation("STANDARD");
  static const KeyLocation LEFT = const KeyLocation("LEFT");
  static const KeyLocation RIGHT = const KeyLocation("RIGHT");
  static const KeyLocation NUM_PAD = const KeyLocation("NUM_PAD");
  static const KeyLocation D_PAD = const KeyLocation("D_PAD");
}
