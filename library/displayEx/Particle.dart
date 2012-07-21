class Particle 
{
  num currentTime;
  num totalTime;
  num x, y;
  num size, sizeDelta;
  num rotation, rotationDelta;
  num startX, startY;
  num velocityX, velocityY;
  num radialAcceleration;
  num tangentialAcceleration;
  num emitRadius, emitRadiusDelta;
  num emitRotation, emitRotationDelta;
  ParticleColor color, colorDelta;
  
  Particle()
  {
    this.color = new ParticleColor();
    this.colorDelta = new ParticleColor();
  }
}
