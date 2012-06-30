class Board extends Sprite
{
                      // LEVEL |  1 |  2 |  3 |  4 |  5 |  6 |  7 | ++
                      //-------|------------------------------------------
  int _levelChains;   //       | 40 | 45 | 50 | 55 | 60 | 65 | 70 | ++5
  int _levelLocks;    //       |  3 |  3 |  4 |  4 |  5 |  5 |  5 | ==
  int _levelJokers;   //       |  0 |  1 |  2 |  3 |  4 |  5 |  5 | ==
  int _levelBlocks;   //       |  0 |  0 |  2 |  3 |  4 |  5 |  6 | ==
  int _levelDoubles;  //       |  0 |  0 |  1 |  2 |  2 |  3 |  3 | ==
  int _levelQuints;   //       |  0 |  0 |  0 |  0 |  1 |  2 |  2 | ==
  int _levelColors;   //       |  3 |  3 |  3 |  3 |  3 |  4 |  4 | ==

  //-------------------------------------------------------------------------------------------------

  int _status;

  List<int>_colors;
  List<Field> _queue;
  List<Field> _fields;
  List<Lock> _locks;

  List<Point> _mouseBuffer;
  bool _animationRunning;

  Sprite _chainLayer;
  Sprite _linkLayer;
  Sprite _specialLayer;
  Sprite _lockLayer;
  Sprite _explosionLayer;

  //-------------------------------------------------------------------------------------------------

  Board(int chains, int locks, int jokers, int blocks, int doubles, int quints, List<int> colors)
  {
    _status = BoardStatus.Playing;
    _colors = colors;

    _levelChains = chains;
    _levelLocks = locks;
    _levelJokers = jokers;
    _levelBlocks = blocks;
    _levelDoubles = doubles;
    _levelQuints = quints;
    _levelColors = colors.length;

    _mouseBuffer = new List<Point>();

    //----------------------------

    _chainLayer = new Sprite();
    _linkLayer = new Sprite();
    _specialLayer = new Sprite();
    _lockLayer = new Sprite();
    _explosionLayer = new Sprite();

    addChild(_chainLayer);
    addChild(_linkLayer);
    addChild(_specialLayer);
    addChild(_lockLayer);
    addChild(_explosionLayer);

    _linkLayer.mouseEnabled = false;
    _specialLayer.mouseEnabled = false;
    _lockLayer.mouseEnabled = false;
    _explosionLayer.mouseEnabled = false;

    //----------------------------

    initLocks();
    initQueue();
    initField();

    _animationRunning = true;

    ValueCounter completeCounter = new ValueCounter();

    this.mask = new Mask.rectangle(0.0, 0.0, 500.0, 500.0);

    for(int x = 0; x < 10; x++)
    {
      for(int y = 0; y < 10; y++)
      {
        Field field = _fields[x + y * 10];
        field.x = x * 50 + 25;
        field.y = y * 50 + 25 - 550;
        field.updateDisplayObjects(_chainLayer, _linkLayer, _specialLayer);

        Tween tween = new Tween(field, 0.4, Transitions.easeOutCubic);
        tween.animate("y", y * 50 + 25);
        tween.delay = x * 0.03;
        tween.onComplete = ()
        {
          if (completeCounter.increment() == 100)
          {
            _updateLinks();
            _animationRunning = false;
            _mouseBuffer.clear();
            this.mask = null;
          }
        };

        Juggler.instance.add(tween);
      }
    }

    //----------------------------

    addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void updateStatus(int status)
  {
    if (status == BoardStatus.Finalizing)
      _status = status;

    if (status == BoardStatus.Timeouting && _status == BoardStatus.Playing)
    {
       _status = status;

       if (_animationRunning == false)
         dispatchEvent(new BoardEvent(BoardEvent.Timeouted, null));
    }
  }

  //-------------------------------------------------------------------------------------------------

  void dropFields()
  {
    this.mask = new Mask.rectangle(0.0, 0.0, 500.0, 500.0);

    for(int y = 0; y < 10; y++)
    {
      for(int x = 0; x < 10; x++)
      {
       Field field = _fields[x + y * 10];

        field.linked = false;
        field.linkedJoker = false;
        field.special = Special.None;
        field.updateDisplayObjects(_chainLayer, _linkLayer, _specialLayer);

        Tween tween = new Tween(field, 0.5, Transitions.easeOutCubic);
        tween.animate("y", 500 + y *50 + 25);
        tween.delay = x * 0.1;

        //tween.animate("x", -500 + x * 50);
        //tween.delay = y * 0.1;

        Juggler.instance.add(tween);
      }
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void initLocks()
  {
    _locks = new List<Lock>();

    for(int l = 0; l < _levelLocks; l++)
    {
      Lock lock = new Lock(l);
      lock.rotation = (Math.random() * 30 - 15) * Math.PI / 180;
      lock.x = 300 - (90 * _levelLocks) / 2 + l * 90 + (Math.random() * 20 - 10);
      lock.y = 550;

      _locks.add(lock);
      _lockLayer.addChild(lock);
    }
  }

  //-------------------------------------------------------------------------------------------------

  int countLinks(int x, int y)
  {
    int linkCount = 0;
    Field field = _fields[x + y * 10];

    if (field.direction == 0)
    {
      Field fieldWest = (x > 0) ? _fields[x - 1 + y * 10] : null;
      Field fieldEast = (x < 9) ? _fields[x + 1 + y * 10] : null;

      if (field.canLinkHorizontal(fieldWest))
        linkCount++;

      if (field.canLinkHorizontal(fieldEast))
        linkCount++;
    }
    else
    {
      Field fieldNorth = (y > 0) ? _fields[x + (y - 1) * 10] : null;
      Field fieldSouth = (y < 9) ? _fields[x + (y + 1) * 10] : null;

      if (field.canLinkVertical(fieldNorth))
        linkCount++;

      if (field.canLinkVertical(fieldSouth))
        linkCount++;
    }

    return linkCount;
  }

  //-------------------------------------------------------------------------------------------------

  bool clearCombinations()
  {
    for(int y = 0; y < 10; y++)
    {
      for(int x = 0; x < 10; x++)
      {
        Field field = _fields[x + y * 10];
        int retry = _levelColors * 2;

        while (countLinks(x, y) == 2 && retry > 0)
        {
          if (retry % 2 == 0)
          {
            field.direction = 1 - field.direction;
            retry--;
          }
          else
          {
            int colorIndex = 0;

            for(int ci = 0; ci < _colors.length; ci++)
              if (field.color == _colors[ci])
                colorIndex = ci;

            field.color = _colors[(colorIndex + 1) % _colors.length];
            retry--;
          }
        }
      }
    }

    //-----------------------------------------

    bool rebuild = false;

    for(int y = 0; y < 10; y++)
      for(int x = 0; x < 10; x++)
        rebuild = rebuild || (countLinks(x, y) == 2);

    return rebuild;
  }

  //-------------------------------------------------------------------------------------------------

  bool possibleCombinations()
  {
    for(int y = 0; y < 10; y++)
      for(int x = 1; x < 9; x++)
        if (_fields[(x-1) + y*10].couldLink(_fields[x + y*10]) && _fields[x + y*10].couldLink(_fields[(x+1) + y*10]))
          return true;

    for(int x = 0; x < 10; x++)
      for(int y = 1; y < 9; y++)
        if (_fields[x + (y-1)*10].couldLink(_fields[x + y*10]) && _fields[x + y*10].couldLink(_fields[x + (y+1)*10]))
          return true;

    return false;
  }

  //-------------------------------------------------------------------------------------------------

  void _initQueuePlaceSpecial(String special, int current, int max)
  {
    for(int retry = 0; retry < 20; retry++)
    {
      int range = (_levelChains / max).toInt();
      int index = current * range + (Math.random() * range).toInt();

      if (_queue[index].special == Special.None)
      {
        _queue[index].special = special;
        return;
      }
    }
  }

  void initQueue()
  {
    _queue = new List<Field>();

    for(int i = 0; i < _levelChains; i++)
    {
      int color = _colors[(Math.random() * _colors.length).toInt()];
      int direction = (Math.random() * 2).toInt();

      _queue.add(new Field(color, direction));
    }

    for(int i = 0; i < _levelLocks * 2; i++)
      _initQueuePlaceSpecial("Lock${(i % _levelLocks) + 1}", i, _levelLocks * 2);  // Lock1, Lock2, Lock3, ...

    for(int i = 0; i < _levelJokers; i++)
      _initQueuePlaceSpecial(Special.Joker, i, _levelJokers);

    for(int i = 0; i < _levelBlocks; i++)
      _initQueuePlaceSpecial(Special.Block, i, _levelBlocks);

    for(int i = 0; i < _levelDoubles; i++)
      _initQueuePlaceSpecial(Special.Double, i, _levelDoubles);

    for(int i = 0; i < _levelQuints; i++)
      _initQueuePlaceSpecial(Special.Quint, i, _levelQuints);
  }

  //-------------------------------------------------------------------------------------------------

  void initField()
  {
    _fields = new List<Field>();

    bool rebuild = true;

    while(rebuild)
    {
      _fields.clear();

      for(int f = 0; f < 100; f++)
      {
       int color = _colors[(Math.random() * _colors.length).toInt()];
       int direction = (Math.random() * 2).toInt();

        _fields.add(new Field(color, direction));
      }

      rebuild = clearCombinations();
    }
  }

  //-------------------------------------------------------------------------------------------------

  bool shuffleField()
  {
    if (_animationRunning || _status != BoardStatus.Playing)
      return false;

    bool rebuild = true;

    _animationRunning = true;

    while (rebuild)
    {
      for(int f = 0; f < _fields.length; f++)
      {
        Field field = _fields[f];
        field.linked = false;
        field.linkedJoker = false;
        field.updateDisplayObjects(_chainLayer, _linkLayer, _specialLayer);

        field.color =  _colors[(Math.random() * _colors.length).toInt()];
        field.direction = (Math.random() * 2).toInt();
      }

      rebuild = clearCombinations() || (possibleCombinations() == false);
    }

    Sound bonusUniversal = Sounds.resource.getSound("BonusUniversal");
    bonusUniversal.play();

    ValueCounter completeCounter = new ValueCounter();

    for(int x = 0; x < 10; x++)
    {
      for(int y = 0; y < 10; y++)
      {
        num delay = x * 0.06;

        Field field = _fields[x + y * 10];
        field.sinScale = 0.0;

        Tween tween = new Tween(field, 0.2, Transitions.linear);
        tween.animateValue((v) => field.sinScale = v, 0.0, 1.0);
        tween.delay = delay;

        tween.onStart = ()
        {
          field.updateDisplayObjects(_chainLayer, _linkLayer, _specialLayer);
        };

        tween.onComplete = ()
        {
          if (completeCounter.increment() == 100)
          {
            _updateLinks();
            _processCombinations();
            _mouseBuffer.clear();
          }
        };

        Juggler.instance.add(tween);
      }
    }

    return true;
  }

  //-------------------------------------------------------------------------------------------------

  void _updateLinks()
  {
    for(int y = 0; y < 10; y++)
    {
      for(int x = 0; x < 10; x++)
      {
        Field field = _fields[x + y * 10];
        Field fieldEast = (x < 9) ? _fields[x + 1 + y * 10] : null;
        Field fieldSouth = (y < 9) ? _fields[x + (y + 1) * 10] : null;

        bool linked = false;
        bool linkedJoker = false;

        if (field.canLinkHorizontal(fieldEast))
        {
          linked = true;
          linkedJoker = (field.special == Special.Joker || fieldEast.special == Special.Joker);
        }

        if (field.canLinkVertical(fieldSouth))
        {
          linked = true;
          linkedJoker = (field.special == Special.Joker || fieldSouth.special == Special.Joker);
        }

        if (field.linked != linked || field.linkedJoker != linkedJoker)
        {
          field.linked = linked;
          field.linkedJoker = linkedJoker;
          field.updateDisplayObjects(_chainLayer, _linkLayer, _specialLayer);
        }
      }
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _processCombinationsExplosion(ValueCounter animationCounter, int x, int y, int length, int dx, int dy)
  {
    _animationRunning = true;
    animationCounter.increment(length);

    int factor = 1;

    for(int l = 0; l < length; l++)
    {
      Field field = _fields[x + l * dx + (y + l * dy) * 10];

      if (field.special == Special.Double) factor = factor * 2;
      if (field.special == Special.Quint) factor = factor * 5;

      int px = x + l * dx;
      int py = y + l * dy;

      Juggler.instance.delayCall(()
      {
        field.empty = true;
        field.updateDisplayObjects(_chainLayer, _linkLayer, _specialLayer);

        Sound chainBlast = Sounds.resource.getSound("ChainBlast");
        chainBlast.play();

        Explosion explosion = new Explosion(field.color, field.direction);
        explosion.x = px * 50;
        explosion.y = py * 50;

        Juggler.instance.add(explosion);
        _explosionLayer.addChild(explosion);

        processSpecial(field);

        //---------------------------------

        if (animationCounter.decrement() == 0)
          _fillEmptyFields();

      }, 0.1 + l * 0.1);
    }

    dispatchEvent(new BoardEvent(BoardEvent.Explosion, { "Length" : length, "Factor" : factor }));
  }

  void _processCombinations()
  {
    _animationRunning = false;
    ValueCounter animationCounter = new ValueCounter();

    //------------------------------------------------------------------------------
    // check horizontal positions

    for(int y = 0; y < 10; y++)
    {
      for(int x = 0; x < 10; )
      {
        int length =  1;

        while(x + length < 10 && _fields[x + length - 1 + y * 10].canLinkHorizontal(_fields[x + length + y * 10]))
          length++;

        if (length >= 3)
          _processCombinationsExplosion(animationCounter, x, y, length, 1, 0);

        x = x + length;
      }
    }

    //------------------------------------------------------------------------------
    // check vertical positions

    for(int x = 0; x < 10; x++)
    {
      for(int y = 0; y < 10; )
      {
        int length =  1;

        while(y + length < 10 && _fields[x + (y + length - 1) * 10].canLinkVertical(_fields[x + (y + length) * 10]))
          length++;

        if (length >= 3)
          _processCombinationsExplosion(animationCounter, x, y, length, 0, 1);

        y = y + length;
      }
    }

    //------------------------------------------------------------------------------
    // no explosions and finalizing or timeouting?

    if (animationCounter.value == 0)
    {
      if (_status == BoardStatus.Finalizing)
        dispatchEvent(new BoardEvent(BoardEvent.Finalized, null));

      if (_status == BoardStatus.Timeouting)
        dispatchEvent(new BoardEvent(BoardEvent.Timeouted, null));

      if (_status == BoardStatus.Playing && possibleCombinations() == false)
        shuffleField();
    }
  }

  //-------------------------------------------------------------------------------------------------

  void processSpecial(Field field)
  {
    if (field.special.indexOf("Lock") == 0)
    {
      int lockNumber = Math.parseInt(field.special.substring(4, 5)) - 1;
      Lock lock = _locks[lockNumber];

      Bitmap special = Grafix.getSpecial(field.special);
      special.x = field.x;
      special.y = field.y;
      addChild(special);

      Tween tween = new Tween(special, 0.5, Transitions.easeOutCubic);
      tween.animate("x" , lock.x);
      tween.animate("y" , lock.y - 10);
      tween.onComplete = () => removeChild(special);

      Juggler.instance.add(tween);
      Juggler.instance.delayCall(() => openLock(lockNumber), 0.5);
    }
  }

  //-------------------------------------------------------------------------------------------------

  void openLock(int lockNumber)
  {
    Lock lock = _locks[lockNumber];
    BoardEvent boardEvent;

    if (lock.locked)
    {
      boardEvent = new BoardEvent(BoardEvent.Unlocked, { "Type" : "SingleLocked", "Position" : new Point(lock.x + 20, lock.y) });

      Sound unlock = Sounds.resource.getSound("Unlock");
      unlock.play();
    }
    else
    {
      boardEvent = new BoardEvent(BoardEvent.Unlocked, { "Type" : "SingleUnlocked", "Position" : new Point(lock.x + 20, lock.y) });
    }

    dispatchEvent(boardEvent);

    lock.locked = false;
    lock.showLocked(false);

    //---------------------------------

    bool allUnlocked = true;

    for(int i = 0; i < _locks.length; i++)
      allUnlocked = allUnlocked && (_locks[i].locked == false);

    if (allUnlocked)
    {
      Sound bonusAllUnlock = Sounds.resource.getSound("BonusAllUnlock");
      bonusAllUnlock.play();

      for(int i = 0; i < _locks.length; i++)
      {
        _locks[i].locked = true;
        Juggler.instance.delayCall(() => _locks[(i + lockNumber) % _locks.length].showHappy(), i * 0.2);
      }

      Juggler.instance.delayCall(() => dispatchEvent(new BoardEvent(BoardEvent.Unlocked, { "Type" : "All", "Position" : new Point(280, 550) })), 0.75);
    }
  }

  //-------------------------------------------------------------------------------------------------

  void _fillEmptyFields()
  {
    Field fieldTarget, fieldSource, fieldSourceWest;

    ValueCounter animationCounter = new ValueCounter();

    for(int x = 0; x < 10; x++)
    {
      int target = 9;
      int source = 8;

      while(target >= 0)
      {
        while (target >= 0 && _fields[x + target * 10].empty == false)
        {
          target--;
          source--;
        }

        while (source >= 0 && _fields[x + source * 10].empty == true)
        {
          source--;
        }

        if (target >= 0)
        {
          if (source >= 0)
          {
            fieldSource = _fields[x + source * 10];
            fieldSourceWest = (x > 0) ?  _fields[x - 1 + source * 10] : null;

            if (fieldSource.canLinkHorizontal(fieldSourceWest))
            {
              fieldSourceWest.linked = false;
              fieldSourceWest.updateDisplayObjects(_chainLayer, _linkLayer, _specialLayer);
            }

            fieldSource.linked = false;
            fieldSource.empty = true;
            fieldSource.updateDisplayObjects(_chainLayer, _linkLayer, _specialLayer);
          }
          else
          {
            if (_queue.length > 0)
            {
              fieldSource = _queue[0];
              _queue.removeRange(0, 1);
            }
            else
            {
              fieldSource = new Field(_colors[(Math.random() *  _colors.length).toInt()], (Math.random() * 2).toInt());
            }
          }

          fieldTarget = _fields[x + target * 10];
          fieldTarget.color = fieldSource.color;
          fieldTarget.direction = fieldSource.direction;
          fieldTarget.special = fieldSource.special;
          fieldTarget.linked = false;
          fieldTarget.empty = false;
          fieldTarget.x = 50 * x + 25;
          fieldTarget.y = 50 * source + 25;
          fieldTarget.updateDisplayObjects(_chainLayer, _linkLayer, _specialLayer);

          animationCounter.increment();

          Tween tween = new Tween(fieldTarget, 0.1, Transitions.linear);
          tween.animate("y", 50 * target + 25);
          tween.onComplete = ()
          {
            if (animationCounter.decrement() == 0)
            {
              _updateLinks();
              _processCombinations();
              _checkMouseBuffer();
            }
          };

          Juggler.instance.add(tween);
        }
      }
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _onMouseDown(MouseEvent me)
  {
    if (me.target == _chainLayer && this.mouseEnabled)
    {
      int x = Math.min(me.localX / 50, 9).toInt();
      int y = Math.min(me.localY / 50, 9).toInt();

      Point p = new Point(x, y);

      _mouseBuffer.add(p);
      _checkMouseBuffer();
    }
  }

  void _checkMouseBuffer()
  {
    while(_status == BoardStatus.Playing && _animationRunning == false && _mouseBuffer.length > 0)
    {
      Point p = _mouseBuffer[0];
      _mouseBuffer.removeRange(0, 1);

      int x = p.x.toInt();
      int y = p.y.toInt();

      Field field = _fields[x + y * 10];
      Field fieldWest = (x > 0) ? _fields[x - 1 + y * 10] : null;
      Field fieldEast = (x < 9) ? _fields[x + 1 + y * 10] : null;
      Field fieldNorth = (y > 0) ? _fields[x + (y - 1) * 10] : null;
      Field fieldSouth = (y < 9) ? _fields[x + (y + 1) * 10] : null;

      bool playChainLink = false;

      if (field.special == Special.Block)
      {
        Sound chainError = Sounds.resource.getSound("ChainError");
        chainError.play();
        continue;
      }

      //--------------------------------------------
      // update links on North and West field

      if (field.canLinkVertical(fieldNorth))
      {
        fieldNorth.linked = false;
        fieldNorth.updateDisplayObjects(_chainLayer, _linkLayer, _specialLayer);
      }

      if (field.canLinkHorizontal(fieldWest))
      {
        fieldWest.linked = false;
        fieldWest.updateDisplayObjects(_chainLayer, _linkLayer, _specialLayer);
      }

      //--------------------------------------------
      // rotate and update links on field

      field.direction = 1 - field.direction;
      field.linked = false;
      field.linkedJoker = false;

      Sound chainRotate = Sounds.resource.getSound("ChainRotate");
      chainRotate.play();

      if (field.canLinkHorizontal(fieldEast))
      {
        field.linked = true;
        field.linkedJoker = (field.special == Special.Joker || fieldEast.special == Special.Joker);
      }

      if (field.canLinkVertical(fieldSouth))
      {
        field.linked = true;
        field.linkedJoker = (field.special == Special.Joker || fieldSouth.special == Special.Joker);
      }

      field.updateDisplayObjects(_chainLayer, _linkLayer, _specialLayer);

      playChainLink = playChainLink || field.linked;

      //--------------------------------------------
      // update links on North and West field

      if (field.canLinkVertical(fieldNorth))
      {
        fieldNorth.linked = true;
        fieldNorth.linkedJoker = (field.special == Special.Joker || fieldNorth.special == Special.Joker);
        fieldNorth.updateDisplayObjects(_chainLayer, _linkLayer, _specialLayer);
        playChainLink = true;
      }

      if (field.canLinkHorizontal(fieldWest))
      {
        fieldWest.linked = true;
        fieldWest.linkedJoker = (field.special == Special.Joker || fieldWest.special == Special.Joker);
        fieldWest.updateDisplayObjects(_chainLayer, _linkLayer, _specialLayer);
        playChainLink = true;
      }

      //--------------------------------------------

      if (playChainLink)
      {
        Sound chainLink = Sounds.resource.getSound("ChainLink");
        chainLink.play();
      }

      //--------------------------------------------

      _processCombinations();
    }
  }

}