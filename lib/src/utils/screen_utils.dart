import 'package:flutter/widgets.dart';

import 'dart:ui' as ui;

class ScreenUtils {
  static MediaQueryData get mediaQueryData =>
      MediaQueryData.fromWindow(ui.window);

  static double get height => mediaQueryData.size.height;

  static double get width => mediaQueryData.size.width;

  /// Screen size ratio => [height] / [width]
  /// 屏幕比例
  static double get ratio => height / width;
}
