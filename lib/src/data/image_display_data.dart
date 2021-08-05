import 'dart:ui';

import 'package:flutter_image_detail_viewer/src/enum/image_type.dart';

class ImageDisplayData {
  final Size imageSize;
  final Size displaySize;
  final double coverScaleValue;
  final double containScaleValue;
  final ImageType type;

  ImageDisplayData(this.imageSize, this.displaySize, this.containScaleValue,
      this.coverScaleValue, this.type);

  double get ratio => imageSize.height / imageSize.width;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImageDisplayData &&
          other.imageSize == this.imageSize &&
          other.displaySize == this.displaySize &&
          other.containScaleValue == this.containScaleValue &&
          other.coverScaleValue == this.coverScaleValue &&
          other.type == this.type);

  @override
  int get hashCode => hashValues(
      imageSize, displaySize, containScaleValue, coverScaleValue, type);
}
