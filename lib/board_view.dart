import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:snake_xenzia/size_util.dart';
import 'package:snake_xenzia/square.dart';
import 'package:snake_xenzia/square_widget.dart';

enum Direction { up, down, left, right }

class BoardView extends StatefulWidget {
  const BoardView({Key? key}) : super(key: key);

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  late List<List<Square>> _squares = SizeUtil.generateSquares();
  int _x = 21;
  int _y = 11;

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

  void reset() {
    _squares = SizeUtil.generateSquares();
    _x = 21;
    _y = 11;
    _direction = Direction.up;
    _gameOver = false;
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
    setState(() {});
  }

  void grow() {
    final _tail = _body.last;
    switch (_direction) {
      case Direction.right:
        final newTail = Square(
          x: _tail.x,
          y: _tail.y - 1,
          piece: Piece.body,
        );
        _body.add(newTail);
        _squares[_tail.x][_tail.y - 1] = newTail;
        break;
      case Direction.left:
        final newTail = Square(
          x: _tail.x,
          y: _tail.y + 1,
          piece: Piece.body,
        );
        _body.add(newTail);
        _squares[_tail.x][_tail.y + 1] = newTail;
        break;
      case Direction.up:
        final newTail = Square(
          x: _tail.x + 1,
          y: _tail.y,
          piece: Piece.body,
        );
        _body.add(newTail);
        _squares[_tail.x + 1][_tail.y] = newTail;

        break;
      case Direction.down:
        final newTail = Square(
          x: _tail.x - 1,
          y: _tail.y,
          piece: Piece.body,
        );
        _body.add(newTail);
        _squares[_tail.x - 1][_tail.y] = newTail;

        break;
      default:
    }
  }

  void checkIfFoodHasBeenEaten() {
    if (_body.first.x == _food.x && _body.first.y == _food.y) {
      grow();
      spunFood();
    }
  }

  void moveUp([int startIndex = 0]) {
    if (startIndex == 0) _x--;
    final oldTail = _body.last;
    for (int i = startIndex; i < _body.length; i++) {
      final block = _body[i];
      if (block.y == _body.first.y) {
        if (startIndex == 0 && i == 0) {
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
          _squares[block.x][block.y] = Square(
            x: block.x,
            y: block.y,
            piece: Piece.none,
          );
          _body[i] = _squares[_x + 1][block.y] = Square(
            x: _x + 1,
            y: block.y,
            piece: Piece.body,
          );
        }
      } else if (block.y > _body.first.y) {
        moveRight(i);
      } else {
        moveLeft(i);
      }
    }

    _squares[oldTail.x][oldTail.y] = oldTail.copyWith(piece: Piece.none);
    setState(() {});
  }

  void moveDown([int startIndex = 0]) {
    if (startIndex == 0) _x++;
    final oldTail = _body.last;
    for (int i = startIndex; i < _body.length; i++) {
      final block = _body[i];
      if (block.y == _body.first.y) {
        if (startIndex == 0 && i == 0) {
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
          _squares[block.x][block.y] = Square(
            x: block.x,
            y: block.y,
            piece: Piece.none,
          );
          _body[i] = _squares[_x - i][block.y] = Square(
            x: _x - i,
            y: block.y,
            piece: Piece.body,
          );
        }
      } else if (block.y > _body.first.y) {
        moveRight(i);
      } else {
        moveLeft(i);
      }
    }
    _squares[oldTail.x][oldTail.y] = oldTail.copyWith(piece: Piece.none);
    setState(() {});
  }

  void moveLeft([int startIndex = 0]) {
    if (startIndex == 0) _y--;
    final oldTail = _body.last;
    for (int i = startIndex; i < _body.length; i++) {
      final block = _body[i];
      if (block.x == _body.first.x) {
        if (startIndex == 0 && i == 0) {
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
          _squares[block.x][block.y] = Square(
            x: block.x,
            y: block.y,
            piece: Piece.none,
          );
          _body[i] = _squares[block.x][_y + 1] = Square(
            x: block.x,
            y: _y + 1,
            piece: Piece.body,
          );
        }
      } else if (block.x > _body.first.x) {
        moveUp(i);
      } else {
        moveDown(i);
      }
    }

    _squares[oldTail.x][oldTail.y] = oldTail.copyWith(piece: Piece.none);
    setState(() {});
  }

  void moveRight([int startIndex = 0]) {
    if (startIndex == 0) _y++;
    final oldTail = _body.last;
    for (int i = startIndex; i < _body.length; i++) {
      final block = _body[i];
      if (block.x == _body.first.x) {
        if (startIndex == 0 && i == 0) {
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
          _squares[block.x][block.y] = Square(
            x: block.x,
            y: block.y,
            piece: Piece.none,
          );
          _body[i] = _squares[block.x][_y - 1] = Square(
            x: block.x,
            y: _y - 1,
            piece: Piece.body,
          );
        }
      } else if (block.x > _body.first.x) {
        moveUp(i);
      } else {
        moveDown(i);
      }
    }

    _squares[oldTail.x][oldTail.y] = oldTail.copyWith(piece: Piece.none);
    setState(() {});
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
      default:
    }

    _duration = 500;
    checkIfFoodHasBeenEaten();
  }

  int _duration = 500;

  void onHorizontalDrag(double? velocity) {
    if (_direction == Direction.left || _direction == Direction.right) return;
    if ((velocity ?? 0) > 0) {
      _direction = Direction.right;
    } else if ((velocity ?? 0) < 0) {
      _direction = Direction.left;
    }
    _duration = 0;

    setState(() {});
  }

  void onVerticalDrag(double? velocity) {
    if (_direction == Direction.up || _direction == Direction.down) return;
    if ((velocity ?? 0) > 0) {
      _direction = Direction.down;
    } else if ((velocity ?? 0) < 0) {
      _direction = Direction.up;
    }

    _duration = 0;
    setState(() {});
  }

  void play() async {
    spunFood();
    while (!_gameOver) {
      try {
        await Future.delayed(Duration(milliseconds: _duration))
            .then((_) => moveBody());

        setState(() {});
      } on RangeError {
        setState(() {
          _gameOver = true;
        });
      } catch (e, trace) {
        print(e);
        print(trace);
        setState(() {
          _gameOver = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Snake Xenzia"),
      ),
      body: _gameOver
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Game Over"),
                  TextButton(
                    onPressed: reset,
                    child: const Text("Play again"),
                  ),
                ],
              ),
            )
          : GestureDetector(
              onHorizontalDragEnd: (DragEndDetails details) {
                onHorizontalDrag(details.primaryVelocity);
              },
              onVerticalDragEnd: (DragEndDetails details) {
                onVerticalDrag(details.primaryVelocity);
              },
              child: Column(
                children: [
                  for (var squares in _squares) ...{
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var square in squares)
                          SquareWidget(square: square),
                      ],
                    )
                  }
                ],
              ),
            ),
    );
  }
}
