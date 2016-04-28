part of game_connect_client.src.games;

class LightBikeGame {
  GameConnectClientActions _actions;
  GameConnectClientApi _api;

  CanvasElement _canvas;
  _LBCellRenderer _renderer;
  List<Bike> _bikes;
  int _playersInGame;

  bool _startDisplayed;
  bool _scoresUpdated;

  CanvasRenderingContext2D _ctx;

  Map<String, Player> _idPlayerMap;
  Map<String, Bike> _idBikeMap;
  Map<Bike, Player> _bikePlayerMap;

  final int _CELL_SIZE = 5;
  static const num GAME_SPEED = 25;

  var _lastTimeStamp;

  LBGameBoard _board;

  var _gameState;

  var _bikeMoveTimer;

  LightBikeGame() {
    _lastTimeStamp = 0;
    _bikes = [];
    _idPlayerMap = {};
    _idBikeMap = {};
    _bikePlayerMap = {};
    _playersInGame = 0;
    _startDisplayed = false;
    _scoresUpdated = false;
  }

  void onDidMount(List<Player> players, GameConnectClientApi api,
      GameConnectClientActions actions) {
    this._api = api;
    this._actions = actions;

    this._canvas = querySelector('#game-canvas');
    this._ctx = _canvas.getContext('2d');

    this._renderer = new _LBCellRenderer(_canvas, _ctx, _CELL_SIZE);

    List gamePlayers = players.length > 4 ? players.sublist(0, 4) : players;
    gamePlayers.forEach((Player p) {
      _idPlayerMap[p.clientId] = p;
    });

    _playersInGame = _idPlayerMap.length < 4 ? _idPlayerMap.length : 4;
    _board = new LBGameBoard(_canvas, _CELL_SIZE);

    resetGame();
  }

  void resetGame() {
    _gameState = !_startDisplayed ? _displayStartMessage : _drawGameUpdate;

    _board.reset();
    _scoresUpdated = false;

    Bike._count = 0;
    _bikes.clear();

    _idPlayerMap.forEach((_, Player p) {
      Bike snake = new Bike(_board, p.displayName);
      _bikes.add(snake);
      _idBikeMap[p.clientId] = snake;
      _bikePlayerMap[snake] = p;
    });

    _playersInGame = _idPlayerMap.length;
  }

  onSnapshotReceived(ControllerSnapshot snapshot) async {
    if (_gameState == _displayStartMessage) {
      if (snapshot.aPressed) {
        _gameState = _drawGameUpdate;
        _bikeMoveTimer =
            new Timer(const Duration(seconds: 2), _moveStationarySnakes);
      }
      if (snapshot.bPressed) {
        // quit game
        _api.sendQuitGameMessage();
        _actions.onQuit();
      }
    } else if (_gameState == _displayGameEndMessage) {
      if (snapshot.aPressed) {
        _bikeMoveTimer =
            new Timer(const Duration(seconds: 2), _moveStationarySnakes);
        resetGame();
      }
      if (snapshot.bPressed) {
        // quit game
        _api.sendQuitGameMessage();
        _actions.onQuit();
      }
    } else if (_gameState == _drawGameUpdate) {
      _idBikeMap[snapshot.senderId]._respondToControllerInput(snapshot);
    }
  }

  void run() {
    window.animationFrame.then(update);
  }

  endGame() {
    if (!_scoresUpdated) {
      _scoresUpdated = true;
      _idBikeMap.forEach((String clientId, Bike snake) {
        this._api.sendHighScore(clientId, snake.getScore());
      });
    }
    _gameState = _displayGameEndMessage;
  }

  void update(num timestamp) {
    final num diff = timestamp - _lastTimeStamp;

    if (diff > GAME_SPEED) {
      _lastTimeStamp = timestamp;

      _gameState();

      if (_checkForEndGame()) {
        endGame();
      }
    }

    run();
  }

  _moveStationarySnakes() {
    _bikes.forEach((Bike s) {
      if (s._dir == null) {
        s._setInitialDirection();
      }
    });
  }

  _checkForEndGame() {
    if (_idPlayerMap.length == 1 && _playersInGame <= 0) {
      return true;
    } else if (_idPlayerMap.length > 1 && _playersInGame == 1) {
      return true;
    }

    return false;
  }

