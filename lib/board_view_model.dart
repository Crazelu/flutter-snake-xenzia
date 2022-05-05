import 'dart:math';
import 'package:flutter/material.dart';
import 'package:snake_xenzia/size_util.dart';
import 'package:snake_xenzia/square.dart';

enum Direction { up, down, left, right }

class BoardViewModel extends ChangeNotifier {
  BoardViewModel() {
    play();
  }
  static const __duration = 200;
  static const __point = 10;

  late List<List<Square>> _squares = SizeUtil.generateSquares();
  List<List<Square>> get squares => _squares;

  late int _x = _squares.length ~/ 2;
  late int _y = _squares.first.length ~/ 2;
  int _duration = __duration;

  late Square _food;

  late List<Square> _body = [
    Square(
      x: _x,
      y: _y,
      piece: Piece.body,
    ),
  ];

  Direction _direction = Direction.up;

  bool _gameOver = false;
  bool get isGameOver => _gameOver;

  int _gamePoints = 0;
  int get gamePoints => _gamePoints;

  ///TODO
  ///Currently not functional because movement logic relies on global
  ///[_x] and [_y] variables which are reset for revival to happen
  void revive() {
    switch (_direction) {
      case Direction.up:
        _x = _squares.length - 1;
        _y = _body.first.y;
        break;
      case Direction.down:
        _x = 0;
        _y = _body.first.y;
        break;
      case Direction.left:
        _x = _body.first.x;
        _y = _squares.first.length - 1;
        break;
      case Direction.right:
        _x = _body.first.x;
        _y = 0;
        break;
    }
    notifyListeners();
  }

  void reset() {
    _squares = SizeUtil.generateSquares();
    _x = _squares.length ~/ 2;
    _y = _squares.first.length ~/ 2;
    _direction = Direction.up;
    _gameOver = false;
    _gamePoints = 0;
    _body = [
      Square(
        x: _x,
        y: _y,
        piece: Piece.body,
      ),
    ];
    play();
  }

  void spunFood() {
    int randomX = Random().nextInt(_squares.length);
    int randomY = Random().nextInt(_squares.first.length);
    _food = _squares[randomX][randomY] =
        Square(x: randomX, y: randomY, piece: Piece.food);
    notifyListeners();
  }

  void grow() {
    final tail = _body.last;
    final head = _body.first;
    late int newX;
    late int newY;
    switch (_direction) {
      case Direction.right:
        if (head.x == tail.x) {
          newX = tail.x;
          newY = tail.y - 1;
        } else if (head.x > tail.x) {
          newX = tail.x - 1;
          newY = tail.y;
        } else {
          newX = tail.x + 1;
          newY = tail.y;
        }
        break;
      case Direction.left:
        if (head.x == tail.x) {
          newX = tail.x;
          newY = tail.y + 1;
        } else if (head.x > tail.x) {
          newX = tail.x - 1;
          newY = tail.y;
        } else {
          newX = tail.x + 1;
          newY = tail.y;
        }
        break;
      case Direction.up:
        if (head.y == tail.y) {
          newX = tail.x + 1;
          newY = tail.y;
        } else if (head.y > tail.y) {
          newX = tail.x;
          newY = tail.y - 1;
        } else {
          newX = tail.x;
          newY = tail.y + 1;
        }
        break;
      case Direction.down:
        if (head.y == tail.y) {
          newX = tail.x - 1;
          newY = tail.y;
        } else if (head.y > tail.y) {
          newX = tail.x;
          newY = tail.y - 1;
        } else {
          newX = tail.x;
          newY = tail.y + 1;
        }
        break;
    }

    final newTail = Square(
      x: newX,
      y: newY,
      piece: Piece.body,
    );
    _body.add(newTail);
    _squares[newX][newY] = newTail;
  }

  void checkIfFoodHasBeenEaten() {
    if (_body.first.x == _food.x && _body.first.y == _food.y) {
      _gamePoints += __point;
      grow();
      spunFood();
    }
  }

  void moveUp() {
    _x--;
    final oldTail = _body.last;
    for (int i = 0; i < _body.length; i++) {
      final block = _body[i];
      if (block.y == _body.first.y) {
        if (i == 0) {
          _squares[_x + 1][block.y] = Square(
            x: _x + 1,
            y: block.y,
            piece: Piece.none,
          );
          _body[i] = _squares[_x][block.y] = Square(
            x: _x,
            y: block.y,
            piece: Piece.body,
          );
        } else {
          _squares[block.x][block.y] = block.copyWith(piece: Piece.none);
          _body[i] = _squares[_x + i][block.y] = Square(
            x: _x + i,
            y: block.y,
            piece: Piece.body,
          );
        }
      } else if (block.y > _body.first.y) {
        shiftLeft(i);
      } else {
        shiftRight(i);
      }
    }

    _squares[oldTail.x][oldTail.y] = oldTail.copyWith(piece: Piece.none);
    notifyListeners();
  }

