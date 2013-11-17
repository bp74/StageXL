part of stagexl;

class SoundTransform {

  num volume;
  num pan;
  //num leftToLeft = 1;
  //num leftToRight = 0;
  //num rightToRight = 1;
  //num rightToLeft = 0;

  SoundTransform([this.volume = 1, this.pan = 0]);

  SoundTransform.mute():this(0, 0);
}
