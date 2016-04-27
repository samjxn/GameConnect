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
      _idBikeMap[snapshot.senderId]._setNextDirection(snapshot);
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
    _ctx.font = "100px Monospace";
    _ctx.textAlign = "center";
    _ctx.fillText("LIGHT BIKE", _canvas.width ~/ 2, _canvas.height ~/ 2);
    _ctx.font = "25px Monospace";

    _ctx.fillText("Press A to start, Press B to quit.", _canvas.width ~/ 2,
        _canvas.height ~/ 2 + 200);

    _startDisplayed = true;
  }

  _displayGameEndMessage() {
    _renderer.clear();

    _ctx.fillStyle = "DeepPink";
    _ctx.font = "100px Monospace";
    _ctx.textAlign = "center";
    _ctx.fillText("Game Over", _canvas.width ~/ 2, _canvas.height ~/ 2);

    _ctx.font = "25px Monospace";

    var verticalOffset = 200;
    _bikes.forEach((Bike s) {
      var scoreText = "${s.name}:  ${s.getScore()}";
      _ctx.fillText(
          scoreText, _canvas.width ~/ 2, _canvas.height ~/ 2 + verticalOffset);
      verticalOffset += 50;
    });

    _ctx.fillStyle = "black";
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
      if (snake.isDead) {
        _playersInGame--;
      }
    });

    _renderer.drawBoard(_board);
    drawLabels();
  }

  drawLabels() {
    var i = 0;

    var cellOffset = 3;

    var labelOffsets = [
      new Point(0, cellOffset),
      new Point(-cellOffset, 0),
      new Point(0, -cellOffset),
      new Point(cellOffset, 0)
    ];

    var justification = ["right", "right", "left", "left"];
    _bikes
        .where((Bike s) => !s.isDead && s._dir == null)
        .toList()
        .forEach((Bike s) {
      _renderer.drawLabel(
          s.name, s.head + labelOffsets[i], s._color, justification[i]);
      i++;
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

  drawBoard(LBGameBoard board) {
    board._lowerCollisionMap.forEach((Point coord, dynamic object) {
      if (object is Bike) {
        Bike bike = object;
        drawCell(coord, bike._color);
      }
    });
  }

  drawLabel(String label, Point point, String color, String alignment) {
    _context.font = "25px Monospace";
    _context.strokeStyle = 'white';
    _context.lineWidth = 5;
    _context.fillStyle = color;
    _context.textAlign = alignment;

    _context.strokeText(label, point.x * cellSize, point.y * cellSize);
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
  }
}

class Bike {
  static int _count;

  static const int START_LENGTH = 2;
  static const int JUMP_COOL_DOWN = 250;
  static const int MAX_JUMP_TIME = 10;

  static const Point LEFT = const Point(-1, 0);
  static const Point RIGHT = const Point(1, 0);
  static const Point UP = const Point(0, -1);
  static const Point DOWN = const Point(0, 1);

  Point _dir;
  Point _nextDir;

  // coordinates of the body segments
  List<Point> trail;
  bool hasMoved;
  bool isDead;
  String _color;
  Point get head => trail.first;
  Point get tail => trail.last;
  LBGameBoard _board;
  String name;
  int _id;

  bool jumping;
  int jumpCoolOff;
  int jumpTime;

  Bike(LBGameBoard this._board, this.name) {
    _id = _count;
    _count++;
    trail = [];
    hasMoved = false;
    isDead = false;
    jumping = false;
    jumpCoolOff = 0;
    jumpTime = MAX_JUMP_TIME;

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

    //                     LEFT       RIGHT
    // UP      ( 0, -1), (-1,  0),   ( 1,  0)
    // RIGHT   ( 1,  0), ( 0, -1),   ( 0,  1)
    // DOWN    ( 0,  1), (-1,  0),   ( 1,  0)
    // LEFT    (-1,  0), ( 0,  1),   ( 0, -1)
  }

  void _setNextDirection(ControllerSnapshot snapshot) {
    if (snapshot == null) {
      return;
    }

    var dpadDir = snapshot?.dpadInput;

    if (dpadDir == "1" && _dir != DOWN) {
      _nextDir = UP;
    }

    if (dpadDir == "2" && _dir != LEFT) {
      _nextDir = RIGHT;
    }

    if (dpadDir == "3" && _dir != UP) {
      _nextDir = DOWN;
    }

    if (dpadDir == "4" && _dir != RIGHT) {
      _nextDir = LEFT;
    }

    if (_dir != null &&
        !this.jumping &&
        jumpCoolOff == 0 &&
        snapshot.aPressed) {
      jumping = true;
    } else if (_dir != null && this.jumping && !snapshot.aPressed) {
      jumping = false;
       _resetJumpCoolOff();
    }

    /*
    if (snapshot.tilt < -1 * THRESHOLD) {
      _turnLeft();
    } else if (snapshot.tilt > THRESHOLD) {
      _turnRight();
    }
     */
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
    }

    _grow();
    hasMoved = true;

    if (jumping) {
      jumpTime--;
      if (jumpTime <= 0) {
        jumping = false;
        _resetJumpCoolOff();
      }
    } else if (jumpCoolOff > 0) {
      jumpCoolOff--;
    }
  }

  kill() {
    this.isDead = true;
    trail.forEach((bodyPoint){
      _board._lowerCollisionMap.remove(bodyPoint);
      _board._upperCollisionMap.remove(bodyPoint);
    });
  }

  _deathImpending() {
    var nextPoint = head + _dir;

    var nextCellOccupant =  _getReleventCollisionMap()[nextPoint];

    if (nextCellOccupant is Bike) {
      return true;
    }

    if (nextPoint.x < 1 ||
        nextPoint.y < 1 ||
        nextPoint.x >= _board._rightEdgeX ||
        nextPoint.y >= _board._bottomEdgeY) {
      return true;
    }

    return false;
  }

  getScore() {
    return trail.length - START_LENGTH;
  }

  Map<Point, Bike>_getReleventCollisionMap() {
    if (this.jumping) {
      return _board._upperCollisionMap;
    }
    else {
      return _board._lowerCollisionMap;
    }
  }

  _resetJumpCoolOff(){
    this.jumpCoolOff = JUMP_COOL_DOWN * (1 - (this.jumpTime ~/ MAX_JUMP_TIME));
    this.jumpTime = MAX_JUMP_TIME;
  }
}
