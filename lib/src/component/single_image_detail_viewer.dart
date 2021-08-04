import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_image_detail_viewer/src/component/single_image_wrapper.dart';
import 'package:flutter_image_detail_viewer/src/controller/image_detail_viewer_controller.dart';
import 'package:flutter_image_detail_viewer/src/data/image_display_data.dart';
import 'package:flutter_image_detail_viewer/src/data/scale_boundary.dart';
import 'package:flutter_image_detail_viewer/src/enum/image_detail_viewer_scale_state.dart';
import 'package:flutter_image_detail_viewer/src/enum/image_type.dart';
import 'package:flutter_image_detail_viewer/src/utils/image_computed_scale.dart';
import 'package:flutter_image_detail_viewer/src/utils/screen_utils.dart';

class SingleImageDetailViewer extends StatefulWidget {
  // final bool isCustom;
  final ImageProvider image;
  // final Widget Function(BuildContext context)? builder;
  final bool showScrollbar;
  final dynamic? initialScale;
  final dynamic? minScale;
  final dynamic? maxScale;
  final bool tapToPopRouter;
  final GestureLongPressCallback? onLongPress;
  final bool enableGestures;
  final ImageLoadingBuilder? loadingBuilder;
  final ImageErrorWidgetBuilder? errorWidgetBuilder;
  final bool Function(ImageProvider image)? judgeGif;
  final Object? heroTag;
  final AnimationController? routerAnimationController;
  final Function(bool value)? enablePageWarp;
  final PageController? pageController;

  SingleImageDetailViewer({
    // this.isCustom = false,
    required this.image,
    // this.builder,
    this.showScrollbar = false,
    this.tapToPopRouter = false,
    this.initialScale,
    this.minScale,
    this.maxScale,
    this.onLongPress,
    this.enableGestures = true,
    this.loadingBuilder,
    this.errorWidgetBuilder,
    this.judgeGif,
    this.heroTag,
    this.routerAnimationController,
    this.enablePageWarp,
    this.pageController,
  });
  // assert(isCustom || builder == null);

  @override
  _SingleImageDetailViewerChild createState() =>
      _SingleImageDetailViewerChild();
}

