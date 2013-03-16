part of dartflash;

/*
 * Please use the new FlipBook class.
 */
@deprecated
class MovieClip extends FlipBook {
  
  MovieClip(List<BitmapData> bitmapDatas, [int frameRate = 30, bool loop = true]):
    super(bitmapDatas, frameRate, loop);
}
