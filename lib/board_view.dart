import 'package:flutter/material.dart';
import 'package:snake_xenzia/board_view_model.dart';
import 'package:snake_xenzia/reactive_widget.dart';
import 'package:snake_xenzia/square_widget.dart';

class BoardView extends StatelessWidget {
  final BoardViewModel viewModel;
  const BoardView({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReactiveWidget(
      controller: viewModel,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text("Snake Xenzia"),
          centerTitle: false,
          actions: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  "${viewModel.gamePoints} points",
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      ?.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        body: viewModel.isGameOver
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Game Over",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    TextButton(
                      onPressed: viewModel.reset,
                      child: const Text("Play again"),
                    ),
                  ],
                ),
              )
            : GestureDetector(
                onHorizontalDragEnd: (DragEndDetails details) {
                  viewModel.onHorizontalDrag(details.primaryVelocity);
                },
                onVerticalDragEnd: (DragEndDetails details) {
                  viewModel.onVerticalDrag(details.primaryVelocity);
                },
                child: Column(
                  children: [
                    for (var squares in viewModel.squares) ...{
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
      ),
    );
  }
}
