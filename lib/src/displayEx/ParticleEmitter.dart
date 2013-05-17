part of stagexl;

//-------------------------------------------------------------------------------------------------
// Credits to www.gamua.com
// Particle System Extension for the Starling framework
// The original code was release under the Simplified BSD License
// http://wiki.starling-framework.org/extensions/particlesystem
//-------------------------------------------------------------------------------------------------

class _ParticleColor {

  num _red = 0.0;
  num _green = 0.0;
  num _blue = 0.0;
  num _alpha = 0.0;

  _ParticleColor.fromJSON(Map json) {
    _red = min(1.0, max(0.0, _ensureNum(json["red"])));
    _green = min(1.0, max(0.0, _ensureNum(json["green"])));
    _blue = min(1.0, max(0.0, _ensureNum(json["blue"])));
    _alpha = min(1.0, max(0.0, _ensureNum(json["alpha"])));
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class _Particle {

  final ParticleEmitter _particleEmitter;

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

  CanvasElement _particleCanvas;
  _Particle _nextParticle;

  _Particle(ParticleEmitter particleEmitter) : _particleEmitter = particleEmitter;

  //-----------------------------------------------------------------------------------------------

  _initParticle() {

    var pe = _particleEmitter;
    var totalTime = pe._lifespan + pe._lifespanVariance * pe._randomVariance;
    if (totalTime < 0.01) totalTime = 0.01;

    _currentTime = 0.0;
    _totalTime = totalTime;

    _x = pe._locationX + pe._locationXVariance * pe._randomVariance;
    _y = pe._locationY + pe._locationYVariance * pe._randomVariance;
    _startX = pe._locationX;
    _startY = pe._locationY;

    num angle = pe._angle + pe._angleVariance * pe._randomVariance;
    num velocity = pe._speed + pe._speedVariance * pe._randomVariance;
    _velocityX = (velocity * cos(angle));
    _velocityY = (velocity * sin(angle));

    _emitRadius = pe._maxRadius + pe._maxRadiusVariance * pe._randomVariance;
    _emitRadiusDelta = pe._maxRadius / _totalTime;
    _emitRotation = pe._angle + pe._angleVariance * pe._randomVariance;
    _emitRotationDelta = pe._rotatePerSecond + pe._rotatePerSecondVariance * pe._randomVariance;
    _radialAcceleration = pe._radialAcceleration + pe._radialAccelerationVariance * pe._randomVariance;
    _tangentialAcceleration = pe._tangentialAcceleration + pe._tangentialAccelerationVariance * pe._randomVariance;

    num size1 = pe._startSize + pe._startSizeVariance * pe._randomVariance;
    num size2 = pe._endSize + pe._endSizeVariance * pe._randomVariance;
    if (size1 < 0.1) size1 = 0.1;
    if (size2 < 0.1) size2 = 0.1;
    _size = size1;
    _sizeDelta = (size2 - size1) / _totalTime;

    _particleCanvas = pe._particleCanvas;

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

  //-----------------------------------------------------------------------------------------------

  bool _advanceParticle(num passedTime) {

    var pe = _particleEmitter;
    var restTime = _totalTime - _currentTime;
    if (restTime <= 0.0) return false;
    if (restTime <= passedTime) passedTime = restTime;

    _currentTime += passedTime;

    if (pe._emitterType == ParticleEmitter.EMITTER_TYPE_RADIAL) {

      _emitRotation += _emitRotationDelta * passedTime;
      _emitRadius   -= _emitRadiusDelta   * passedTime;
      _x = pe._locationX - cos(_emitRotation) * _emitRadius;
      _y = pe._locationY - sin(_emitRotation) * _emitRadius;

      if (_emitRadius < pe._minRadius) {
        _currentTime = _totalTime;
      }

    } else {

      num distanceX = _x - _startX;
      num distanceY = _y - _startY;
      num distanceScalar = sqrt(distanceX * distanceX + distanceY * distanceY);
      if (distanceScalar < 0.01) distanceScalar = 0.01;
      distanceX = distanceX / distanceScalar;
      distanceY = distanceY / distanceScalar;

      var gravityX = pe._gravityX;
      var gravityY = pe._gravityY;

      _velocityX += passedTime * (gravityX + distanceX * _radialAcceleration - distanceY * _tangentialAcceleration);
      _velocityY += passedTime * (gravityY + distanceY * _radialAcceleration + distanceX * _tangentialAcceleration);
      _x += _velocityX * passedTime;
      _y += _velocityY * passedTime;
    }

    _size += _sizeDelta * passedTime;

    /*
    ParticleColor color = particle.color;
    ParticleColor colorDelta = particle.colorDelta;
    color.red   += colorDelta.red   * passedTime;
    color.green += colorDelta.green * passedTime;
    color.blue  += colorDelta.blue  * passedTime;
    color.alpha += colorDelta.alpha * passedTime;
    */

    return true;
  }

  //-----------------------------------------------------------------------------------------------

  _renderParticle(CanvasRenderingContext2D context) {

    var imageIndex = _currentTime * 32 ~/ _totalTime;
    var sourceX = 32 * imageIndex;
    var sourceY = 0;
    var targetX = _x - _size / 2.0;
    var targetY = _y - _size / 2.0;

    context.drawImageScaledFromSource(_particleCanvas, sourceX, sourceY, 32, 32, targetX, targetY, _size, _size);
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class ParticleEmitter extends DisplayObject implements Animatable {

  final Random _random = new Random();

  _Particle _rootParticle;
  _Particle _lastParticle;

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
  num _duration = 0.0;
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

    _rootParticle = new _Particle(this);
    _lastParticle = _rootParticle;

    _emissionTime = 0.0;
    _frameTime = 0.0;
    _particleCount = 0;

    updateConfig(jsonConfig);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _drawParticleCanvas() {

    _particleCanvas = new CanvasElement(width: 1024, height: 32);
    var context = _particleCanvas.context2D;

    for(int i = 0; i < 32; i++) {

      var radius = 15;
      num targetX = i * 32 + 15.5;
      num targetY = 15.5;

      num colorRed   = _startColor._red   + i * (_endColor._red   - _startColor._red ) / 31;
      num colorGreen = _startColor._green + i * (_endColor._green - _startColor._green) / 31;
      num colorBlue  = _startColor._blue  + i * (_endColor._blue  - _startColor._blue ) / 31;
      num colorAlpha = _startColor._alpha + i * (_endColor._alpha - _startColor._alpha) / 31;

      int cRed = (255.0 * colorRed).toInt();
      int cGreen = (255.0 * colorGreen).toInt();
      int cBlue = (255.0 * colorBlue).toInt();

      var gradient = context.createRadialGradient(targetX, targetY, 0, targetX, targetY, radius);
      gradient.addColorStop(0.00, "rgba($cRed, $cGreen, $cBlue, $colorAlpha)");
      gradient.addColorStop(1.00, "rgba($cRed, $cGreen, $cBlue, 0.0)");
      context.beginPath();
      context.moveTo(targetX + radius, targetY);
      context.arc(targetX, targetY, radius, 0, PI * 2.0, false);
      context.fillStyle = gradient;
      context.fill();
    }
  }

  //-------------------------------------------------------------------------------------------------

  void start([num duration]) {
    _emissionTime = _duration;

    if (duration != null && duration is num)
      _emissionTime = duration;
  }

  void stop(bool clear) {
    _emissionTime = 0.0;
    if (clear) _particleCount = 0;
  }

  void setEmitterLocation(num x, num y) {
    _locationX = _ensureNum(x);
    _locationY = _ensureNum(y);
  }

  int get particleCount => _particleCount;

  num get _randomVariance => _random.nextDouble() * 2.0 - 1.0;

  //-------------------------------------------------------------------------------------------------

  void updateConfig(String jsonConfig) {

    var config = json.parse(jsonConfig);

    _emitterType = _ensureInt(config["emitterType"]);
    _locationX = _ensureNum(config["location"]["x"]);
    _locationY = _ensureNum(config["location"]["y"]);

    _maxNumParticles = _ensureInt(config["maxParticles"]);
    _duration = _ensureNum(config["duration"]);
    _lifespan = _ensureNum(config["lifeSpan"]);
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

    if (_duration <= 0) _duration = double.INFINITY;
    _emissionTime = _duration;

    _drawParticleCanvas();
  }

  //-------------------------------------------------------------------------------------------------

  bool advanceTime(num passedTime) {

    var particle = _rootParticle;
    var particleCount = _particleCount;

    // advance existing particles

    for (int i = 0; i < particleCount; i++) {

      var nextParticle = particle._nextParticle as _Particle;

      if (nextParticle._advanceParticle(passedTime)) {
        particle = nextParticle;
        continue;
      }

      if (nextParticle._nextParticle != null) {
        particle._nextParticle = nextParticle._nextParticle;
        _lastParticle._nextParticle = nextParticle;
        _lastParticle = nextParticle;
        _lastParticle._nextParticle = null;
      }

      _particleCount--;
    }

    // create and advance new particles

    if (_emissionTime > 0.0) {

      num timeBetweenParticles = _lifespan / _maxNumParticles;
      _frameTime += passedTime;

      while (_frameTime > 0.0) {

        if (_particleCount < _maxNumParticles) {

          var nextParticle = particle._nextParticle;

          if (nextParticle == null) {
            nextParticle = _lastParticle = particle._nextParticle = new _Particle(this);
          }

          particle = nextParticle;
          particle._initParticle();
          particle._advanceParticle(_frameTime);
          _particleCount++;
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

  void render(RenderState renderState) {

    var context = renderState.context;
    context.globalCompositeOperation = _compositeOperation;

    var particle = _rootParticle;

    for(int i = 0; i < _particleCount; i++) {
      particle = particle._nextParticle;
      particle._renderParticle(context);
    }
  }

}
