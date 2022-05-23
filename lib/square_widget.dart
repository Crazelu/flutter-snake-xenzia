import 'package:flutter/material.dart';
import 'package:snake_xenzia/settings.dart';
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
      height: GameSettings.bodySize,
      width: GameSettings.bodySize,
      decoration: BoxDecoration(
        color: square.piece == Piece.body
            ? Colors.blue
            : square.piece == Piece.food
                ? Colors.red
                : square.piece == Piece.obstacle
                    ? Colors.grey[700]
                    : Colors.transparent,
        shape:
            square.piece == Piece.food ? BoxShape.circle : BoxShape.rectangle,
      ),
      child: square.piece == Piece.obstacle
          ? const Center(
              child: Text(
                "|",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }
}
