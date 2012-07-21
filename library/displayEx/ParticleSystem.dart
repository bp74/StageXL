class ParticleSystem extends DisplayObject implements IAnimatable
{
  //-------------------------------------------------------------------------------------------------
  // Credits to www.gamua.com
  // Particle System Extension for the Starling framework
  // The original code was release under the Simplified BSD License
  // http://wiki.starling-framework.org/extensions/particlesystem
  //-------------------------------------------------------------------------------------------------
  
  List<Particle> _particles;
  int _particleCount;
  html.CanvasElement _particleCanvas;
  num _frameTime;
  num _emissionTime;
  
  static final int EMITTER_TYPE_GRAVITY = 0;
  static final int EMITTER_TYPE_RADIAL = 1;
  
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
  ParticleColor startColor;
  ParticleColor endColor;
  
  //-------------------------------------------------------------------------------------------------
  
  ParticleSystem(String jsonConfig)
  {
    _emissionTime = 0.0;
    _frameTime = 0.0;
    
    _particles = new List<Particle>();
    _particleCount = 0;
    
    var pex = json.JSON.parse(jsonConfig);
    
    // _blendFactorSource = pex["blendFuncSource"];
    // _blendFactorDestination = pex["blendFuncDestination"];
    
    emitterType = pex["emitterType"];
    emitterX = pex["sourcePosition"]["x"];
    emitterY = pex["sourcePosition"]["y"];
    emitterXVariance = pex["sourcePositionVariance"]["x"];
    emitterYVariance = pex["sourcePositionVariance"]["y"];
    
    maxNumParticles = pex["maxParticles"];
    lifespan = Math.max(0.01, pex["particleLifeSpan"]);
    lifespanVariance = pex["particleLifespanVariance"];
    startSize = pex["startParticleSize"];
    startSizeVariance = pex["startParticleSizeVariance"];
    endSize = pex["finishParticleSize"];
    endSizeVariance = pex["FinishParticleSizeVariance"];
    emitAngle = pex["angle"] * Math.PI / 180.0;
    emitAngleVariance = pex["angleVariance"] * Math.PI / 180.0;
    
    gravityX = pex["gravity"]["x"];
    gravityY = pex["gravity"]["y"];
    speed = pex["speed"];
    speedVariance = pex["speedVariance"];    
    radialAcceleration = pex["radialAcceleration"];
    radialAccelerationVariance = pex["radialAccelVariance"];
    tangentialAcceleration = pex["tangentialAcceleration"];
    tangentialAccelerationVariance = pex["tangentialAccelVariance"];

    minRadius = pex["minRadius"];    
    maxRadius = pex["maxRadius"];
    maxRadiusVariance = pex["maxRadiusVariance"];
    rotatePerSecond = pex["rotatePerSecond"] * Math.PI / 180.0;
    rotatePerSecondVariance = pex["rotatePerSecondVariance"] * Math.PI / 180.0;
    
    startColor = new ParticleColor.fromJSON(pex["startColor"]);
    endColor = new ParticleColor.fromJSON(pex["finishColor"]);
    
    _drawParticleCanvas();
  }  

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _drawParticleCanvas()
  {
    _particleCanvas = new html.CanvasElement(256, 256);
    var context = _particleCanvas.context2d;

    for(int i = 0; i< 64; i++)
    {
      var radius = 15;
      num targetX = (i % 8).toInt() * 32 + 15.5;
      num targetY = (i / 8).toInt() * 32 + 15.5;

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
      context.arc(targetX, targetY, radius, 0, Math.PI * 2, false);
      context.fillStyle = gradient;
      context.fill();
    }
  }
  
  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------
  
  void initParticle(Particle particle)
  {
    particle.currentTime = 0.0;
    particle.totalTime = lifespan + lifespanVariance * (Math.random() * 2.0 - 1.0);

    if (particle.totalTime <= 0.0) return;
      
    particle.x = emitterX + emitterXVariance * (Math.random() * 2.0 - 1.0);
    particle.y = emitterY + emitterYVariance * (Math.random() * 2.0 - 1.0);
    particle.startX = emitterX;
    particle.startY = emitterY;
      
    num angle = emitAngle + emitAngleVariance * (Math.random() * 2.0 - 1.0);
    num velocity = speed + speedVariance * (Math.random() * 2.0 - 1.0);
    particle.velocityX = velocity * Math.cos(angle);
    particle.velocityY = velocity * Math.sin(angle);
    
    particle.emitRadius = maxRadius + maxRadiusVariance * (Math.random() * 2.0 - 1.0);
    particle.emitRadiusDelta = maxRadius / particle.totalTime;
    particle.emitRotation = emitAngle + emitAngleVariance * (Math.random() * 2.0 - 1.0); 
    particle.emitRotationDelta = rotatePerSecond + rotatePerSecondVariance * (Math.random() * 2.0 - 1.0); 
    particle.radialAcceleration = radialAcceleration + radialAccelerationVariance * (Math.random() * 2.0 - 1.0);
    particle.tangentialAcceleration = tangentialAcceleration + tangentialAccelerationVariance * (Math.random() * 2.0 - 1.0);
    
    num size1 = startSize + startSizeVariance * (Math.random() * 2.0 - 1.0); 
    num size2 = endSize + endSizeVariance * (Math.random() * 2.0 - 1.0);
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
  
  void advanceParticle(Particle particle, num passedTime)
  {
    num restTime = particle.totalTime - particle.currentTime;
    passedTime = (restTime > passedTime) ? passedTime : restTime;
    particle.currentTime += passedTime;
      
    if (emitterType == EMITTER_TYPE_RADIAL)
    {
      particle.emitRotation += particle.emitRotationDelta * passedTime;
      particle.emitRadius   -= particle.emitRadiusDelta   * passedTime;
      particle.x = emitterX - Math.cos(particle.emitRotation) * particle.emitRadius;
      particle.y = emitterY - Math.sin(particle.emitRotation) * particle.emitRadius;
          
      if (particle.emitRadius < minRadius)
        particle.currentTime = particle.totalTime;
    }
    else
    {
      num distanceX = particle.x - particle.startX;
      num distanceY = particle.y - particle.startY;
      num distanceScalar = Math.sqrt(distanceX * distanceX + distanceY * distanceY);
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
    Particle particle;
      
    //--------------------------------------------------------
    // advance existing particles
      
    while (particleIndex < _particleCount)
    {
      particle = _particles[particleIndex];
          
      if (particle.currentTime < particle.totalTime)  
      {
        advanceParticle(particle, passedTime);
        particleIndex++;
      }
      else 
      {
        Particle swapParticle = _particles[_particleCount - 1];
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
        if (_particleCount >= _particles.length)
          _particles.add(new Particle());
        
        particle = _particles[_particleCount++];  
        this.initParticle(particle);
        this.advanceParticle(particle, _frameTime);

        _frameTime -= timeBetweenParticles;
      }
    }
    
    //--------------------------------------------------------

    if (_emissionTime == double.INFINITY) 
    {
      return (_particleCount > 0);
    }  
    else  
    {
      _emissionTime = Math.max(0.0, _emissionTime - passedTime);
      return (_emissionTime > 0.0);
    }
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
      Particle particle = _particles[i];

      int time = ((particle.currentTime / particle.totalTime) * 63).toInt();
      int sourceX = (time % 8).toInt() * 32;
      int sourceY = (time / 8).toInt() * 32;

      int targetSize = particle.size.toInt(); 
      int targetX = (particle.x - targetSize / 2.0).toInt();
      int targetY = (particle.y - targetSize / 2.0).toInt();

      context.drawImage(_particleCanvas, sourceX, sourceY, 32, 32, targetX, targetY, targetSize, targetSize);
    }
    
    context.restore();
  }
  
}