  void moveDown() {
    _x++;
    final oldTail = _body.last;
    for (int i = 0; i < _body.length; i++) {
      final block = _body[i];
      if (block.y == _body.first.y) {
        if (i == 0) {
          _squares[_x - 1][block.y] = Square(
            x: _x - 1,
            y: block.y,
            piece: Piece.none,
          );
          _body[i] = _squares[_x][block.y] = Square(
            x: _x,
            y: block.y,
            piece: Piece.body,
          );
        } else {
          _squares[block.x][block.y] = block.copyWith(piece: Piece.none);
          _body[i] = _squares[_x - i][block.y] = Square(
            x: _x - i,
            y: block.y,
            piece: Piece.body,
          );
        }
      } else if (block.y > _body.first.y) {
        shiftLeft(i);
      } else {
        shiftRight(i);
      }
    }
    _squares[oldTail.x][oldTail.y] = oldTail.copyWith(piece: Piece.none);
    notifyListeners();
  }

  void moveLeft() {
    _y--;
    final oldTail = _body.last;
    for (int i = 0; i < _body.length; i++) {
      final block = _body[i];
      if (block.x == _body.first.x) {
        if (i == 0) {
          _squares[block.x][_y + 1] = Square(
            x: block.x,
            y: _y + 1,
            piece: Piece.none,
          );
          _body[i] = _squares[block.x][_y] = Square(
            x: block.x,
            y: _y,
            piece: Piece.body,
          );
        } else {
          _squares[block.x][block.y] = block.copyWith(piece: Piece.none);
          _body[i] = _squares[block.x][_y + i] = Square(
            x: block.x,
            y: _y + i,
            piece: Piece.body,
          );
        }
      } else if (block.x > _body.first.x) {
        shiftUp(i);
      } else {
        shiftDown(i);
      }
    }

    _squares[oldTail.x][oldTail.y] = oldTail.copyWith(piece: Piece.none);
    notifyListeners();
  }

  void moveRight() {
    _y++;
    final oldTail = _body.last;
    for (int i = 0; i < _body.length; i++) {
      final block = _body[i];
      if (block.x == _body.first.x) {
        if (i == 0) {
          _squares[block.x][_y - 1] = Square(
            x: block.x,
            y: _y - 1,
            piece: Piece.none,
          );
          _body[i] = _squares[block.x][_y] = Square(
            x: block.x,
            y: _y,
            piece: Piece.body,
          );
        } else {
          _squares[block.x][block.y] = block.copyWith(piece: Piece.none);
          _body[i] = _squares[block.x][_y - i] = Square(
            x: block.x,
            y: _y - i,
            piece: Piece.body,
          );
        }
      } else if (block.x > _body.first.x) {
        shiftUp(i);
      } else {
        shiftDown(i);
      }
    }

    _squares[oldTail.x][oldTail.y] = oldTail.copyWith(piece: Piece.none);
    notifyListeners();
  }

  void shiftRight(int index) {
    final block = _body[index];
    _squares[block.x][block.y] = block.copyWith(piece: Piece.none);
    _body[index] = _squares[block.x][block.y + 1] = Square(
      x: block.x,
      y: block.y + 1,
      piece: Piece.body,
    );
  }

  void shiftLeft(int index) {
    final block = _body[index];
    _squares[block.x][block.y] = block.copyWith(piece: Piece.none);
    _body[index] = _squares[block.x][block.y - 1] = Square(
      x: block.x,
      y: block.y - 1,
      piece: Piece.body,
    );
  }

  void shiftUp(int index) {
    final block = _body[index];
    _squares[block.x][block.y] = block.copyWith(piece: Piece.none);
    _body[index] = _squares[block.x - 1][block.y] = Square(
      x: block.x - 1,
      y: block.y,
      piece: Piece.body,
    );
  }

  void shiftDown(int index) {
    final block = _body[index];
    _squares[block.x + 1][block.y] = block.copyWith(piece: Piece.none);
    _body[index] = _squares[block.x][block.y] = Square(
      x: block.x + 1,
      y: block.y,
      piece: Piece.body,
    );
  }

  void moveBody() {
    switch (_direction) {
      case Direction.right:
        moveRight();
        break;
      case Direction.left:
        moveLeft();
        break;
      case Direction.up:
        moveUp();
        break;
      case Direction.down:
        moveDown();
        break;
    }

    _duration = __duration;
    checkIfFoodHasBeenEaten();
  }

  void onHorizontalDrag(double? velocity) {
    if (_direction == Direction.left || _direction == Direction.right) return;
    if ((velocity ?? 0) > 0) {
      _direction = Direction.right;
    } else if ((velocity ?? 0) < 0) {
      _direction = Direction.left;
    }
    _duration = 0;

    notifyListeners();
  }

  void onVerticalDrag(double? velocity) {
    if (_direction == Direction.up || _direction == Direction.down) return;
    if ((velocity ?? 0) > 0) {
      _direction = Direction.down;
    } else if ((velocity ?? 0) < 0) {
      _direction = Direction.up;
    }

    _duration = 0;
    notifyListeners();
  }

  void play() async {
    spunFood();
    while (!_gameOver) {
      try {
        await Future.delayed(Duration(milliseconds: _duration))
            .then((_) => moveBody());
      } on RangeError {
        _gameOver = true;
        notifyListeners();
        //TODO: Revive on RangeError
        //i.e when edge of the board is reached
        // revive();
      } catch (e, trace) {
        print(e);
        print(trace);

        _gameOver = true;
        notifyListeners();
      }
    }
  }
}
