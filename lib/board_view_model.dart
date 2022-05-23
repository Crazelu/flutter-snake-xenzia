import 'dart:math';
import 'package:flutter/material.dart';
import 'package:snake_xenzia/size_util.dart';
import 'package:snake_xenzia/square.dart';

enum Direction { up, down, left, right, none }

class BoardViewModel extends ChangeNotifier {
  BoardViewModel() {
    play();
  }
  static const __duration = 200;
  static const __point = 10;

  late List<List<Square>> _squares = SizeUtil.generateSquares();
  List<List<Square>> get squares => _squares;

  late final int _tileCount = _squares.length;

  late int _x = _squares.length ~/ 2;
  late int _y = _squares.first.length ~/ 2;
  int _duration = __duration;
  int _xVel = 0;
  int _yVel = 0;
  int _snakeLength = 3;

  late Square _food = _randomFood;

  late List<Square> _body = [];

  Direction _direction = Direction.none;

  bool _gameOver = false;
  bool get isGameOver => _gameOver;

  int _gamePoints = 0;
  int get gamePoints => _gamePoints;

  void reset() {
    _xVel = 0;
    _yVel = 0;
    _squares = SizeUtil.generateSquares();
    _x = _squares.length ~/ 2;
    _y = _squares.first.length ~/ 2;
    _direction = Direction.none;
    _gameOver = false;
    _gamePoints = 0;
    _body = [];
    play();
  }

  void play() async {
    // onVerticalDrag(-1);

    while (!_gameOver) {
      try {
        await Future.delayed(Duration(milliseconds: (1000 / 15).ceil()))
            .then((_) => moveBody());
      } catch (e, trace) {
        print(e);
        print(trace);

        _gameOver = true;
        notifyListeners();
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
      if (part.x == _x && part.y == _y) {
        if (_snakeLength != 3) {
          _gameOver = true;
        }
        notifyListeners();
      }
    }
    _body.add(Square(x: _x, y: _y, piece: Piece.body));

    while (_body.length > _snakeLength) {
      _body.removeAt(0);
    }

    notifyListeners();

    checkIfFoodHasBeenEaten();

    _squares[_food.x][_food.y] = _food;
    notifyListeners();
  }

  void checkIfFoodHasBeenEaten() {
    if (_x == _food.x && _y == _food.y) {
      _snakeLength++;
      _gamePoints += __point;
      spunFood();
    }
  }

  Square get _randomFood {
    int randomX = Random().nextInt(_squares.length);
    int randomY = Random().nextInt(_squares.first.length);
    return Square(x: randomX, y: randomY, piece: Piece.food);
  }

  void spunFood() {
    int randomX = Random().nextInt(_squares.length);
    int randomY = Random().nextInt(_squares.first.length);
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
    _duration = 0;

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
