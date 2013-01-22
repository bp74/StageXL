part of dartflash;

//-------------------------------------------------------------------------------------------------
// Credits to www.gamua.com
// Particle System Extension for the Starling framework
// The original code was release under the Simplified BSD License
// http://wiki.starling-framework.org/extensions/particlesystem
//-------------------------------------------------------------------------------------------------

class _ParticleColor
{
  num red, green, blue, alpha;

  _ParticleColor([this.red = 0.0, this.green = 0.0, this.blue = 0.0, this.alpha = 0.0]);

  _ParticleColor.fromJSON(Map json)
  {
    this.red = json["red"] as num;
    this.green = json["green"] as num;
    this.blue = json["blue"] as num;
    this.alpha = json["alpha"] as num;
  }
}

class _Particle
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
  //_ParticleColor color, colorDelta;
}

class ParticleSystem extends DisplayObject implements Animatable
{
  Random _random;
  List<_Particle> _particles;
  int _particleCount;
  CanvasElement _particleCanvas;
  num _frameTime;
  num _emissionTime;

  static const int EMITTER_TYPE_GRAVITY = 0;
  static const int EMITTER_TYPE_RADIAL = 1;

  // emitter configuration
  int emitterType;
  num emitterX, emitterY;
  num emitterXVariance, emitterYVariance;

  // particle configuration
  int maxNumParticles;
  num lifespan, lifespanVariance;
  num startSize, startSizeVariance;
  num endSize, endSizeVariance;
  num emitAngle, emitAngleVariance;

  // gravity configuration
  num gravityX, gravityY;
  num speed, speedVariance;
  num radialAcceleration, radialAccelerationVariance;
  num tangentialAcceleration, tangentialAccelerationVariance;

  // radial configuration
  num minRadius;
  num maxRadius, maxRadiusVariance;
  num rotatePerSecond, rotatePerSecondVariance;

  // color configuration
  _ParticleColor startColor;
  _ParticleColor endColor;

  //-------------------------------------------------------------------------------------------------

