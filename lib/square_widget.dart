import 'package:flutter/material.dart';
import 'package:snake_xenzia/square.dart';

class SquareWidget extends StatelessWidget {
  final Square square;
  const SquareWidget({
    Key? key,
    required this.square,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
        color: square.piece == Piece.body
            ? Colors.blue
            : square.piece == Piece.food
                ? Colors.red
                : Colors.transparent,
        shape:
            square.piece == Piece.food ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }
}
