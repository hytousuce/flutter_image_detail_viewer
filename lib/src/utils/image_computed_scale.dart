import 'package:flutter/material.dart';

class ImageComputedScale {
  final String value;
  final double multiplicator;

  const ImageComputedScale._internal(this.value, [this.multiplicator = 1.0]);

  static const cover = const ImageComputedScale._internal('cover');

  static const contain = const ImageComputedScale._internal('contain');

  ImageComputedScale operator *(num other) {
    return ImageComputedScale._internal(this.value, this.multiplicator * other);
  }

  ImageComputedScale operator /(num divider) =>
      ImageComputedScale._internal(this.value, this.multiplicator / divider);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImageComputedScale &&
          this.value == other.value &&
          this.multiplicator == other.multiplicator);

  @override
  int get hashCode => hashValues(value, multiplicator);
}
