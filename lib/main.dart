import 'package:flutter/material.dart';
import 'package:snake_xenzia/board_view.dart';
import 'package:snake_xenzia/board_view_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Xenzia',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BoardView(viewModel: BoardViewModel()),
    );
  }
}