  _displayStartMessage() {
    _renderer.clear();

    _ctx.fillStyle = "DeepPink";
    _ctx.font = "100px Orbitron";
    _ctx.textAlign = "center";
    _ctx.fillText("LIGHT BIKE", _canvas.width ~/ 2, _canvas.height ~/ 2);
    _ctx.font = "25px Orbitron";

    _ctx.fillText("Press A to start, Press B to quit.", _canvas.width ~/ 2,
        _canvas.height ~/ 2 + 200);

    _startDisplayed = true;
  }

  _displayGameEndMessage() {

    _winnersName() {
      String name;
      _bikes.forEach((Bike b) {
        if (!b.isDead) {
          name = b.name;
        }
      });
      return name.toUpperCase();
    }

    _renderer.clear();

    var titleText = _idPlayerMap.length > 1 ? _winnersName() + " WINS" : "GAME OVER";

    _ctx.fillStyle = "DeepPink";
    _ctx.font = "100px Orbitron";
    _ctx.textAlign = "center";
    _ctx.fillText(titleText, _canvas.width ~/ 2, _canvas.height ~/ 2);

    _ctx.font = "25px Orbitron";

    var verticalOffset = 200;
    _bikes.forEach((Bike s) {
      _ctx.textAlign = "right";
      _ctx.fillText(s.name + ":", _canvas.width ~/ 2,
          _canvas.height ~/ 2 + verticalOffset);
      _ctx.textAlign = "left";
      _ctx.fillText("     ${s.getScore()}", _canvas.width ~/ 2,
          _canvas.height ~/ 2 + verticalOffset);

      verticalOffset += 50;
    });

    _ctx.textAlign = "center";
    _ctx.fillStyle = "DeepPink";
    _ctx.fillText("Press A to restart, Press B to quit.", _canvas.width ~/ 2,
        _canvas.height ~/ 2 + 400);
  }

  _drawGameUpdate() {
    _renderer.clear();

    // mark each snake as 'has not moved'
    _bikes.forEach((snake) {
      snake.hasMoved = false;
    });

    //move snakes
    _bikes.where((snake) => !snake.isDead).forEach((snake) {
      snake.move();
      if (snake.isBoosting) {
        snake.move();
      }
      if (snake.isDead) {
        _playersInGame--;
      }
    });

    _renderer.drawLowerBoard(_board);
    _renderer.drawUpperBoard(_board);
    drawLabels();
  }

  drawLabels() {
    var labelOffsets = [
      new Point(0, 5),
      new Point(-5, 0),
      new Point(0, -5),
      new Point(5, 0)
    ];
    var justification = ["left", "right", "right", "left"];

    _bikes.forEach((Bike b) {
      if (b._dir == null) {
        _renderer.drawLabel(b.name, b.head + labelOffsets[b._id], "DeepPink",
            justification[b._id]);
      }
    });
  }
}

class _LBCellRenderer {
  int cellSize;
  CanvasRenderingContext2D _context;
  CanvasElement _canvasElement;

  _LBCellRenderer(CanvasElement this._canvasElement,
      CanvasRenderingContext2D this._context, this.cellSize);

  void clear() {
    var lineWidth = cellSize;
    var x = lineWidth;
    var y = lineWidth;

    _context
      ..fillStyle = "black"
      ..lineWidth = cellSize
      ..strokeStyle = "DeepPink"
      ..fillRect(0, 0, _canvasElement.width - 2, _canvasElement.height - 2)
      ..strokeRect(x ~/ 2, y ~/ 2, _canvasElement.width - (x),
          _canvasElement.height - (x));
  }

  void drawCell(Point coords, String color) {
    _context.fillStyle = color;

    final int x = coords.x * cellSize;
    final int y = coords.y * cellSize;

    _context.fillRect(x, y, cellSize, cellSize);
  }

  void drawUpperLevelCell(Point coords, String color) {
    _context.fillStyle = color;

    final int x = coords.x * cellSize;
    final int y = coords.y * cellSize;

    _context.fillRect(x + 2, y + 2, cellSize - 2, cellSize - 2);
  }

