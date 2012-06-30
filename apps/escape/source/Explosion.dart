class ExplosionParticle
{
  Bitmap bitmap;
  num startX;
  num startY;
  num angle;
  num velocity;
  num rotation;
}

class Explosion extends Sprite implements IAnimatable
{
  List<ExplosionParticle> _particles;
  num _currentTime;

  Explosion(int color, int direction)
  {
    _particles = new List<ExplosionParticle>();
    _currentTime = 0.0;

    this.mouseEnabled = false;

    Bitmap chain = Grafix.getChain(color, direction);

    num angle;
    num velocity;
    num rotation;

    for(int y = 0; y <= 1; y++)
    {
      for(int x = 0; x <= 1; x++)
      {
        if (x == 0 && y == 0) { angle = Math.PI * 1.15; rotation = - Math.PI * 2; }
        if (x == 1 && y == 0) { angle = Math.PI * 1.85; rotation = Math.PI * 2; }
        if (x == 1 && y == 1) { angle = Math.PI * 0.15; rotation = Math.PI * 2; }
        if (x == 0 && y == 1) { angle = Math.PI * 0.85; rotation = - Math.PI * 2; }

        angle = angle + 0.2 * Math.PI * Math.random();
        velocity = 80.0 + 40.0 * Math.random();

        Bitmap bitmap = new Bitmap(chain.bitmapData);
        bitmap.clipRectangle = new Rectangle(x * 25, y * 25, 25, 25);
        bitmap.pivotX = 12.5 + x * 25;
        bitmap.pivotY = 12.5 + y * 25;
        bitmap.x = x * 25;
        bitmap.y = y * 25;
        addChild(bitmap);

        ExplosionParticle particle = new ExplosionParticle();
        particle.bitmap = bitmap;
        particle.startX = x * 25 + 12.5;
        particle.startY = y * 25 + 12.5;
        particle.angle = angle;
        particle.velocity = velocity;
        particle.rotation = rotation;

        _particles.add(particle);
      }
    }
  }

  //----------------------------------------------------------------------------------------------------------

  bool advanceTime(num time)
  {
    _currentTime = Math.min(0.8, _currentTime + time);

    num gravity = 981.0;

    for(int i = 0; i < _particles.length; i++)
    {
      ExplosionParticle particle = _particles[i];

      Bitmap bitmap = particle.bitmap;
      num angle = particle.angle;
      num velocity = particle.velocity;
      num rotation = particle.rotation;

      num posX = particle.startX + _currentTime * (Math.cos(angle) * velocity);
      num posY = particle.startY + _currentTime * (Math.sin(angle) * velocity + _currentTime * gravity * 0.5);

      bitmap.x = posX;
      bitmap.y = posY;
      bitmap.rotation = _currentTime * rotation;
    }

    if (_currentTime >= 0.6)
      this.alpha = (0.8 - _currentTime) / 0.2;

    if (_currentTime >= 0.8)
      this.removeFromParent();

    return (_currentTime < 0.8);
  }

}