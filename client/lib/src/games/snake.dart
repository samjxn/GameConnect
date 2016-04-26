part of game_connect_client.src.games;

// This would be better if it were named "Spaghetti".

class SnakeGame {

  GameConnectClientActions _actions;
  GameConnectClientApi _api;

  CanvasElement _canvas;
  _CellRenderer _renderer;
  List<Snake> _snakes;
  int _playersInGame;

  bool _startDisplayed;
  bool _scoresUpdated;

  CanvasRenderingContext2D _ctx;

  Map<String, Player> _idPlayerMap;
  Map<String, Snake> _idSnakeMap;
  Map<Snake, Player> _snakePlayerMap;

  final int _CELL_SIZE = 10;
  static const num GAME_SPEED = 100;
  num _lastTimeStamp = 0;

  GameBoard _board;

  var _gameState;

  var _snakeMoveTimer;


  SnakeGame() {
    _snakes = [];
    _idPlayerMap = {};
    _idSnakeMap = {};
    _snakePlayerMap = {};
    _playersInGame = 0;
    _startDisplayed = false;
    _scoresUpdated = false;
  }

  void onDidMount(List<Player> players, GameConnectClientApi api, GameConnectClientActions actions) {

    this._api = api;
    this._actions = actions;

    this._canvas = querySelector('#game-canvas');
    this._ctx = _canvas.getContext('2d');

    this._renderer = new _CellRenderer(_canvas, _ctx, _CELL_SIZE);

    List gamePlayers = players.length > 4 ? players.sublist(0, 4) : players;
    gamePlayers.forEach((Player p) {
      _idPlayerMap[p.clientId] = p;
    });

    _playersInGame = _idPlayerMap.length < 4 ? _idPlayerMap.length : 4;
    _board = new GameBoard(_canvas, _CELL_SIZE);

    resetGame();
  }

  void resetGame() {
    _gameState = !_startDisplayed ? _displayStartMessage : _drawGameUpdate;

    _board.reset();
    _board.addFood();
    _scoresUpdated = false;

    Snake._count = 0;
    _snakes.clear();

    _idPlayerMap.forEach((_, Player p) {
      Snake snake = new Snake(_board, p.displayName);
      _snakes.add(snake);
      _idSnakeMap[p.clientId] = snake;
      _snakePlayerMap[snake] = p;
    });

    _playersInGame = _idPlayerMap.length;
  }

  onSnapshotReceived(ControllerSnapshot snapshot) async {

    if (_gameState == _displayStartMessage){

      if (snapshot.aPressed) {
        _gameState = _drawGameUpdate;
        _snakeMoveTimer = new Timer(const Duration(seconds: 2), _moveStationarySnakes);
      }
     if (snapshot.bPressed) {
       // quit game
       _api.sendQuitGameMessage();
       _actions.onQuit();
     }
    }

    else if  (_gameState == _displayGameEndMessage) {
      if (snapshot.aPressed){
        _snakeMoveTimer = new Timer(const Duration(seconds: 2), _moveStationarySnakes);
        resetGame();
      }
      if (snapshot.bPressed) {
        // quit game
        _api.sendQuitGameMessage();
        _actions.onQuit();
      }
    }

    else if (_gameState == _drawGameUpdate) {
      _idSnakeMap[snapshot.senderId]._setNextDirection(snapshot);
    }
  }

  void run() {
    window.animationFrame.then(update);
  }

