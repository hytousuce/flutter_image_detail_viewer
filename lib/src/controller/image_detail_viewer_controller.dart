import 'package:flutter/material.dart';

class ImageDetailViewerController
    extends ValueNotifier<ImageDetailViewerValue> {
  ImageDetailViewerController(ImageDetailViewerValue value) : super(value);

  ImageDetailViewerController.fromValue({double? scale, Offset? centerOffset})
      : super(
          ImageDetailViewerValue(
            scale: scale ?? 1.0,
            centerOffset: centerOffset ?? const Offset(0, 0),
          ),
        );

  double get scale => value.scale;
  Offset get centerOffset => value.centerOffset;
  set scale(double newScaleValue) {
    value = value.copyWith(scale: newScaleValue);
    notifyListeners();
  }

  set centerOffset(Offset newOffsetValue) {
    value = value.copyWith(centerOffset: newOffsetValue);
    notifyListeners();
  }
}

/// The value of
class ImageDetailViewerValue {
  double scale;
  Offset centerOffset;

  ImageDetailViewerValue(
      {this.scale = 1.0, this.centerOffset = const Offset(0, 0)});

  ImageDetailViewerValue copyWith({
    double? scale,
    Offset? centerOffset,
  }) =>
      ImageDetailViewerValue(
          scale: scale ?? this.scale,
          centerOffset: centerOffset ?? this.centerOffset);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ImageDetailViewerValue &&
            scale == other.scale &&
            centerOffset == other.centerOffset);
  }

  @override
  int get hashCode => hashValues(scale, centerOffset);
}
