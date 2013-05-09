part of stagexl;

//-------------------------------------------------------------------------------------------------
// Credits to www.gamua.com
// Particle System Extension for the Starling framework
// The original code was release under the Simplified BSD License
// http://wiki.starling-framework.org/extensions/particlesystem
//-------------------------------------------------------------------------------------------------

class _ParticleColor {

  num red, green, blue, alpha;

  _ParticleColor([this.red = 0.0, this.green = 0.0, this.blue = 0.0, this.alpha = 0.0]);

  _ParticleColor.fromJSON(Map json) {
    this.red = _ensureNum(json["red"]);
    this.green = _ensureNum(json["green"]);
    this.blue = _ensureNum(json["blue"]);
    this.alpha = _ensureNum(json["alpha"]);
  }
}

class _Particle {
  num _currentTime = 0.0;
  num _totalTime = 0.0;
  num _x = 0.0;
  num _y = 0.0;
  num _size = 0.0;
  num _sizeDelta = 0.0;
  num _rotation = 0.0;
  num _rotationDelta = 0.0;
  num _startX = 0.0;
  num _startY = 0.0;
  num _velocityX = 0.0;
  num _velocityY = 0.0;
  num _radialAcceleration = 0.0;
  num _tangentialAcceleration = 0.0;
  num _emitRadius = 0.0;
  num _emitRadiusDelta = 0.0;
  num _emitRotation = 0.0;
  num _emitRotationDelta = 0.0;
  //_ParticleColor color, colorDelta;
}

class ParticleSystem extends DisplayObject implements Animatable {

  final Random _random = new Random();
  final List<_Particle> _particles = new List<_Particle>();

  int _particleCount;
  CanvasElement _particleCanvas;
  num _frameTime;
  num _emissionTime;

  static const int EMITTER_TYPE_GRAVITY = 0;
  static const int EMITTER_TYPE_RADIAL = 1;

  // emitter configuration
  int _emitterType = 0;
  num _emitterX = 0.0;
  num _emitterY = 0.0;
  num _emitterXVariance = 0.0;
  num _emitterYVariance = 0.0;

  // particle configuration
  int _maxNumParticles = 0;
  num _lifespan = 0.0;
  num _lifespanVariance = 0.0;
  num _startSize = 0.0;
  num _startSizeVariance = 0.0;
  num _endSize = 0.0;
  num _endSizeVariance = 0.0;
  num _emitAngle = 0.0;
  num _emitAngleVariance = 0.0;

  // gravity configuration
  num _gravityX = 0.0;
  num _gravityY = 0.0;
  num _speed = 0.0;
  num _speedVariance = 0.0;
  num _radialAcceleration = 0.0;
  num _radialAccelerationVariance = 0.0;
  num _tangentialAcceleration = 0.0;
  num _tangentialAccelerationVariance = 0.0;

  // radial configuration
  num _minRadius = 0.0;
  num _maxRadius = 0.0;
  num _maxRadiusVariance = 0.0;
  num _rotatePerSecond = 0.0;
  num _rotatePerSecondVariance = 0.0;

  // color configuration
  _ParticleColor startColor;
  _ParticleColor endColor;

  //-------------------------------------------------------------------------------------------------