  void drawFood(Point coords, String color) {
    _context.fillStyle = color;
    _context.strokeStyle = "white";
    _context.lineWidth = 1;

    final radius = (cellSize ~/ 2);
    final int x = coords.x * cellSize + radius;
    final int y = coords.y * cellSize + radius;

    _context.beginPath();
    _context.arc(x, y, radius, 0, 2 * PI, false);
    _context.fillStyle = color;
    _context.fill();
  }

  drawLowerBoard(LBGameBoard board) {
    _drawBoard(board._lowerCollisionMap, drawCell);
  }

  drawUpperBoard(LBGameBoard board) {
    _drawBoard(board._upperCollisionMap, drawUpperLevelCell);
  }

  _drawBoard(Map<Point, Bike> collisionMap, drawFunction) {
    collisionMap.forEach((Point coord, Bike bike) {
      if (coord == bike.head) {
        var color = bike.boostCoolOff == 0 ? "DeepPink" : "white";
        drawFunction(coord, color);
      } else if (coord == bike.trail[1]) {
        var color = bike.jumpCoolOff == 0 ? "DeepPink" : "white";
        drawFunction(coord, color);
      } else {
        drawFunction(coord, bike._color);
      }
    });
  }

  drawLabel(String label, Point point, String color, String alignment) {
    _context.font = "25px Orbitron";
    _context.fillStyle = color;
    _context.textAlign = alignment;

    _context.fillText(label, point.x * cellSize, point.y * cellSize);
  }
}

class LBGameBoard {
  int _rightEdgeX;
  int _bottomEdgeY;
  Map<Point, Bike> _lowerCollisionMap;
  Map<Point, Bike> _upperCollisionMap;
  Random rand;

  LBGameBoard(canvas, cell_size) {
    _rightEdgeX = canvas.width ~/ cell_size;
    _bottomEdgeY = canvas.height ~/ cell_size;
    _lowerCollisionMap = {};
    _upperCollisionMap = {};
    rand = new Random();
  }

  reset() {
    _lowerCollisionMap.clear();
    _upperCollisionMap.clear();
  }
}

class Bike {
  static int _count;

  static const int START_LENGTH = 2;
  static const int JUMP_COOL_DOWN = 150;
  static const int BOOST_COOL_DOWN = 250;
  static const int DEFAULT_JUMP_TIME = 30;
  static const int DEFAULT_BOOST_TIME = 50;

  static const Point LEFT = const Point(-1, 0);
  static const Point RIGHT = const Point(1, 0);
  static const Point UP = const Point(0, -1);
  static const Point DOWN = const Point(0, 1);

  Point _dir;
  Point _nextDir;

  // coordinates of the body segments
  Timer _canTurnTimer;
  List<Point> trail;
  bool hasMoved;
  bool isDead;
  String _color;
  Point get head => trail.first;
  Point get tail => trail.last;
  LBGameBoard _board;
  String name;
  int _id;

  bool isJumping;
  bool isBoosting;
  bool _canTurn;
  int jumpCoolOff;
  int boostCoolOff;
  int jumpTime;
  int boostTime;

  Bike(LBGameBoard this._board, this.name) {
    _id = _count;
    _count++;
    trail = [];
    hasMoved = false;
    isDead = false;
    isJumping = false;
    isBoosting = false;
    _canTurn = true;
    jumpCoolOff = 0;
    boostCoolOff = 0;
    jumpTime = DEFAULT_JUMP_TIME;

    boostTime = DEFAULT_BOOST_TIME;

    _dir = null;
    trail = _resetTrail();
    _initCollisions();
    _setColor();
  }

  void _initCollisions() {
    trail.forEach((Point bodyPoint) {
      _board._lowerCollisionMap[bodyPoint] = this;
    });
  }

  void _setInitialDirection() {
    var x = head - trail[1];

    _nextDir = x;
  }

  void _setColor() {
    _color = ["red", "blue", "gold", "green"][(_id) % 4];
  }

  _resetTrail() {
    var newBody = [];

    var x = 0;
    var y = 0;
    var xOffset = 0;
    var yOffset = 0;

    switch (_id) {
      case 0:
        x = 2;
        y = 2;
        xOffset = 1;
        break;
      case 1:
        x = _board._rightEdgeX - 2;
        y = 2;
        yOffset = 1;
        break;
      case 2:
        x = _board._rightEdgeX - 2;
        y = _board._bottomEdgeY - 2;
        xOffset = -1;
        break;
      case 3:
        x = 2;
        y = _board._bottomEdgeY - 1;
        yOffset = -1;
        break;
    }

    for (int i = 0; i < START_LENGTH; i++) {
      var bodyPoint = new Point(x, y);
      newBody.add(bodyPoint);
      x += xOffset;
      y += yOffset;
    }

    return newBody.reversed.toList(growable: true);
  }

