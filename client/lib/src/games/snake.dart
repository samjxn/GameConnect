part of game_connect_client.src.games;



class SnakeGame  extends IGCGame {

  CanvasElement canvas;
  CanvasRenderingContext2D context;
  _CellRenderer renderer;
  List<Snake> _snakes;
  List<Point> _food;
  int _playersInGame;

  CanvasRenderingContext2D _ctx;

  Map<String, Player> _idPlayerMap;
  Map<Player, Snake> _playerSnakeMap;

  final int CELL_SIZE= 10;
  static const num GAME_SPEED = 50;
  num _lastTimeStamp = 0;

  GameBoard _board;

  SnakeGame(){
    _snakes = [];
    _idPlayerMap = {};
    _playerSnakeMap = {};
    _playersInGame = 0;
    _food = [];
  }

  void onDidMount(List<Player> players) {

    canvas = querySelector('#snake-canvas');
    _ctx = canvas.getContext('2d');

    renderer = new _CellRenderer(canvas, _ctx, CELL_SIZE);

    players.forEach((Player p){
      _idPlayerMap[p.clientId] = p;
    });

    _playersInGame = _idPlayerMap.length >= 4 ?_idPlayerMap.length : 4;
    _board = new GameBoard(canvas, CELL_SIZE);

    resetGame();
  }

  void resetGame() {

    _food.clear();

    _food.insert(0, _randomPoint());

    Snake._count = 0;
    _snakes.clear();

    _idPlayerMap.forEach((_, Player p){
      Snake snake = new Snake(_board);
      _snakes.add(snake);
      _playerSnakeMap[p] = snake;
    });

  }

  Point _randomPoint() {
    Random random = new Random();
    return new Point(random.nextInt(_board._rightEdgeX),
        random.nextInt(_board._bottomEdgeY));
  }

  onSnapshotReceived(ControllerSnapshot snapshot) async {
    String clientId = snapshot.senderId;
    Snake snake = _playerSnakeMap[_idPlayerMap[clientId]];
    snake._setNextDirection(snapshot);
  }


  void run() {
    window.animationFrame.then(update);
  }

  void update(num delta) {

    if(_playersInGame <= 0) {
      //endGame();
    }

    final num diff = delta - _lastTimeStamp;

    if (diff > GAME_SPEED) {

      _lastTimeStamp = delta;
      renderer.clear();

      //draw foods

      _food.forEach((Point p){
        renderer.drawCell(p, "purple");
      });

      // mark each snake as 'has not moved'
      _snakes.forEach((snake) {
        snake.hasMoved = false;
      });

      //move snakes
      _snakes.where((snake) => !snake.isDead).forEach((snake) {
        snake._move();
        if (snake.isDead) {
          _playersInGame--;
        }
      });

      renderer.drawAllSnakes(_board);
    }

    run();
  }

}

class _CellRenderer {

  int cellSize;
  CanvasRenderingContext2D _context;
  CanvasElement _canvasElement;



  _CellRenderer(CanvasElement this._canvasElement, CanvasRenderingContext2D this._context, this.cellSize);

  void clear() {
    _context..fillStyle = "white"
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

  drawAllSnakes(GameBoard board){
    board._snakeMap.forEach((Point bodyPoint, Snake snake){
      drawCell(bodyPoint, snake._color);
    });
  }
}

class GameBoard {

  int _rightEdgeX;
  int _bottomEdgeY;
  Map<Point, Snake> _snakeMap;

  GameBoard(canvas, cell_size) {
    _rightEdgeX = canvas.width ~/ cell_size;
    _bottomEdgeY = canvas.height ~/ cell_size;
    _snakeMap = {};
  }
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


  Snake(GameBoard this._board) {
    _count++;
    _body = [];
    hasMoved = false;
    isDead = false;

    _setInitialDirection();
    _setInitialBody();
    _setColor();
  }

  void _setInitialDirection() {
    _dir = null;//[RIGHT, DOWN, LEFT, UP][_count - 1];
  }

  void _setColor() {
    _color = ["red", "blue", "yellow", "green"][_count - 1];
  }

  _setInitialBody() {

    if (_body == null || ! _body.isEmpty) {
      _body = [];
    }

    var x = 0;
    var y = 0;
    var xOffset = 0;
    var yOffset = 0;

    switch (_count) {
      case 1:
        x = 1;
        y = 1;
        xOffset = 1;
        break;
      case 2:
        x = _board._rightEdgeX - 1;
        y = 1;
        yOffset = 1;
        break;
      case 3:
        x = _board._rightEdgeX - 1;
        y = _board._bottomEdgeY - 1;
        xOffset = -1;
        break;
      case 4:
        x = 1;
        y = _board._bottomEdgeY - 1;
        yOffset = -1;
        break;
    }

    for (int i = 0; i < START_LENGTH; i++) {
      var bodyPoint = new Point(x, y);
      _body.add(bodyPoint);
      _board._snakeMap[bodyPoint] = this;
      x += xOffset;
      y += yOffset;
    }

    _body = _body.reversed.toList(growable: true);
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

  void grow({growAmount: 1}) {


    bool nextCellOccupied() {
      var occupant = _board._snakeMap[head + _dir];

      // if snake map is empty at snake's new head position
      if (occupant == null) {
        // the cell is not occupied
        return false;
      }

      // if snake map contains the tail of a snake about to move
      if (this.head == occupant.tail && !occupant.hasMoved){
        // the cell is "not occupied"
        return false;
      }

      return true;
    }

    for (int i = 0; i < growAmount; i++) {
      if (nextCellOccupied()) {
        this.isDead = true;
        for (Point bodyPoint in _body) {
          _board._snakeMap.remove(bodyPoint);
          this._body = [];
        }
      } else {
        _body.insert(0, head + _dir);
        _board._snakeMap[head] = this;
      }
    }
  }

  void _move() {

    _dir = _nextDir;

    if (_dir == null) {
      hasMoved = true;
      return;
    }

    grow();
    if (!this.isDead) {
      var removedBodyPoint = _body.last;
      _board._snakeMap.remove(removedBodyPoint);
      _body.removeLast();
      hasMoved = true;
    }
  }
}