  ParticleSystem(String jsonConfig) {

    _emissionTime = 0.0;
    _frameTime = 0.0;
    _particleCount = 0;

    var pex = json.parse(jsonConfig);

    _emitterType = _ensureInt(pex["emitterType"]);
    _emitterX = _ensureNum(pex["sourcePosition"]["x"]);
    _emitterY = _ensureNum(pex["sourcePosition"]["y"]);
    _emitterXVariance = _ensureNum(pex["sourcePositionVariance"]["x"]);
    _emitterYVariance = _ensureNum(pex["sourcePositionVariance"]["y"]);

    _maxNumParticles = _ensureInt(pex["maxParticles"]);
    _lifespan = _ensureNum(max(0.01, pex["particleLifeSpan"]));
    _lifespanVariance = _ensureNum(pex["particleLifespanVariance"]);
    _startSize = _ensureNum(pex["startParticleSize"]);
    _startSizeVariance = _ensureNum(pex["startParticleSizeVariance"]);
    _endSize = _ensureNum(pex["finishParticleSize"]);
    _endSizeVariance = _ensureNum(pex["FinishParticleSizeVariance"]);
    _emitAngle = _ensureNum(pex["angle"]) * PI / 180.0;
    _emitAngleVariance = _ensureNum(pex["angleVariance"]) * PI / 180.0;

    _gravityX = _ensureNum(pex["gravity"]["x"]);
    _gravityY = _ensureNum(pex["gravity"]["y"]);
    _speed = _ensureNum(pex["speed"]);
    _speedVariance = _ensureNum(pex["speedVariance"]);
    _radialAcceleration = _ensureNum(pex["radialAcceleration"]);
    _radialAccelerationVariance = _ensureNum(pex["radialAccelVariance"]);
    _tangentialAcceleration = _ensureNum(pex["tangentialAcceleration"]);
    _tangentialAccelerationVariance = _ensureNum(pex["tangentialAccelVariance"]);

    _minRadius = _ensureNum(pex["minRadius"]);
    _maxRadius = _ensureNum(pex["maxRadius"]);
    _maxRadiusVariance = _ensureNum(pex["maxRadiusVariance"]);
    _rotatePerSecond = _ensureNum(pex["rotatePerSecond"]) * PI / 180.0;
    _rotatePerSecondVariance = _ensureNum(pex["rotatePerSecondVariance"]) * PI / 180.0;

    startColor = new _ParticleColor.fromJSON(pex["startColor"]);
    endColor = new _ParticleColor.fromJSON(pex["finishColor"]);

    _drawParticleCanvas();
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _drawParticleCanvas() {

    _particleCanvas = new CanvasElement(width: 256, height: 256);
    var context = _particleCanvas.context2D;

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

  void _initParticle(_Particle particle) {

    if (particle is! _Particle) return;     // dart2js hint

    var totalTime = _lifespan + _lifespanVariance * (_random.nextDouble() * 2.0 - 1.0);
    if (totalTime <= 0.0) return;

    particle._currentTime = 0.0;
    particle._totalTime = totalTime;

    particle._x = _emitterX + _emitterXVariance * (_random.nextDouble() * 2.0 - 1.0);
    particle._y = _emitterY + _emitterYVariance * (_random.nextDouble() * 2.0 - 1.0);
    particle._startX = _emitterX;
    particle._startY = _emitterY;

    num angle = _emitAngle + _emitAngleVariance * (_random.nextDouble() * 2.0 - 1.0);
    num velocity = _speed + _speedVariance * (_random.nextDouble() * 2.0 - 1.0);
    particle._velocityX = (velocity * cos(angle));
    particle._velocityY = (velocity * sin(angle));

    particle._emitRadius = _maxRadius + _maxRadiusVariance * (_random.nextDouble() * 2.0 - 1.0);
    particle._emitRadiusDelta = _maxRadius / particle._totalTime;
    particle._emitRotation = _emitAngle + _emitAngleVariance * (_random.nextDouble() * 2.0 - 1.0);
    particle._emitRotationDelta = _rotatePerSecond + _rotatePerSecondVariance * (_random.nextDouble() * 2.0 - 1.0);
    particle._radialAcceleration = _ensureNum(_radialAcceleration) + _radialAccelerationVariance * (_random.nextDouble() * 2.0 - 1.0);
    particle._tangentialAcceleration = _ensureNum(_tangentialAcceleration) + _tangentialAccelerationVariance * (_random.nextDouble() * 2.0 - 1.0);

    num size1 = _startSize + _startSizeVariance * (_random.nextDouble() * 2.0 - 1.0);
    num size2 = _endSize + _endSizeVariance * (_random.nextDouble() * 2.0 - 1.0);
    if (size1 < 0.1) size1 = 0.1;
    if (size2 < 0.1) size2 = 0.1;
    particle._size = size1;
    particle._sizeDelta = (size2 - size1) / particle._totalTime;

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

  void _advanceParticle(_Particle particle, num passedTime) {

    if (particle is! _Particle) return;     // dart2js hint

    num restTime = particle._totalTime - particle._currentTime;
    passedTime = (restTime > passedTime) ? passedTime : restTime;
    particle._currentTime += passedTime;

    if (_emitterType == EMITTER_TYPE_RADIAL) {

      particle._emitRotation += particle._emitRotationDelta * passedTime;
      particle._emitRadius   -= particle._emitRadiusDelta   * passedTime;
      particle._x = _emitterX - cos(particle._emitRotation) * particle._emitRadius;
      particle._y = _emitterY - sin(particle._emitRotation) * particle._emitRadius;

      if (particle._emitRadius < _minRadius)
        particle._currentTime = particle._totalTime;

    } else {

      num distanceX = particle._x - particle._startX;
      num distanceY = particle._y - particle._startY;
      num distanceScalar = sqrt(distanceX * distanceX + distanceY * distanceY);
      if (distanceScalar < 0.01) distanceScalar = 0.01;
      distanceX = distanceX / distanceScalar;
      distanceY = distanceY / distanceScalar;

      particle._velocityX += passedTime * (_gravityX + distanceX * particle._radialAcceleration - distanceY * particle._tangentialAcceleration);
      particle._velocityY += passedTime * (_gravityY + distanceY * particle._radialAcceleration + distanceX * particle._tangentialAcceleration);
      particle._x += particle._velocityX * passedTime;
      particle._y += particle._velocityY * passedTime;
    }

    particle._size += particle._sizeDelta * passedTime;

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

  void start([num duration = double.INFINITY]) {

    _emissionTime = duration;
  }

  void stop(bool clear) {

    _emissionTime = 0.0;

    if (clear)
      _particleCount = 0;
  }

  void setEmitterPosition(num x, num y) {
    _emitterX = _ensureNum(x);
    _emitterY = _ensureNum(y);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  bool advanceTime(num passedTime) {

    int particleIndex = 0;

    //--------------------------------------------------------
    // advance existing particles

    while (particleIndex < _particleCount) {

      _Particle particle = _particles[particleIndex];

      if (particle._currentTime < particle._totalTime) {

        _advanceParticle(particle, passedTime);
        particleIndex++;

      } else {

        var swapParticle = _particles[_particleCount - 1];
        _particles[_particleCount - 1] = particle;
        _particles[particleIndex] = swapParticle;
        _particleCount--;
      }
    }

    //--------------------------------------------------------
    // create and advance new particles

    if (_emissionTime > 0.0) {

      num timeBetweenParticles = _lifespan / _maxNumParticles;
      _frameTime += passedTime;

      while (_frameTime > 0.0) {

        if (_particleCount < _maxNumParticles) {

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

  void render(RenderState renderState) {

    var context = renderState.context;
    context.globalCompositeOperation = "lighter";

    for(int i = 0; i < _particleCount; i++) {

      var particle = _particles[i];

      var time = ((particle._currentTime / particle._totalTime) * 63).floor();
      var sourceX = (time  % 8) * 32;
      var sourceY = (time ~/ 8) * 32;

      var targetSize = particle._size;
      var targetX = particle._x - targetSize / 2.0;
      var targetY = particle._y - targetSize / 2.0;

      context.drawImageScaledFromSource(_particleCanvas, sourceX, sourceY, 32, 32, targetX, targetY, targetSize, targetSize);
    }
  }

}
