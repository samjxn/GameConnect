part of game_connect_client.src.games;

abstract class IGCGame {

  onSnapshotReceived(ControllerSnapshot snapshot);

  init();
}


class SnakeGame  extends IGCGame {

  CanvasElement canvas;
  CanvasRenderingContext2D context;
  _CellRenderer renderer;
  Snake _snake;
  Point _food;

  _CellRenderer _cellRender;
  CanvasRenderingContext2D _ctx;

  final int CELL_SIZE= 10;
  static const num GAME_SPEED = 50;
  num _lastTimeStamp = 0;

  int _rightEdgeX;
  int _bottomEdgeY;

  void onDidMount() {
    canvas = querySelector('#snake-canvas');
    _ctx = canvas.getContext('2d');
    _rightEdgeX = canvas.width ~/ CELL_SIZE;
    _bottomEdgeY = canvas.height ~/ CELL_SIZE;
    renderer = new _CellRenderer(canvas, _ctx, CELL_SIZE);

    init();
  }

  void init() {
    _snake = new Snake(renderer);
    _snake._dir = Snake.RIGHT;
    _food = _randomPoint();
  }

  Point _randomPoint() {
    Random random = new Random();
    return new Point(random.nextInt(_rightEdgeX),
        random.nextInt(_bottomEdgeY));
  }

  void onSnapshotReceived(ControllerSnapshot snapshot) {
    _snake._setNextDirection(snapshot);
  }

  void _checkForCollisions() {
    // check for collision with food
    if (_snake.head == _food) {
      _snake.grow(growAmount: 1);
      _food = _randomPoint();
    }

    // check death conditions
    if (_snake.head.x <= -1 ||
        _snake.head.x >= _rightEdgeX ||
        _snake.head.y <= -1 ||
        _snake.head.y >= _bottomEdgeY ||
        _snake.checkForBodyCollision()) {
      init();
    }
  }

  void run() {
    window.animationFrame.then(update);
  }

  void update(num delta) {
    final num diff = delta - _lastTimeStamp;

    if (diff > GAME_SPEED) {
      _lastTimeStamp = delta;
      renderer.clear();
      renderer.drawCell(_food, "blue");
      _snake.update();
      _checkForCollisions();
    }

    // keep looping
    run();
  }


}

class _CellRenderer {

  int CELL_SIZE;
  CanvasRenderingContext2D _context;
  CanvasElement _canvasElement;

  void clear() {
    _context..fillStyle = "white"
      ..fillRect(0, 0, _canvasElement.width, _canvasElement.height);
  }

  _CellRenderer(CanvasElement this._canvasElement, CanvasRenderingContext2D this._context, this.CELL_SIZE);

  void drawCell(Point coords, String color) {
    _context.fillStyle = color;
    _context.strokeStyle = "white";

    final int x = coords.x * CELL_SIZE;
    final int y = coords.y * CELL_SIZE;

    _context.fillRect(x, y, CELL_SIZE, CELL_SIZE);
    _context.strokeRect(x, y, CELL_SIZE, CELL_SIZE);
  }

}

class Snake {

  static const int START_LENGTH = 6;
  static const Point LEFT = const Point(-1, 0);
  static const Point RIGHT = const Point(1, 0);
  static const Point UP = const Point(0, -1);
  static const Point DOWN = const Point(0, 1);

  _CellRenderer _cellRender;

  Point _dir = RIGHT;

  Point snakeHead;
  Point moveRight;

  // coordinates of the body segments
  List<Point> _body;

  Point get head => _body.first;

  Snake(_CellRenderer this._cellRender) {
    int i = START_LENGTH - 1;
    _body = new List<Point>.generate(START_LENGTH,
        ((int index) => new Point(i--, 0))
    );
  }

  void _setNextDirection(ControllerSnapshot snapshot) {

    if (snapshot == null) {
      return;
    }


    var dpadDir = snapshot?.dpadInput;

    if (dpadDir == "1" && _dir != DOWN) {
      _dir = UP;
    }

    if (dpadDir == "2" && _dir != LEFT) {
      _dir = RIGHT;
    }

    if (dpadDir == "3" && _dir != UP) {
      print("DOWN");
      _dir = DOWN;
    }

    if (dpadDir == "4" && _dir != RIGHT) {
      _dir = LEFT;
    }

  }

  void _draw() {
    _body.forEach((Point p){
      _cellRender.drawCell(p, "green");
    });
  }

  void grow({growAmount: 1}) {
    for (int i = 0; i < growAmount; i++) {
      _body.insert(0, head + _dir);
    }
  }

  void _move() {
    grow();
    _body.removeLast();
  }

  bool checkForBodyCollision() {
    for (Point p in _body.skip(1)) {
      if (p == head) {
        return true;
      }
    }
    return false;
  }

  void update() {
    _move();
    _draw();
  }
}



