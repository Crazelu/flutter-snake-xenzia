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
      default:
    }
    setState(() {});
  }

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
    final tail = _body.last;
    final head = _body.first;
    switch (_direction) {
      case Direction.right:
        late int newX;
        late int newY;
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
        final newTail = Square(
          x: newX,
          y: newY,
          piece: Piece.body,
        );
        _body.add(newTail);
        _squares[newX][newY] = newTail;
        break;
      case Direction.left:
        late int newX;
        late int newY;
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
        final newTail = Square(
          x: newX,
          y: newY,
          piece: Piece.body,
        );
        _body.add(newTail);
        _squares[newX][newY] = newTail;
        break;
      case Direction.up:
        late int newX;
        late int newY;
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
        final newTail = Square(
          x: newX,
          y: newY,
          piece: Piece.body,
        );
        _body.add(newTail);
        _squares[newX][newY] = newTail;
        break;
      case Direction.down:
        late int newX;
        late int newY;
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
        final newTail = Square(
          x: newX,
          y: newY,
          piece: Piece.body,
        );
        _body.add(newTail);
        _squares[newX][newY] = newTail;
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
    setState(() {});
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
    setState(() {});
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
    setState(() {});
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

    _duration = 200;
    checkIfFoodHasBeenEaten();
  }

  int _duration = 200;

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
        // revive();
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