  ParticleSystem(String jsonConfig)
  {
    _random = new Random();
    _emissionTime = 0.0;
    _frameTime = 0.0;

    _particles = new List<_Particle>();
    _particleCount = 0;

    var pex = json.parse(jsonConfig);
    
    emitterType = pex["emitterType"].toInt();
    emitterX = pex["sourcePosition"]["x"] as num;
    emitterY = pex["sourcePosition"]["y"] as num;
    emitterXVariance = pex["sourcePositionVariance"]["x"] as num;
    emitterYVariance = pex["sourcePositionVariance"]["y"] as num;

    maxNumParticles = pex["maxParticles"].toInt();
    lifespan = max(0.01, pex["particleLifeSpan"] as num);
    lifespanVariance = pex["particleLifespanVariance"] as num;
    startSize = pex["startParticleSize"] as num;
    startSizeVariance = pex["startParticleSizeVariance"] as num;
    endSize = pex["finishParticleSize"] as num;
    endSizeVariance = pex["FinishParticleSizeVariance"] as num;
    emitAngle = (pex["angle"] as num) * PI / 180.0;
    emitAngleVariance = (pex["angleVariance"] as num) * PI / 180.0;

    gravityX = pex["gravity"]["x"] as num;
    gravityY = pex["gravity"]["y"] as num;
    speed = pex["speed"] as num;
    speedVariance = pex["speedVariance"] as num;
    radialAcceleration = pex["radialAcceleration"] as num;
    radialAccelerationVariance = pex["radialAccelVariance"] as num;
    tangentialAcceleration = pex["tangentialAcceleration"] as num;
    tangentialAccelerationVariance = pex["tangentialAccelVariance"] as num;

    minRadius = pex["minRadius"] as num;
    maxRadius = pex["maxRadius"] as num;
    maxRadiusVariance = pex["maxRadiusVariance"] as num;
    rotatePerSecond = (pex["rotatePerSecond"] as num) * PI / 180.0;
    rotatePerSecondVariance = (pex["rotatePerSecondVariance"] as num) * PI / 180.0;

    startColor = new _ParticleColor.fromJSON(pex["startColor"]);
    endColor = new _ParticleColor.fromJSON(pex["finishColor"]);

    _drawParticleCanvas();
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _drawParticleCanvas()
  {
    _particleCanvas = new CanvasElement(width: 256, height: 256);
    var context = _particleCanvas.context2d;

    for(int i = 0; i< 64; i++)
    {
      var radius = 15;
      num targetX = (i  % 8) * 32 + 15.5;
      num targetY = (i ~/ 8) * 32 + 15.5;

      num colorRed   = startColor.red   + i * (endColor.red    - startColor.red ) / 63;
      num colorGreen = startColor.green + i * (endColor.green - startColor.green) / 63;
      num colorBlue  = startColor.blue  + i * (endColor.blue  - startColor.blue ) / 63;
      num colorAlpha = startColor.alpha + i * (endColor.alpha - startColor.alpha) / 63;

      int cRed = (255.0 * colorRed).toInt();
      int cGreen = (255.0 * colorGreen).toInt();
      int cBlue = (255.0 * colorBlue).toInt();
      int cAlpha = (255.0 * colorAlpha).toInt();

      if (cRed < 0) cRed = 0; else if (cRed > 255) cRed = 255;
      if (cGreen < 0) cGreen = 0; else if (cGreen > 255) cGreen = 255;
      if (cBlue < 0) cBlue = 0; else if (cBlue > 255) cBlue = 255;
      if (cAlpha < 0) cAlpha = 0; else if (cAlpha > 255) cAlpha = 255;

      var gradient = context.createRadialGradient(targetX, targetY, 0, targetX, targetY, radius);
      gradient.addColorStop(0.0, "rgba($cRed, $cGreen, $cBlue, ${cAlpha / 255.0})");
      gradient.addColorStop(1.0, "rgba($cRed, $cGreen, $cBlue, 0.0)");

      context.beginPath();
      context.moveTo(targetX + radius, targetY);
      context.arc(targetX, targetY, radius, 0, PI * 2.0, false);
      context.fillStyle = gradient;
      context.fill();
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _initParticle(_Particle particle)
  {
    particle.currentTime = 0.0;
    particle.totalTime = lifespan + lifespanVariance * (_random.nextDouble() * 2.0 - 1.0);

    if (particle.totalTime <= 0.0) return;

    particle.x = emitterX + emitterXVariance * (_random.nextDouble() * 2.0 - 1.0);
    particle.y = emitterY + emitterYVariance * (_random.nextDouble() * 2.0 - 1.0);
    particle.startX = emitterX;
    particle.startY = emitterY;

    num angle = emitAngle + emitAngleVariance * (_random.nextDouble() * 2.0 - 1.0);
    num velocity = speed + speedVariance * (_random.nextDouble() * 2.0 - 1.0);
    particle.velocityX = velocity * cos(angle);
    particle.velocityY = velocity * sin(angle);

    particle.emitRadius = maxRadius + maxRadiusVariance * (_random.nextDouble() * 2.0 - 1.0);
    particle.emitRadiusDelta = maxRadius / particle.totalTime;
    particle.emitRotation = emitAngle + emitAngleVariance * (_random.nextDouble() * 2.0 - 1.0);
    particle.emitRotationDelta = rotatePerSecond + rotatePerSecondVariance * (_random.nextDouble() * 2.0 - 1.0);
    particle.radialAcceleration = radialAcceleration + radialAccelerationVariance * (_random.nextDouble() * 2.0 - 1.0);
    particle.tangentialAcceleration = tangentialAcceleration + tangentialAccelerationVariance * (_random.nextDouble() * 2.0 - 1.0);

    num size1 = startSize + startSizeVariance * (_random.nextDouble() * 2.0 - 1.0);
    num size2 = endSize + endSizeVariance * (_random.nextDouble() * 2.0 - 1.0);
    if (size1 < 0.1) size1 = 0.1;
    if (size2 < 0.1) size2 = 0.1;
    particle.size = size1;
    particle.sizeDelta = (size2 - size1) / particle.totalTime;

    // colors
    /*
    ParticleColor color = particle.color;
    ParticleColor colorDelta = particle.colorDelta;

    color.red   = startColor.red;
    color.green = startColor.green;
    color.blue  = startColor.blue;
    color.alpha = startColor.alpha;

    colorDelta.red   = (endColor.red   - startColor.red)   / particle.totalTime;
    colorDelta.green = (endColor.green - startColor.green) / particle.totalTime;
    colorDelta.blue  = (endColor.blue  - startColor.blue)  / particle.totalTime;
    colorDelta.alpha = (endColor.alpha - startColor.alpha) / particle.totalTime;
    */
  }

  //-------------------------------------------------------------------------------------------------

  void _advanceParticle(_Particle particle, num passedTime)
  {
    num restTime = particle.totalTime - particle.currentTime;
    passedTime = (restTime > passedTime) ? passedTime : restTime;
    particle.currentTime += passedTime;

    if (emitterType == EMITTER_TYPE_RADIAL)
    {
      particle.emitRotation += particle.emitRotationDelta * passedTime;
      particle.emitRadius   -= particle.emitRadiusDelta   * passedTime;
      particle.x = emitterX - cos(particle.emitRotation) * particle.emitRadius;
      particle.y = emitterY - sin(particle.emitRotation) * particle.emitRadius;

      if (particle.emitRadius < minRadius)
        particle.currentTime = particle.totalTime;
    }
    else
    {
      num distanceX = particle.x - particle.startX;
      num distanceY = particle.y - particle.startY;
      num distanceScalar = sqrt(distanceX * distanceX + distanceY * distanceY);
      if (distanceScalar < 0.01) distanceScalar = 0.01;
      distanceX = distanceX / distanceScalar;
      distanceY = distanceY / distanceScalar;

      particle.velocityX += passedTime * (gravityX + distanceX * particle.radialAcceleration - distanceY * particle.tangentialAcceleration);
      particle.velocityY += passedTime * (gravityY + distanceY * particle.radialAcceleration + distanceX * particle.tangentialAcceleration);
      particle.x += particle.velocityX * passedTime;
      particle.y += particle.velocityY * passedTime;
    }

    particle.size += particle.sizeDelta * passedTime;

    /*
    ParticleColor color = particle.color;
    ParticleColor colorDelta = particle.colorDelta;
    color.red   += colorDelta.red   * passedTime;
    color.green += colorDelta.green * passedTime;
    color.blue  += colorDelta.blue  * passedTime;
    color.alpha += colorDelta.alpha * passedTime;
    */
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void start([num duration = double.INFINITY])
  {
    _emissionTime = duration;
  }

  void stop(bool clear)
  {
    _emissionTime = 0.0;

    if (clear)
      _particleCount = 0;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  bool advanceTime(num passedTime)
  {
    int particleIndex = 0;

    //--------------------------------------------------------
    // advance existing particles

    while (particleIndex < _particleCount)
    {
      _Particle particle = _particles[particleIndex];

      if (particle.currentTime < particle.totalTime)
      {
        _advanceParticle(particle, passedTime);
        particleIndex++;
      }
      else
      {
        var swapParticle = _particles[_particleCount - 1];
        _particles[_particleCount - 1] = particle;
        _particles[particleIndex] = swapParticle;
        _particleCount--;
      }
    }

    //--------------------------------------------------------
    // create and advance new particles

    if (_emissionTime > 0.0)
    {
      num timeBetweenParticles = lifespan / maxNumParticles;
      _frameTime += passedTime;

      while (_frameTime > 0.0)
      {
        if (_particleCount < maxNumParticles)
        {
          if (_particleCount >= _particles.length)
            _particles.add(new _Particle());

          var particle = _particles[_particleCount++];
          _initParticle(particle);
          _advanceParticle(particle, _frameTime);
        }

        _frameTime -= timeBetweenParticles;
      }

      _emissionTime = max(0.0, _emissionTime - passedTime);
    }

    //--------------------------------------------------------

    return (_particleCount > 0);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void render(RenderState renderState)
  {
    var context = renderState.context;

    context.save();
    context.globalCompositeOperation = "lighter";

    for(int i = 0; i < _particleCount; i++)
    {
      var particle = _particles[i];

      int time = ((particle.currentTime / particle.totalTime) * 63).toInt();
      int sourceX = (time  % 8) * 32;
      int sourceY = (time ~/ 8) * 32;

      int targetSize = particle.size.toInt();
      int targetX = (particle.x - targetSize / 2.0).toInt();
      int targetY = (particle.y - targetSize / 2.0).toInt();

      context.drawImage(_particleCanvas, sourceX, sourceY, 32, 32, targetX, targetY, targetSize, targetSize);
    }

    context.restore();
  }

}
