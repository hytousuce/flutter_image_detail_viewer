import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class ImageDetailViewerOption {
  final ImageProvider? image;
  final Widget Function(BuildContext context)? customBuilder;
  final bool showScrollbar;

  /// The initial scale value for this option.
  /// 本配置的最初缩放值
  ///
  /// The value's type can be [double] or [ImageComputedScale].
  /// 值的类型可以为 [double] 或 [ImageComputedScale]。
  final dynamic? initialScale;

  /// The max scale value for this option.
  /// 本配置的最大缩放值
  ///
  /// The value's type can be [double] or [ImageComputedScale].
  /// 值的类型可以为 [double] 或 [ImageComputedScale]。
  final dynamic? minScale;

  /// The min scale value for this option.
  /// 本配置的最小缩放值
  ///
  /// The value's type can be [double] or [ImageComputedScale].
  /// 值的类型可以为 [double] 或 [ImageComputedScale]。
  final dynamic? maxScale;

  /// Whether to pop the router when user tap on the viewer.
  /// 当用户单击时是否退出路由。
  final bool tapToPopRouter;

  /// Method will be called when the user long press the viewer.
  /// 当用户长按时进行的操作。
  final GestureLongPressCallback? onLongPress;

  /// Whether to enable the gesture detector.
  /// 是否启用手势。
  final bool enableGestures;

  /// The hero tag for Image. When given, a hero wrapper will be wrapped for the
  /// image Widget.
  /// Hero 动画的标签，当提供时，图片控件外围将会被包裹一个 Hero Widget。
  final Object? heroTag;

  /// A default [ImageDetailViewerOption] constructor with an [ImageProvider].
  /// 使用提供的 [ImageProvider] 构建。
  ImageDetailViewerOption({
    required this.image,
    this.showScrollbar = false,
    this.tapToPopRouter = false,
    this.initialScale,
    this.minScale,
    this.maxScale,
    this.onLongPress,
    this.enableGestures = true,
    this.heroTag,
  }) : customBuilder = null;

  /// An [ImageDetailViewerOption] constructor with a custom builder.
  /// 可使用自定义 builder 函数的构造函数。
  // ImageDetailViewerOption.customBuilder({
  //   required this.customBuilder,
  //   this.showScrollbar = false,
  //   this.tapToPopRouter = false,
  //   this.initialScale,
  //   this.minScale,
  //   this.maxScale,
  //   this.onLongPress,
  //   this.heroTag,
  //   this.enableGestures = true,
  // }) : image = null;
}
