part of game_connect_client.src.games;

class SnakeGame extends IGCGame {
  CanvasElement canvas;
  _CellRenderer renderer;
  List<Snake> _snakes;
  int _playersInGame;
  bool _displayLabels;

  CanvasRenderingContext2D _ctx;

  Map<String, Player> _idPlayerMap;
  Map<String, Snake> _idSnakeMap;
  Map<Snake, Player> _snakePlayerMap;

  final int CELL_SIZE = 10;
  static const num GAME_SPEED = 50;
  num _lastTimeStamp = 0;

  GameBoard _board;

  bool _displayInitialMessage;

  int _gameStartTimestamp;

  SnakeGame() {
    _snakes = [];
    _idPlayerMap = {};
    _idSnakeMap = {};
    _snakePlayerMap = {};
    _playersInGame = 0;
    _displayLabels = true;
  }

  void onDidMount(List<Player> players) {
    List gamePlayers = players.length > 4 ? players.sublist(0, 4) : players;

    canvas = querySelector('#snake-canvas');
    _ctx = canvas.getContext('2d');

    renderer = new _CellRenderer(canvas, _ctx, CELL_SIZE);

    gamePlayers.forEach((Player p) {
      _idPlayerMap[p.clientId] = p;
    });

    _playersInGame = _idPlayerMap.length < 4 ? _idPlayerMap.length : 4;
    _board = new GameBoard(canvas, CELL_SIZE);

    resetGame();
  }

  void resetGame() {
    _displayInitialMessage = true;
    _displayLabels = true;

    _board.reset();
    _board.addFood();

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
    _displayInitialMessage = false;

    Snake snake = _idSnakeMap[snapshot.senderId];
    snake._setNextDirection(snapshot);
  }

  void run() {
    window.animationFrame.then(update);
  }

  endGame() {
    resetGame();
  }

  void update(num timestamp) {
    final num diff = timestamp - _lastTimeStamp;

    if (diff > GAME_SPEED) {
      _lastTimeStamp = timestamp;

      if (_displayInitialMessage) {
        _displayStartMessage();
      } else {
        _drawGameUpdate(timestamp);
      }

      if (_playersInGame <= 0) {
        endGame();
      }
    }

    run();
  }

  _displayStartMessage() {
    renderer.clear();

    _ctx.fillStyle = "black";
    _ctx.font = "100px Monospace";
    _ctx.textAlign = "center";
    _ctx.fillText("Snake.", canvas.width ~/ 2, canvas.height ~/ 2);
    _ctx.font = "25px Monospace";
    _ctx.fillText("(hiss)", canvas.width ~/ 2 + 75, canvas.height ~/ 2 + 25);

    _ctx.fillText("Press A to start, Press B to quit.", canvas.width ~/ 2,
        canvas.height ~/ 2 + 100);
  }

  _drawGameUpdate(timestamp) {
    _gameStartTimestamp ??= timestamp;
    renderer.clear();

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

    drawLabels();

    renderer.drawBoard(_board);
  }

  drawLabels() {
    if (_displayLabels) {

      var i = 0;

      var cellOffset = 3 ;//* CELL_SIZE;

      var labelOffsets = [
        new Point(0, cellOffset),
        new Point(-cellOffset, 0),
        new Point(0, -cellOffset),
        new Point(cellOffset, 0)
      ];
      var justification  = [
        "right",
        "right",
        "left",
        "left"
      ];


//       todo:  get drawing labels working
      _snakes.forEach((Snake s) {
        renderer.drawLabel(s.name, s.head +labelOffsets[i], s._color, justification[i]);
        i++;
      });
    }
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
    _context.fillStyle = color;
    _context.textAlign = alignment;

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

  static const int START_LENGTH = 20;
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

  Snake(GameBoard this._board, this.name) {
    _id = _count;
    _count++;
    _body = [];
    hasMoved = false;
    isDead = false;

    _setInitialDirection();
    _body = _getInitialBody();
    _initBodyCollisions();
    _setColor();
  }

  void _initBodyCollisions() {
    _body.forEach((Point bodyPoint){
      _board._collisionMap[bodyPoint] = this;
    });
  }

  void _setInitialDirection() {
    //todo:  undo
    _dir = null; //[RIGHT, DOWN, LEFT, UP][_count - 1];
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
      //todo:  MOVE
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

    // todo:  remove
    if (_dir == null) {
      _nextDir = null;
      hasMoved = true;
      return;
    }

    var nextCellOccupant = _board._collisionMap[head + _dir];

    if (_deathImpending()) {
      this.isDead = true;
      _body.forEach((bodyPoint) => _board._collisionMap.remove(bodyPoint));
      _body.clear();

      return;
    }

    if (nextCellOccupant is Food) {
      for (int i = 0; i < nextCellOccupant.growthAmount; i++) {
        if (!_deathImpending()) {
          _grow();
        }
      }
      _board.addFood();
    } else {
      _grow();
      _board._collisionMap.remove(_body.last);
      _body.removeLast();
      hasMoved = true;
    }
    _dir = null;
    _nextDir = null;
  }

  _deathImpending() {
    var nextCellOccupant = _board._collisionMap[head + _dir];

    if (nextCellOccupant is Snake) {
      return true;
    }

    return false;
  }
}
