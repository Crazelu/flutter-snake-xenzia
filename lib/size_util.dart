import 'dart:ui';
import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:snake_xenzia/square.dart';

class SizeUtil {
  SizeUtil._();

  static late double deviceHeight =
      (window.physicalSize.height / window.devicePixelRatio) -
          (kToolbarHeight * 2);
  static late double deviceWidth =
      window.physicalSize.width / window.devicePixelRatio;

  static List<List<Square>> generateSquares() {
    List<List<Square>> result = [];

    double height = 20;
    double width = 20;

    int rowItems = deviceWidth ~/ width;

    for (int i = 0; i < deviceHeight ~/ height; i++) {
      List<Square> inner = [];
      for (int j = 0; j < rowItems; j++) {
        inner.add(Square(x: i, y: j));
      }
      result.add(inner);
    }

    // log("$result");
    return result;
  }
}
