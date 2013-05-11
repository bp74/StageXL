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

class ParticleEmitter extends DisplayObject implements Animatable {

  final Random _random = new Random();
  final List<_Particle> _particles = new List<_Particle>();

  CanvasElement _particleCanvas;
  int _particleCount = 0;
  num _frameTime = 0.0;
  num _emissionTime = 0.0;

  static const int EMITTER_TYPE_GRAVITY = 0;
  static const int EMITTER_TYPE_RADIAL = 1;

  // emitter configuration
  int _emitterType = 0;
  num _locationX = 0.0;
  num _locationY = 0.0;
  num _locationXVariance = 0.0;
  num _locationYVariance = 0.0;

  // particle configuration
  int _maxNumParticles = 0;
  num _lifespan = 0.0;
  num _lifespanVariance = 0.0;
  num _startSize = 0.0;
  num _startSizeVariance = 0.0;
  num _endSize = 0.0;
  num _endSizeVariance = 0.0;
  String _shape = "circle";

  // gravity configuration
  num _gravityX = 0.0;
  num _gravityY = 0.0;
  num _speed = 0.0;
  num _speedVariance = 0.0;
  num _angle = 0.0;
  num _angleVariance = 0.0;
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
  String _compositeOperation;
  _ParticleColor _startColor;
  _ParticleColor _endColor;

  //-------------------------------------------------------------------------------------------------

