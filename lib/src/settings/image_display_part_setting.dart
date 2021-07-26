import 'dart:ui';

class ImageDisplayPartSetting {
  /// The coordinate of the top-left display part corner in image coordinate
  /// system.
  /// 显示区域左上角在图片坐标系下的坐标。以图片的最左上角为(0, 0)。
  final Offset topLeftOffset;

  /// The height in double of the display part in image coordinate system.
  /// 在图片坐标系下，显示区域高度的值。
  final double? height;

  /// The width in double of the display part in image coordinate system.
  /// 在图片坐标系下，显示区域宽度的值。
  final double? width;

  /// Get a [ImageDisplayPartSetting] with [topLeftOffset] and one of [height]
  /// and [width].
  /// 使用左上角坐标 [topLeftOffset] 与高 [height] 或长 [width] 中的一者获取显示部分配
  /// 置。
  ///
  /// ⚠️ Please notice that, only at least one of [height] and [width] is required.
  /// Don't give all of them. When you provide only one of them, the
  /// [getDisplaySize] function will calculate the other one. When you give none
  /// of them, [getDisplaySize] will calculate the maximum valid displayable
  /// [Size] with [topLeftOffset] and the size of you widget.
  /// ⚠️ 注意：只需要提供 [height] 与 [width] 中最多一者。也就是说，你可以提供他俩中的一个，
  /// 或是两个都不提供。[getDisplaySize] 方法会根据你提供的信息和图片大小、控件大小等信息来
  /// 计算最大的显示区域大小。当你提供了 [height] 与 [width] 中的一者，这个方法会计算另一者；
  /// 当你没有提供这两个参数，这个方法会根据图片可显示的最大区域以及你的控件 (Widget) 的比例
  /// 来计算相应的显示大小。
  const ImageDisplayPartSetting(this.topLeftOffset, {this.height, this.width})
      : assert(height == null || width == null);

  /// Get the diaplay size.
  /// 获取可视尺寸
  ///
  /// * [size]: The size of widget. 控件大小。
  /// * [imageSize]: The size of image. 图片大小。
  ///
  /// If the function could get a valid size with the given [height] of [width],
  /// the size with be returned. Otherwise, a maxinum valid space size will
  /// returned. Moreover, the function will return `null` if the [topLeftOffset]
  /// is not less that [imageSize], which indicates an error condition.
  /// 如果这个方法可以通过构造函数给出的 [height] 或 [width] 得到一个不超出原本图片大小的区
  /// 域尺寸，则返回这个尺寸。否则会返回一个最大的可视尺寸。如果 [topLeftOffset] 不合理（即
  /// 这个点不在图片的范围内），则返回 `null`，表示发生错误。
  Size? getDisplaySize(Size size, Size imageSize) {
    if (!(topLeftOffset < imageSize)) {
      return null;
    }
    if (height == null && width == null) {
      double maxWidth = imageSize.width - topLeftOffset.dx;
      double maxHeight = imageSize.height - topLeftOffset.dy;
      if (maxWidth / maxHeight >= size.width / size.height) {
        // 以高度为准
        return Size(size.width / size.height * maxHeight, maxHeight);
      } else
        return Size(maxWidth, size.height / size.width * maxWidth);
    } else if (height != null) {
      // 首先判断使用这个给定的高度是否会超出图片实际内容
      double maxWidth = imageSize.width - topLeftOffset.dx;
      double maxHeight = imageSize.height - topLeftOffset.dy;
      double calculatedWidth = size.width / size.height * height!;
      if (calculatedWidth <= maxWidth && height! <= maxHeight) {
        return Size(calculatedWidth, height!);
      } else {
        // 返回最大可显示区域
        if (maxWidth / maxHeight >= size.width / size.height) {
          // 以高度为准
          return Size(size.width / size.height * maxHeight, maxHeight);
        } else
          return Size(maxWidth, size.height / size.width * maxWidth);
      }
    } else {
      // 此时必定 width != null
      double maxWidth = imageSize.width - topLeftOffset.dx;
      double maxHeight = imageSize.height - topLeftOffset.dy;
      double calculatedHeight = size.width / size.height * width!;
      if (calculatedHeight <= maxWidth && width! <= maxHeight) {
        return Size(width!, calculatedHeight);
      } else {
        // 返回最大可显示区域
        if (maxWidth / maxHeight >= size.width / size.height) {
          // 以高度为准
          return Size(size.width / size.height * maxHeight, maxHeight);
        } else
          return Size(maxWidth, size.height / size.width * maxWidth);
      }
    }
  }
}