class _SingleImageDetailViewerChild extends State<SingleImageDetailViewer>
    with SingleTickerProviderStateMixin {
  ImageStream? _imageStream;
  bool _isListeningToStream = false;
  ImageChunkEvent? _loadingProgress;
  Object? _lastException;
  StackTrace? _lastStack;
  ImageStreamCompleterHandle? _completerHandle;
  ImageDetailViewerController controller =
      ImageDetailViewerController.fromValue();
  ImageDisplayData? displayData;
  ScaleBoundary scaleBoundary = ScaleBoundary.noZoom;
  ImageDetailViewerScaleState state = ImageDetailViewerScaleState.initial;

  // ===================== 以下内容为对图片的处理 =====================
  ImageStreamListener? _imageStreamListener;
  ImageStreamListener _getListener({bool recreateListener = false}) {
    if (_imageStreamListener == null || recreateListener) {
      _lastException = null;
      _lastStack = null;
      _imageStreamListener = ImageStreamListener(
        _handleImageFrame,
        onChunk: widget.loadingBuilder == null ? null : _handleImageChunk,
        onError: widget.errorWidgetBuilder != null
            ? (dynamic error, StackTrace? stackTrace) {
                setState(() {
                  _lastException = error;
                  _lastStack = stackTrace;
                });
              }
            : null,
      );
    }
    return _imageStreamListener!;
  }

  void judgeImageType(ImageInfo imageInfo) async {
    if (displayData != null) return;
    int height = imageInfo.image.height;
    int width = imageInfo.image.width;
    double displayWidth = ScreenUtils.width;
    double displayHeight = height / width * displayWidth;
    double ratio = height / width;
    if (height / width > ScreenUtils.ratio) {
      // 属于长图
      displayData = ImageDisplayData(
        Size(width.toDouble(), height.toDouble()),
        Size(displayWidth, displayHeight),
        ScreenUtils.ratio / ratio,
        1.0,
        ImageType.piiic,
      );
      controller.centerOffset = Offset(
        0,
        math.max(0, (displayHeight - ScreenUtils.height) / 2),
      );
      scaleBoundary = ScaleBoundary.getBoundary(displayData!,
          maxScale: widget.maxScale ?? ImageComputedScale.cover * 1.5,
          minScale: widget.minScale ?? ImageComputedScale.contain);
      if (mounted) setState(() {});
      return;
    }
    // 以下情况均为正常图判断是否为动图即可
    if (widget.judgeGif != null && widget.judgeGif!.call(widget.image)) {
      // 通过用户提供的方法实现了
      displayData = ImageDisplayData(
        Size(width.toDouble(), height.toDouble()),
        Size(displayWidth, displayHeight),
        1.0,
        ScreenUtils.ratio / ratio,
        ImageType.animated,
      );
      scaleBoundary = ScaleBoundary.getBoundary(displayData!,
          maxScale: widget.maxScale ?? ImageComputedScale.cover * 1.5,
          minScale: widget.minScale ?? ImageComputedScale.contain * 0.8);
      if (mounted) setState(() {});
      return;
    } else if (widget.image is NetworkImage) {
      if ((widget.image as NetworkImage).url.toLowerCase().contains('.gif')) {
        displayData = ImageDisplayData(
          Size(width.toDouble(), height.toDouble()),
          Size(displayWidth, displayHeight),
          1.0,
          ScreenUtils.ratio / ratio,
          ImageType.animated,
        );
        scaleBoundary = ScaleBoundary.getBoundary(displayData!,
            maxScale: widget.maxScale ?? ImageComputedScale.cover * 1.5,
            minScale: widget.minScale ?? ImageComputedScale.contain * 0.8);
        if (mounted) setState(() {});
        return;
      }
    } else if (widget.image is AssetImage) {
      if ((widget.image as AssetImage)
          .assetName
          .toLowerCase()
          .contains('.gif')) {
        displayData = ImageDisplayData(
          Size(width.toDouble(), height.toDouble()),
          Size(displayWidth, displayHeight),
          1.0,
          ScreenUtils.ratio / ratio,
          ImageType.animated,
        );
        scaleBoundary = ScaleBoundary.getBoundary(displayData!,
            maxScale: widget.maxScale ?? ImageComputedScale.cover * 1.5,
            minScale: widget.minScale ?? ImageComputedScale.contain * 0.8);
        if (mounted) setState(() {});
        return;
      }
    } else if (widget.image is MemoryImage) {
      try {
        ui.Codec codec = await PaintingBinding.instance!
            .instantiateImageCodec((widget.image as MemoryImage).bytes);
        if (codec.frameCount >= 1) {
          displayData = ImageDisplayData(
            Size(width.toDouble(), height.toDouble()),
            Size(displayWidth, displayHeight),
            1.0,
            ScreenUtils.ratio / ratio,
            ImageType.animated,
          );
          scaleBoundary = ScaleBoundary.getBoundary(displayData!,
              maxScale: widget.maxScale ?? ImageComputedScale.cover * 1.5,
              minScale: widget.minScale ?? ImageComputedScale.contain * 0.8);
          if (mounted) setState(() {});
          return;
        }
      } catch (_) {}
    } else if (widget.image is FileImage) {
      try {
        if ((widget.image as FileImage)
            .file
            .path
            .toLowerCase()
            .endsWith('.gif')) {
          displayData = ImageDisplayData(
            Size(width.toDouble(), height.toDouble()),
            Size(displayWidth, displayHeight),
            1.0,
            ScreenUtils.ratio / ratio,
            ImageType.animated,
          );
          scaleBoundary = ScaleBoundary.getBoundary(displayData!,
              maxScale: widget.maxScale ?? ImageComputedScale.cover * 1.5,
              minScale: widget.minScale ?? ImageComputedScale.contain * 0.8);
          if (mounted) setState(() {});
          return;
        }
      } catch (_) {}
    }
    displayData = ImageDisplayData(
      Size(width.toDouble(), height.toDouble()),
      Size(displayWidth, displayHeight),
      1.0,
      ScreenUtils.ratio / ratio,
      ImageType.normal,
    );
    scaleBoundary = ScaleBoundary.getBoundary(displayData!,
        maxScale: widget.maxScale ?? ImageComputedScale.cover * 1.5,
        minScale: widget.minScale ?? ImageComputedScale.contain * 0.8);
    if (mounted) setState(() {});
    return;
  }

  void _handleImageFrame(ImageInfo imageInfo, bool synchronousCall) {
    // 判断图片类型
    judgeImageType(imageInfo);
    setState(() {
      _loadingProgress = null;
      _lastException = null;
      _lastStack = null;
    });
  }

  void _handleImageChunk(ImageChunkEvent event) {
    assert(widget.loadingBuilder != null);
    setState(() {
      _loadingProgress = event;
      _lastException = null;
      _lastStack = null;
    });
  }

  void _resolveImage() {
    final ImageStream newStream =
        widget.image.resolve(createLocalImageConfiguration(context));
    _updateStream(newStream);
  }

  void _updateStream(ImageStream newStream) {
    if (_imageStream?.key == newStream.key) return;
    if (_isListeningToStream) _imageStream!.removeListener(_getListener());
    setState(() {
      _loadingProgress = null;
    });

    _imageStream = newStream;
    if (_isListeningToStream) _imageStream!.addListener(_getListener());
  }

  void _listenToStream() {
    if (_isListeningToStream) return;
    _imageStream!.addListener(_getListener());
    _completerHandle?.dispose();
    _completerHandle = null;

    _isListeningToStream = true;
  }

  void _stopListeningToStream({bool keepStreamAlive = false}) {
    if (!_isListeningToStream) return;
    if (keepStreamAlive &&
        _completerHandle == null &&
        _imageStream?.completer != null) {
      _completerHandle = _imageStream!.completer!.keepAlive();
    }

    _imageStream!.removeListener(_getListener());
    _isListeningToStream = false;
  }

  void didChangeDependencies() {
    _resolveImage();
    if (TickerMode.of(context))
      _listenToStream();
    else
      _stopListeningToStream(keepStreamAlive: true);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    assert(_imageStream != null);
    _stopListeningToStream();
    _completerHandle?.dispose();
    super.dispose();
  }

  // ===================== 以下内容为对手势的处理 =====================
  late double controllerScaleOldValue;
  // late Offset controllerOffsetOldValue;
  late Offset startScalePointerOffset;
  late Offset scalePointerOldOffset;
  late bool disableDragToPop;
  late bool enablePageDrag;
  late double page;

  void onHorizontalDragStart(DragStartDetails details) {
    double panDxMaxValue = math.max(
        0,
        (displayData!.displaySize.width * controller.scale -
                ScreenUtils.width) /
            2);
    enablePageDrag =
        (controller.centerOffset.dx.abs() - panDxMaxValue).abs() < 10;
    if (widget.pageController != null) {
      page = widget.pageController!.page!;
    }
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    if (enablePageDrag && widget.pageController != null) {
      widget.pageController!.jumpTo(
          math.max(0, widget.pageController!.offset - details.delta.dx));
    } else {
      double panDxMaxValue = math.max(
          0,
          (displayData!.displaySize.width * controller.scale -
                  ScreenUtils.width) /
              2);
      double panDyMaxValue = math.max(
          0,
          (displayData!.displaySize.height * controller.scale -
                  ScreenUtils.height) /
              2);
      Offset offsetWillbeValue =
          controller.centerOffset + (details.delta * controller.scale);
      controller.centerOffset = Offset(
          math.max(
              -panDxMaxValue, math.min(panDxMaxValue, offsetWillbeValue.dx)),
          math.max(
              -panDyMaxValue, math.min(panDyMaxValue, offsetWillbeValue.dy)));
    }
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    if (widget.pageController != null && enablePageDrag) {
      if (widget.pageController!.offset + -details.velocity.pixelsPerSecond.dx >
          ScreenUtils.width * (page + 0.5)) {
        widget.pageController!.animateToPage(page.floor() + 1,
            duration: Duration(milliseconds: 250), curve: Curves.easeOut);
      } else if (widget.pageController!.offset +
              -details.velocity.pixelsPerSecond.dx <
          ScreenUtils.width * (page - 0.5)) {
        widget.pageController!.animateToPage(page.floor() - 1,
            duration: Duration(milliseconds: 250), curve: Curves.easeOut);
      } else if (widget.pageController!.offset <= 0) {
        widget.pageController!.animateToPage(0,
            duration: Duration(milliseconds: 250), curve: Curves.easeOut);
      } else if (widget.pageController!.offset >
          ScreenUtils.width * widget.pageController!.positions.length) {
        widget.pageController!.animateToPage(
            widget.pageController!.positions.length,
            duration: Duration(milliseconds: 250),
            curve: Curves.easeOut);
      }
    }
  }

  void onScaleStart(ScaleStartDetails details) {
    controllerScaleOldValue = controller.value.scale;
    startScalePointerOffset = details.focalPoint;
    scalePointerOldOffset = details.focalPoint;
    double panDyMaxValue = math.max(
        0,
        (displayData!.displaySize.height * controller.scale -
                ScreenUtils.height) /
            2);
    if ((controller.centerOffset.dy.abs() - panDyMaxValue).abs() < 10)
      disableDragToPop = false;
    else
      disableDragToPop = true;
    double panDxMaxValue = math.max(
        0,
        (displayData!.displaySize.width * controller.scale -
                ScreenUtils.width) /
            2);
    if (widget.enablePageWarp != null) {
      print("~~~${(controller.centerOffset.dx.abs() - panDxMaxValue).abs()}");
      if ((controller.centerOffset.dx.abs() - panDxMaxValue).abs() < 10)
        widget.enablePageWarp!.call(true);
      else
        widget.enablePageWarp!.call(false);
    }
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    Offset delta = details.focalPoint - scalePointerOldOffset;
    scalePointerOldOffset = details.focalPoint;
    if (displayData == null) return;
    controller.scale = math.max(
        scaleBoundary.minScale,
        math.min(
            scaleBoundary.maxScale, controllerScaleOldValue * details.scale));
    print("${scaleBoundary.minScale}, ${scaleBoundary.maxScale}");
    if (controller.scale != 1.0) {
      state = controller.scale > 1.0
          ? ImageDetailViewerScaleState.zoomedIn
          : ImageDetailViewerScaleState.zoomedOut;
    }
    double panDyMaxValue = math.max(
        0,
        (displayData!.displaySize.height * controller.scale -
                ScreenUtils.height) /
            2);

    if (state == ImageDetailViewerScaleState.initial &&
        widget.routerAnimationController != null &&
        ((controller.centerOffset.dy + delta.dy).abs() > panDyMaxValue ||
            widget.routerAnimationController!.value != 0.5) &&
        !disableDragToPop) {
      widget.routerAnimationController!.value -=
          delta.dy / ScreenUtils.height / 2;
      return;
    }
    double panDxMaxValue = math.max(
        0,
        (displayData!.displaySize.width * controller.scale -
                ScreenUtils.width) /
            2);
    Offset offsetWillbeValue =
        controller.centerOffset + (delta * controller.scale);
    controller.centerOffset = Offset(
        math.max(-panDxMaxValue, math.min(panDxMaxValue, offsetWillbeValue.dx)),
        math.max(
            -panDyMaxValue, math.min(panDyMaxValue, offsetWillbeValue.dy)));
  }

  void Function(ScaleEndDetails) onScaleEnd(BuildContext context) {
    return (details) {
      double dragVelocity = details.velocity.pixelsPerSecond.dy;
      print("~~~${dragVelocity / ScreenUtils.height / 20}");
      if (state == ImageDetailViewerScaleState.initial &&
          widget.routerAnimationController != null &&
          widget.routerAnimationController!.value != 0.5 &&
          (widget.routerAnimationController!.value +
                      (dragVelocity / ScreenUtils.height / 10) -
                      0.5)
                  .abs() >
              0.1) {
        widget.routerAnimationController!
            .animateTo(widget.routerAnimationController!.value > 0.5 ? 1 : 0);
        Navigator.pop(context);
      } else if (widget.routerAnimationController != null) {
        widget.routerAnimationController!.animateTo(0.5);
      }
    };
  }

  Animation? doubleTapScaleAnimation;
  AnimationController? doubleTapScaleAnimationController;

  void onDoubleTap() {
    if (doubleTapScaleAnimationController == null) {
      return;
    } else if ([AnimationStatus.completed, AnimationStatus.dismissed]
            .indexOf(doubleTapScaleAnimationController!.status) ==
        -1) {
      doubleTapScaleAnimationController!.stop();
    }
    late double willScaleValue;
    if (state == ImageDetailViewerScaleState.initial) {
      if (displayData == null) return;
      if (displayData!.type == ImageType.piiic) {
        // 长图放大
        willScaleValue = 1.5;
        state = ImageDetailViewerScaleState.zoomedIn;
      } else {
        willScaleValue = displayData!.coverScaleValue;
        state = ImageDetailViewerScaleState.covering;
      }
    } else {
      willScaleValue = 1.0;
      state = ImageDetailViewerScaleState.initial;
    }
    doubleTapScaleAnimation =
        Tween<double>(begin: controller.value.scale, end: willScaleValue)
            .animate(CurvedAnimation(
                parent: doubleTapScaleAnimationController!,
                curve: Curves.easeOut))
              ..addListener(() {
                if (doubleTapScaleAnimation == null) return;
                double panDyMaxValue = math.max(
                    0,
                    (displayData!.displaySize.height *
                                doubleTapScaleAnimation!.value -
                            ScreenUtils.height) /
                        2);
                double panDxMaxValue = ((displayData!.displaySize.width *
                                doubleTapScaleAnimation!.value -
                            ScreenUtils.width) /
                        2)
                    .abs();

                controller.centerOffset = Offset(
                    math.max(-panDxMaxValue,
                        math.min(panDxMaxValue, controller.centerOffset.dx)),
                    math.max(-panDyMaxValue,
                        math.min(panDyMaxValue, controller.centerOffset.dy)));
                controller.scale = doubleTapScaleAnimation!.value;
              });
    doubleTapScaleAnimationController!.forward(from: 0);
  }

  VoidCallback onTap(BuildContext context) {
    return () {
      if (widget.routerAnimationController != null) {
        widget.routerAnimationController!.reverse();
      }
      Navigator.pop(context);
    };
  }

  @override
  void initState() {
    super.initState();
    doubleTapScaleAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
  }

  @override
  Widget build(BuildContext context) {
    if (_lastException != null) {
      assert(widget.errorWidgetBuilder != null);
      return widget.errorWidgetBuilder!(context, _lastException!, _lastStack);
    }
    Widget imageWarapper = SingleImageWrapper(
      widget.image,
      controller,
      displayData,
      heroTag: widget.heroTag,
    );

    if (widget.enableGestures) {
      imageWarapper = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: onHorizontalDragStart,
        onHorizontalDragUpdate: onHorizontalDragUpdate,
        onHorizontalDragEnd: onHorizontalDragEnd,
        onDoubleTap: onDoubleTap,
        onScaleStart: onScaleStart,
        onScaleUpdate: onScaleUpdate,
        onScaleEnd: onScaleEnd(context),
        // onPanUpdate: onPanUpdate,
        // onPanEnd: onPanEnd(context),
        onTap: onTap(context),
        child: imageWarapper,
      );
    }

    if (widget.loadingBuilder != null)
      imageWarapper =
          widget.loadingBuilder!(context, imageWarapper, _loadingProgress);
    return imageWarapper;
  }
}
