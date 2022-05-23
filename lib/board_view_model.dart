import 'dart:math';
import 'package:flutter/material.dart';
import 'package:snake_xenzia/size_util.dart';
import 'package:snake_xenzia/square.dart';

enum Direction { up, down, left, right, none }

class BoardViewModel extends ChangeNotifier {
  BoardViewModel() {
    play();
  }

  static const __point = 10;

  late List<List<Square>> _squares = SizeUtil.generateSquares();
  List<List<Square>> get squares => _squares;

  late final int _tileCount = _squares.length;

  late int _x = _squares.length ~/ 2;
  late int _y = _squares.first.length ~/ 2;

  int _xVel = 0;
  int _yVel = 0;
  int _snakeLength = 3;

  late Square _food = _randomFood;

  List<Square> _body = [];
  List<Square> _obstacles = [];

  Direction _direction = Direction.none;

  bool _gameOver = false;
  bool get isGameOver => _gameOver;

  int _gamePoints = 0;
  int get gamePoints => _gamePoints;

  void reset() {
    _xVel = 0;
    _yVel = 0;
    _snakeLength = 3;
    _squares = SizeUtil.generateSquares();
    _x = _squares.length ~/ 2;
    _y = _squares.first.length ~/ 2;
    _direction = Direction.none;
    _obstacles = [];
    _gameOver = false;
    _gamePoints = 0;
    _food = _food.copyWith(piece: Piece.none);
    _body = [];
    play();
  }

  void play() async {
    _createObstacles();
    _spunFood();

    while (!_gameOver) {
      try {
        await Future.delayed(Duration(milliseconds: (1000 / 15).ceil()))
            .then((_) => moveBody());
      } catch (e, trace) {
        print(e);
        print(trace);
      }
    }
  }

  void moveBody() {
    _x += _xVel;
    _y += _yVel;

    if (_x < 0) {
      _x = _tileCount - 1;
    }
    if (_x > _tileCount - 1) {
      _x = 0;
    }
    if (_y < 0) {
      _y = _squares.first.length - 1;
    }
    if (_y > _squares.first.length - 1) {
      _y = 0;
    }
    _squares = SizeUtil.generateSquares();
    for (int i = 0; i < _body.length; i++) {
      final part = _body[i];

      _squares[part.x][part.y] =
          _squares[part.x][part.y].copyWith(piece: Piece.body);
      _evaluateGameOver(part);
    }

    _body.add(Square(x: _x, y: _y, piece: Piece.body));

    while (_body.length > _snakeLength) {
      _body.removeAt(0);
    }

    notifyListeners();

    _squares[_food.x][_food.y] = _food;
    for (var obstacle in _obstacles) {
      _squares[obstacle.x][obstacle.y] = obstacle;
    }
    _checkIfFoodHasBeenEaten();
    _checkForObstacleCollision();
    notifyListeners();
  }

  void _checkForObstacleCollision() {
    for (var obstacle in _obstacles) {
      if (_x == obstacle.x && _y == obstacle.y) {
        _gameOver = true;
        notifyListeners();
        break;
      }
    }
  }

  void _evaluateGameOver(Square curr) {
    if (curr.x == _x && curr.y == _y) {
      if (_snakeLength != 3) {
        _gameOver = true;
        notifyListeners();
      }
    }
  }

  void _checkIfFoodHasBeenEaten() {
    if (_x == _food.x && _y == _food.y) {
      _snakeLength++;
      _gamePoints += __point;
      _spunFood();
    }
  }

  void _createObstacles() {
    try {
      //rightvertical wall
      int staticX = _squares.length ~/ 2 + 4;
      int x = staticX;
      int y = _squares.first.length ~/ 2 +
          ((_squares.first.length ~/ 2) / 1.4).ceil();

      int steps = 10;
      while (steps > 0) {
        final obstacle = Square(x: x, y: y, piece: Piece.obstacle);

        _squares[x][y] = obstacle;
        _obstacles.add(obstacle);
        x--;
        steps--;
      }

      //left vertical wall
      x = staticX;
      y = _squares.first.length ~/ 2 -
          ((_squares.first.length ~/ 2) / 1.2).ceil();

      steps = 10;
      while (steps > 0) {
        final obstacle = Square(x: x, y: y, piece: Piece.obstacle);

        _squares[x][y] = obstacle;
        _obstacles.add(obstacle);
        x--;
        steps--;
      }

      y = _squares.first.length ~/ 2 +
          ((_squares.first.length ~/ 2) / 1.4).ceil();

      //bottom horizontal wall
      y = y + 3 > _squares.first.length - 3 ? y - 3 : y + 3;
      x = -1 * (staticX - _squares.length ~/ 0.85);
      steps = staticX ~/ 1.7;
      while (steps > 0) {
        final obstacle = Square(x: x, y: y, piece: Piece.obstacle);

        _squares[x][y] = obstacle;
        _obstacles.add(obstacle);
        y--;
        steps--;
      }

      //top walls

      //left
      y = _squares.first.length ~/ 2.2 +
          ((_squares.first.length ~/ 2) / 2.5).ceil();
      steps = staticX ~/ 1.9;
      x = _squares.first.length ~/ 2.2;
      while (steps > 0) {
        final obstacle = Square(x: x, y: y, piece: Piece.obstacle);

        _squares[x][y] = obstacle;
        _obstacles.add(obstacle);
        y--;
        steps--;
      }
    } catch (e, trace) {
      print(e);
      print(trace);
    }
  }

  Square get _randomFood {
    int randomX = Random().nextInt(_squares.length);
    int randomY = Random().nextInt(_squares.first.length);
    return Square(x: randomX, y: randomY, piece: Piece.food);
  }

  void _spunFood() {
    int randomX = Random().nextInt(_squares.length);
    int randomY = Random().nextInt(_squares.first.length);

    while (_squares[randomX][randomY].piece == Piece.obstacle ||
        _squares[randomX][randomY].piece == Piece.body) {
      randomX = Random().nextInt(_squares.length);
      randomY = Random().nextInt(_squares.first.length);
    }
    _food = _squares[randomX][randomY] =
        Square(x: randomX, y: randomY, piece: Piece.food);
    notifyListeners();
  }

  void onHorizontalDrag(double? velocity) {
    if (_direction == Direction.left || _direction == Direction.right) return;

    if ((velocity ?? 0) > 0) {
      _direction = Direction.right;
      _xVel = 0;
      _yVel = 1;
    } else if ((velocity ?? 0) < 0) {
      _direction = Direction.left;
      _xVel = 0;
      _yVel = -1;
    }

    notifyListeners();
  }

  void onVerticalDrag(double? velocity) {
    if (_direction == Direction.up || _direction == Direction.down) return;

    if ((velocity ?? 0) > 0) {
      _direction = Direction.down;
      _xVel = 1;
      _yVel = 0;
    } else if ((velocity ?? 0) < 0) {
      _direction = Direction.up;
      _xVel = -1;
      _yVel = 0;
    }
  }
}