  ParticleEmitter(String jsonConfig) {

    _emissionTime = 0.0;
    _frameTime = 0.0;
    _particleCount = 0;

    updateConfig(jsonConfig);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _drawParticleCanvas() {

    _particleCanvas = new CanvasElement(width: 256, height: 256);
    var context = _particleCanvas.context2D;

    for(int i = 0; i < 64; i++) {

      var radius = 15;
      num targetX = (i  % 8) * 32 + 15.5;
      num targetY = (i ~/ 8) * 32 + 15.5;

      num colorRed   = _startColor.red   + i * (_endColor.red    - _startColor.red ) / 63;
      num colorGreen = _startColor.green + i * (_endColor.green - _startColor.green) / 63;
      num colorBlue  = _startColor.blue  + i * (_endColor.blue  - _startColor.blue ) / 63;
      num colorAlpha = _startColor.alpha + i * (_endColor.alpha - _startColor.alpha) / 63;

      int cRed = (255.0 * colorRed).toInt();
      int cGreen = (255.0 * colorGreen).toInt();
      int cBlue = (255.0 * colorBlue).toInt();
      int cAlpha = (255.0 * colorAlpha).toInt();

      if (cRed < 0) cRed = 0; else if (cRed > 255) cRed = 255;
      if (cGreen < 0) cGreen = 0; else if (cGreen > 255) cGreen = 255;
      if (cBlue < 0) cBlue = 0; else if (cBlue > 255) cBlue = 255;
      if (cAlpha < 0) cAlpha = 0; else if (cAlpha > 255) cAlpha = 255;

      var gradient = context.createRadialGradient(targetX, targetY, 0, targetX, targetY, radius);
      gradient.addColorStop(0.00, "rgba($cRed, $cGreen, $cBlue, ${cAlpha / 255.0})");
      gradient.addColorStop(1.00, "rgba($cRed, $cGreen, $cBlue, 0.0)");
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

    var totalTime = _lifespan + _lifespanVariance * (_random.nextDouble() * 2.0 - 1.0);
    if (totalTime <= 0.0) return;

    particle._currentTime = 0.0;
    particle._totalTime = totalTime;

    particle._x = _locationX + _locationXVariance * (_random.nextDouble() * 2.0 - 1.0);
    particle._y = _locationY + _locationYVariance * (_random.nextDouble() * 2.0 - 1.0);
    particle._startX = _locationX;
    particle._startY = _locationY;

    num angle = _angle + _angleVariance * (_random.nextDouble() * 2.0 - 1.0);
    num velocity = _speed + _speedVariance * (_random.nextDouble() * 2.0 - 1.0);
    particle._velocityX = (velocity * cos(angle));
    particle._velocityY = (velocity * sin(angle));

    particle._emitRadius = _maxRadius + _maxRadiusVariance * (_random.nextDouble() * 2.0 - 1.0);
    particle._emitRadiusDelta = _maxRadius / particle._totalTime;
    particle._emitRotation = _angle + _angleVariance * (_random.nextDouble() * 2.0 - 1.0);
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

    num restTime = particle._totalTime - particle._currentTime;
    passedTime = (restTime > passedTime) ? passedTime : restTime;
    particle._currentTime += passedTime;

    if (_emitterType == EMITTER_TYPE_RADIAL) {

      particle._emitRotation += particle._emitRotationDelta * passedTime;
      particle._emitRadius   -= particle._emitRadiusDelta   * passedTime;
      particle._x = _locationX - cos(particle._emitRotation) * particle._emitRadius;
      particle._y = _locationY - sin(particle._emitRotation) * particle._emitRadius;

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

  void setEmitterLocation(num x, num y) {
    _locationX = _ensureNum(x);
    _locationY = _ensureNum(y);
  }

  void updateConfig(String jsonConfig) {

    var config = json.parse(jsonConfig);

    _emitterType = _ensureInt(config["emitterType"]);
    _locationX = _ensureNum(config["location"]["x"]);
    _locationY = _ensureNum(config["location"]["y"]);

    _maxNumParticles = _ensureInt(config["maxParticles"]);
    _lifespan = _ensureNum(max(0.01, config["lifeSpan"]));
    _lifespanVariance = _ensureNum(config["lifespanVariance"]);
    _startSize = _ensureNum(config["startSize"]);
    _startSizeVariance = _ensureNum(config["startSizeVariance"]);
    _endSize = _ensureNum(config["finishSize"]);
    _endSizeVariance = _ensureNum(config["finishSizeVariance"]);
    _shape = config["shape"];

    _locationXVariance = _ensureNum(config["locationVariance"]["x"]);
    _locationYVariance = _ensureNum(config["locationVariance"]["y"]);
    _speed = _ensureNum(config["speed"]);
    _speedVariance = _ensureNum(config["speedVariance"]);
    _angle = _ensureNum(config["angle"]) * PI / 180.0;
    _angleVariance = _ensureNum(config["angleVariance"]) * PI / 180.0;
    _gravityX = _ensureNum(config["gravity"]["x"]);
    _gravityY = _ensureNum(config["gravity"]["y"]);
    _radialAcceleration = _ensureNum(config["radialAcceleration"]);
    _radialAccelerationVariance = _ensureNum(config["radialAccelerationVariance"]);
    _tangentialAcceleration = _ensureNum(config["tangentialAcceleration"]);
    _tangentialAccelerationVariance = _ensureNum(config["tangentialAccelerationVariance"]);

    _minRadius = _ensureNum(config["minRadius"]);
    _maxRadius = _ensureNum(config["maxRadius"]);
    _maxRadiusVariance = _ensureNum(config["maxRadiusVariance"]);
    _rotatePerSecond = _ensureNum(config["rotatePerSecond"]) * PI / 180.0;
    _rotatePerSecondVariance = _ensureNum(config["rotatePerSecondVariance"]) * PI / 180.0;

    _compositeOperation = config["compositeOperation"];
    _startColor = new _ParticleColor.fromJSON(config["startColor"]);
    _endColor = new _ParticleColor.fromJSON(config["finishColor"]);

    _drawParticleCanvas();
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  bool advanceTime(num passedTime) {

    int particleIndex = 0;

    //--------------------------------------------------------
    // advance existing particles

    while (particleIndex < _particleCount) {

      _Particle particle = _particles[particleIndex];
      if (particle is! _Particle) continue; // dart2js hint

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
          if (particle is! _Particle) continue; // dart2js hint

          _initParticle(particle);
          _advanceParticle(particle, _frameTime);
        }

        _frameTime -= timeBetweenParticles;
      }

      _emissionTime = max(0.0, _emissionTime - passedTime);
    }

    //--------------------------------------------------------

    //return (_particleCount > 0);
    return true;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void render(RenderState renderState) {

    var context = renderState.context;
    context.globalCompositeOperation = _compositeOperation;

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

    //context.setTransform(1, 0, 0, 1, 0, 0);
    //context.drawImage(_particleCanvas, 0, 0);
  }

}
