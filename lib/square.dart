class Square {
  final int x;
  final int y;
  final Piece piece;

  Square({
    required this.x,
    required this.y,
    this.piece = Piece.none,
  });

  Square copyWith({Piece? piece}) {
    return Square(
      x: x,
      y: y,
      piece: piece ?? this.piece,
    );
  }
}

enum Piece { food, body, none }
