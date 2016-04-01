// Dart Academy Tutorial

// Created by Michael Rhodas

import 'dart:html';
import 'dart:math';
import 'dart:collection';

// Make top level keyboard for all classes to access the input.
Keyboard keyboard = new Keyboard();

// Make the size of each cell.
const int CELL_SIZE = 10;

// Make the canvas and canvas context available to all classes.
CanvasElement canvas;
CanvasRenderingContext2D ctx;


void main() {
  //querySelector('#wrapper').children.add();

  // Select the canvas element.
  canvas = querySelector('#canvas')
    ..focus();

  // Used to draw on 2d canvas plane.
  ctx = canvas.getContext('2d');
  new Game()
    ..run();
}

// Function to clear everything.
void clear() {
  ctx
    ..fillStyle = "white"
    ..fillRect(0, 0, canvas.width, canvas.height);
}

// Draw a cell with scaled inputs.
void drawCell(Point coords, String color) {
  ctx
    ..fillStyle = color
    ..strokeStyle = "white";

  final int x = coords.x * CELL_SIZE;
  final int y = coords.y * CELL_SIZE;

  ctx
    ..fillRect(x, y, CELL_SIZE, CELL_SIZE)
    ..strokeRect(x, y, CELL_SIZE, CELL_SIZE);
}


//from Fredrik Bornander.  Listens to the keyboard during the game.
//TODO will adapt this class to use the websockets input.
class Keyboard {
  HashMap<int, int> _keys = new HashMap<int, int>();

  Keyboard() {
    window.onKeyDown.listen((KeyboardEvent event) {
      if (!_keys.containsKey(event.keyCode)) {
        _keys[event.keyCode] = event.timeStamp;
      }
    });

    window.onKeyUp.listen((KeyboardEvent event) {
      _keys.remove(event.keyCode);
    });
  }

  bool isPressed(int keyCode) => _keys.containsKey(keyCode);

// Keyboard Class End
}


class Snake {
  // Direction constants.
  static const Point LEFT = const Point(-1, 0);
  static const Point RIGHT = const Point(1, 0);
  static const Point UP = const Point(0, -1);
  static const Point DOWN = const Point(0, 1);

  // Start length.
  static const int START_LENGTH = 6;

  //Holds the coordinates of the snake's blocks.
  List<Point> _body;

  //Initial and represents current direction.
  Point _dir = RIGHT;

  //Create an initial snake chain.
  Snake() {
    int i = START_LENGTH - 1;

    _body = new List<Point>.generate(
        START_LENGTH, (int index) => new Point(i--, 0));
  }

  // Getter function shorthand.  Snake.head or head within snake to access first element.
  Point get head => _body.first;

  // When food is collected, this is used to increase the snake size.
  void grow() {
    // add new head based on current direction
    _body.insert(0, head + _dir);
  }

  // Used to check if snake segments have collided with the head.
  bool checkForBodyCollision() {
    // skip creates a temporary list of all segments besides the head.
    for (Point p in _body.skip(1)) {
      if (p == head) {
        return true;
      }
    }

    return false;
  }

  // Move the snake by adding a new head in the current direction, then removing the tail.
  void _move() {
    grow();
    _body.removeLast();
  }

  // draw each segment of the snake.
  void _draw() {
    for (Point p in _body) {
      drawCell(p, "green");
    }
  }

  // This checks the arrow key input to determine what is pressed.  It will check for reverse direction as well.
  void _checkInput() {
    if (keyboard.isPressed(KeyCode.LEFT) && _dir != RIGHT) {
      _dir = LEFT;
    } else if (keyboard.isPressed(KeyCode.RIGHT) && _dir != LEFT) {
      _dir = RIGHT;
    } else if (keyboard.isPressed(KeyCode.UP) && _dir != DOWN) {
      _dir = UP;
    } else if (keyboard.isPressed(KeyCode.DOWN) && _dir != UP) {
      _dir = DOWN;
    }
  }

  // Used to control the snkaes frame by frame movement.
  void update() {
    // Check if a key is pressed.
    _checkInput();

    // Move the snake segment points.
    _move();

    // Redraw the snake.
    _draw();
  }

//Snake Class End
}

class Game {
  // Game clock in milliseconds.
  static const num GAME_SPEED = 50;

  // Calculate the amount of time between frame updates.
  num _lastTimeStamp = 0;

  // These will be the x and y coordinates scaled by the width and height.
  int _rightEdgeX;
  int _bottomEdgeY;

  // This represents the snake during game runtime.
  Snake _snake;
  // Current food coordinate.
  Point _food;

  // Create a game.
  Game() {

    // Find the two edges determined by cell size.
    _rightEdgeX = canvas.width ~/ CELL_SIZE;
    _bottomEdgeY = canvas.height ~/ CELL_SIZE;

    // Initialize the snake and food coordinate.
    init();
  }

  // Used for a new game.
  void init() {
    _snake = new Snake();
    _food = _randomPoint();
  }

  // Used to find a random point for the food.
  Point _randomPoint() {
    Random random = new Random();

    // Make a random point with the scaled x and y coordinates.
    return new Point(random.nextInt(_rightEdgeX),
        random.nextInt(_bottomEdgeY));
  }

  // This will find collisions with food and obstacle and reset the game.
  void _checkForCollisions() {
    // food collision
    if (_snake.head == _food) {
      _snake.grow();

      // Make a new point for the food to use next time.
      _food = _randomPoint();
    }

    // obstacle collision
    if (_snake.head.x <= -1 ||
        _snake.head.x >= _rightEdgeX ||
        _snake.head.y <= -1 ||
        _snake.head.y >= _bottomEdgeY ||
        _snake.checkForBodyCollision()) {

      // Restart the game if there is a collision.
      init();
    }
  }

  //
  void update(num delta) {

    //Consistently calculate the time since the last update.
    final num diff = delta - _lastTimeStamp;

    //Then when the time reaches the game speed, update the animation.
    if (diff > GAME_SPEED) {
      // Old time stamp.
      _lastTimeStamp = delta;

      //Get rid of all old drawings.
      clear();

      //Make a new food dot.
      drawCell(_food, "blue");

      //Update the snake an ddraw it.
      _snake.update();

      // Check if there is a game over or growth.
      _checkForCollisions();
    }

    // keep looping
    run();
  }

  void run() {
    window.animationFrame.then(update);
  }

//Game Class End
}