  void turnLeft() {
    if (_dir == null) {
      return;
    }

    _nextDir = new Point(_dir.y, -1 * _dir.x);
  }

  void turnRight() {
    if (_dir == null) {
      return;
    }

    _nextDir = new Point(-1 * _dir.y, _dir.x);
  }

  void _respondToControllerInput(ControllerSnapshot snapshot) {
    if (snapshot == null) {
      return;
    }

    _respondToTilt(int tiltValue) {
      tiltValue ??= 0;

      if (tiltValue < -3) {
        if (_canTurn) {
          _triggerTurnTimer();
          turnLeft();
        }
        _canTurn = false;
      } else if (tiltValue > 3) {
        if (_canTurn) {
          _triggerTurnTimer();
          turnRight();
        }
      } else {
        _canTurnTimer?.cancel();
        _canTurnTimer = null;
        _canTurn = true;
      }
    }

    var dpadDir = snapshot.dpadInput;

    if (dpadDir == "2") {
      turnRight();
    }
    if (dpadDir == "4") {
      turnLeft();
    }

    if (_dir != null &&
        snapshot.aPressed &&
        !this.isJumping &&
        jumpCoolOff == 0) {
      isJumping = true;
    }
    if (_dir != null &&
        snapshot.bPressed &&
        !this.isBoosting &&
        boostCoolOff == 0) {
      isBoosting = true;
    }

    _respondToTilt(snapshot.tilt);
  }

  _triggerTurnTimer() {
    _canTurn = false;
    _canTurnTimer =
        new Timer(const Duration(milliseconds: 500), (() => _canTurn = true));
  }

  void _grow() {
    _getReleventCollisionMap()[head + _dir] = this;
    trail.insert(0, head + _dir); // updates head
  }

  void move() {
    _dir = _nextDir;

    if (_dir == null) {
      hasMoved = true;
      return;
    }

    if (_deathImpending()) {
      this.kill();
      return;
    }

    _grow();
    hasMoved = true;

    if (isJumping) {
      jumpTime--;
      if (jumpTime <= 0) {
        isJumping = false;
        _resetJumpCoolOff();
      }
    } else if (jumpCoolOff > 0) {
      jumpCoolOff--;
    }
    if (isBoosting) {
      boostTime--;

      if (_deathImpending()) {
        this.kill();
        return;
      }
      _grow();

      if (boostTime <= 0) {
        isBoosting = false;
        _resetBoostCoolOff();
      }
    } else if (boostCoolOff > 0) {
      boostCoolOff--;
    }
  }

  kill() {
    this.isDead = true;
    trail.forEach((bodyPoint) {
      _board._lowerCollisionMap.remove(bodyPoint);
      _board._upperCollisionMap.remove(bodyPoint);
    });
  }

  _deathImpending() {
    var nextPoint = head + _dir;

    var nextCellOccupant = _getReleventCollisionMap()[nextPoint];

    if (nextCellOccupant is Bike) {
      return true;
    }

    if (nextPoint.x < 1 ||
        nextPoint.y < 1 ||
        nextPoint.x >= _board._rightEdgeX - 1 ||
        nextPoint.y >= _board._bottomEdgeY - 1) {
      return true;
    }

    return false;
  }

  getScore() {
    return trail.length - START_LENGTH;
  }

  Map<Point, Bike> _getReleventCollisionMap() {
    if (this.isJumping) {
      return _board._upperCollisionMap;
    } else {
      return _board._lowerCollisionMap;
    }
  }

  _resetJumpCoolOff() {
    this.jumpCoolOff = JUMP_COOL_DOWN;
    this.jumpTime = DEFAULT_JUMP_TIME;
  }

  _resetBoostCoolOff() {
    this.boostCoolOff = BOOST_COOL_DOWN;
    this.boostTime = DEFAULT_JUMP_TIME;
  }
}