  endGame() {

    if (!_scoresUpdated) {
      _scoresUpdated = true;
      _idSnakeMap.forEach((String clientId, Snake snake) {
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
    _snakes.forEach((Snake s){
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

    _ctx.fillStyle = "black";
    _ctx.font = "100px Monospace";
    _ctx.textAlign = "center";
    _ctx.fillText("Snake.", _canvas.width ~/ 2, _canvas.height ~/ 2);
    _ctx.font = "25px Monospace";
    _ctx.fillText("(hiss)", _canvas.width ~/ 2 + 75, _canvas.height ~/ 2 + 25);

    _ctx.fillText("Press A to start, Press B to quit.", _canvas.width ~/ 2,
        _canvas.height ~/ 2 + 200);

    _startDisplayed = true;
  }

  _displayGameEndMessage() {

    _renderer.clear();

    _ctx.fillStyle = "black";
    _ctx.font = "100px Monospace";
    _ctx.textAlign = "center";
    _ctx.fillText("Game Over", _canvas.width ~/ 2, _canvas.height ~/ 2);

    _ctx.font = "25px Monospace";

    var verticalOffset = 200;
    _snakes.forEach((Snake s) {
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
    _snakes.forEach((snake) {
      snake.hasMoved = false;
    });

    //move snakes
    _snakes.where((snake) => !snake.isDead).forEach((snake) {
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
    _snakes
        .where((Snake s) => !s.isDead && s._dir == null)
        .toList()
        .forEach((Snake s) {
      _renderer.drawLabel(
          s.name, s.head + labelOffsets[i], s._color, justification[i]);
      i++;
    });
  }
}

class _CellRenderer {
  int cellSize;
  CanvasRenderingContext2D _context;
  CanvasElement _canvasElement;

  _CellRenderer(CanvasElement this._canvasElement,
      CanvasRenderingContext2D this._context, this.cellSize);

  void clear() {
    _context
      ..fillStyle = "white"
      ..fillRect(0, 0, _canvasElement.width - 1, _canvasElement.height - 1);
  }

  void drawCell(Point coords, String color) {
    _context.lineWidth = 1;
    _context.fillStyle = color;
    _context.strokeStyle = "white";

    final int x = coords.x * cellSize;
    final int y = coords.y * cellSize;

    _context.fillRect(x, y, cellSize, cellSize);
    _context.strokeRect(x, y, cellSize, cellSize);
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

  drawBoard(GameBoard board) {
    board._collisionMap.forEach((Point coord, dynamic object) {
      if (object is Snake) {
        Snake snake = object;
        drawCell(coord, snake._color);
      } else if (object is Food) {
        Food food = object;
        drawFood(coord, food.color);
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

class GameBoard {
  int _rightEdgeX;
  int _bottomEdgeY;
  Map<Point, dynamic> _collisionMap;
  Random rand;

  GameBoard(canvas, cell_size) {
    _rightEdgeX = canvas.width ~/ cell_size;
    _bottomEdgeY = canvas.height ~/ cell_size;
    _collisionMap = {};
    rand = new Random();
  }

  addFood() {
    var foodPoint;
    var food = generateNewFood();

    do {
      foodPoint =
          new Point(rand.nextInt(_rightEdgeX), rand.nextInt(_bottomEdgeY));
    } while (_collisionMap[foodPoint] != null);

    _collisionMap[foodPoint] = food;
  }

  reset() {
    _collisionMap.clear();
  }

  Food generateNewFood() {
    int theta = rand.nextInt(100);
    var food;
    if (theta <= 45) {
      food = new Food("purple", 1);
    } else if (theta <= 75) {
      food = new Food("hotpink", 2);
    } else if (theta <= 98) {
      food = new Food("DodgerBlue ", 3);
    } else {
      food = new Food("black", 10);
    }

    return food;
  }
}

class Food {
  String color;
  int growthAmount;

  Food(this.color, this.growthAmount);
}

class Snake {
  static int _count;

  static const int START_LENGTH = 6
  ;
  static const Point LEFT = const Point(-1, 0);
  static const Point RIGHT = const Point(1, 0);
  static const Point UP = const Point(0, -1);
  static const Point DOWN = const Point(0, 1);

  Point _dir;
  Point _nextDir;

  // coordinates of the body segments
  List<Point> _body;
  bool hasMoved;
  bool isDead;
  String _color;
  Point get head => _body.first;
  Point get tail => _body.last;
  GameBoard _board;
  String name;
  int _id;
  int _toGrow;

  Snake(GameBoard this._board, this.name) {
    _id = _count;
    _count++;
    _body = [];
    hasMoved = false;
    isDead = false;
    _toGrow = 0;

    _dir = null;
    _body = _getInitialBody();
    _initBodyCollisions();
    _setColor();
  }

  void _initBodyCollisions() {
    _body.forEach((Point bodyPoint) {
      _board._collisionMap[bodyPoint] = this;
    });
  }

  void _setInitialDirection() {

    var x = head - _body[1];

     _nextDir = x;
  }

  void _setColor() {
    _color = ["red", "blue", "gold", "green"][(_id) % 4];
  }

  _getInitialBody() {
    var newBody = [];

    var x = 0;
    var y = 0;
    var xOffset = 0;
    var yOffset = 0;

    switch (_id) {
      case 0:
        x = 1;
        y = 1;
        xOffset = 1;
        break;
      case 1:
        x = _board._rightEdgeX - 1;
        y = 1;
        yOffset = 1;
        break;
      case 2:
        x = _board._rightEdgeX - 1;
        y = _board._bottomEdgeY - 1;
        xOffset = -1;
        break;
      case 3:
        x = 1;
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
  }

  void _grow() {
    _board._collisionMap[head + _dir] = this;
    _body.insert(0, head + _dir); // updates head
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

    var nextCellOccupant = _board._collisionMap[head + _dir];
    if (nextCellOccupant is Food) {
      _toGrow += nextCellOccupant.growthAmount * 10;
      _board.addFood();
    }

    _grow();
    hasMoved = true;

    if (_toGrow > 0) {
      _toGrow--;
    } else {
      _board._collisionMap.remove(_body.last);
      _body.removeLast();
    }
  }

  kill() {
    this.isDead = true;
    _body.forEach((bodyPoint) => _board._collisionMap.remove(bodyPoint));
  }

  _deathImpending() {
    var nextPoint = head + _dir;

    var nextCellOccupant = _board._collisionMap[nextPoint];

    if (nextCellOccupant is Snake) {
      return true;
    }

    if (nextPoint.x < 0 ||
        nextPoint.y < 0 ||
        nextPoint.x >= _board._rightEdgeX ||
        nextPoint.y >= _board._bottomEdgeY) {
      return true;
    }

    return false;
  }

  getScore() {
    return _body.length - START_LENGTH;
  }
}
