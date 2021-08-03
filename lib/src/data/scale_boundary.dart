import 'dart:math';

import 'package:flutter_image_detail_viewer/src/data/image_display_data.dart';
import 'package:flutter_image_detail_viewer/src/utils/image_computed_scale.dart';

class ScaleBoundary {
  final double maxScale;
  final double minScale;
  final double initialScale;

  const ScaleBoundary(this.initialScale, this.maxScale, this.minScale)
      : assert(maxScale >= initialScale && minScale <= initialScale);

  static ScaleBoundary getBoundary(ImageDisplayData imageDisplayData,
      {dynamic maxScale, dynamic minScale}) {
    double initialScale = 1.0;
    double maxScaleValue = 1.0;
    double minScaleValue = 1.0;
    if (maxScale != null) {
      if (maxScale is double) {
        maxScaleValue = max(initialScale, maxScale);
      } else {
        assert(maxScale is ImageComputedScale);
        ImageComputedScale maxScaleComputed = maxScale as ImageComputedScale;
        if (maxScaleComputed.value == 'cover') {
          maxScaleValue = max(
              initialScale,
              imageDisplayData.coverScaleValue *
                  maxScaleComputed.multiplicator);
        } else {
          assert(maxScaleComputed.value == 'contain');
          maxScaleValue = max(
              initialScale,
              imageDisplayData.containScaleValue *
                  maxScaleComputed.multiplicator);
        }
      }
    }
    if (minScale != null) {
      if (minScale is double) {
        minScaleValue = max(0.0, min(initialScale, minScale));
      } else {
        assert(minScale is ImageComputedScale);
        ImageComputedScale minScaleComputed = minScale as ImageComputedScale;
        if (minScaleComputed.value == 'cover') {
          minScaleValue = max(
            0.0,
            min(
              initialScale,
              imageDisplayData.coverScaleValue * minScaleComputed.multiplicator,
            ),
          );
        } else {
          assert(minScaleComputed.value == 'contain');
          minScaleValue = max(
            0.0,
            min(
              initialScale,
              imageDisplayData.containScaleValue *
                  minScaleComputed.multiplicator,
            ),
          );
          print("~~~${imageDisplayData.containScaleValue}");
        }
      }
    }
    return ScaleBoundary(initialScale, maxScaleValue, minScaleValue);
  }

  static const noZoom = const ScaleBoundary(1.0, 1.0, 1.0);
}
