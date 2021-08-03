import 'package:flutter/material.dart';
import 'package:flutter_image_detail_viewer/src/controller/image_detail_viewer_controller.dart';
import 'package:flutter_image_detail_viewer/src/data/image_display_data.dart';

class SingleImageWrapper extends StatefulWidget {
  final ImageProvider image;
  final ImageDetailViewerController controller;
  final ImageDisplayData? displayData;
  final Object? heroTag;

  SingleImageWrapper(this.image, this.controller, this.displayData,
      {this.heroTag});

  @override
  _SingleImageWrapperState createState() => _SingleImageWrapperState();
}

class _SingleImageWrapperState extends State<SingleImageWrapper> {
  double get scale => widget.controller.scale;
  Offset get offset => widget.controller.centerOffset;
  ImageDisplayData? get imageDisplayData => widget.displayData;

  void controllerListener() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(controllerListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(controllerListener);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SingleImageWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.displayData != widget.displayData) {
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget image = Image(image: widget.image);
    if (widget.heroTag != null) {
      image = Hero(tag: widget.heroTag!, child: image);
    }
    final Matrix4 matrix = Matrix4.identity()..scale(scale);
    if (imageDisplayData == null)
      return Container();
    else
      return CustomSingleChildLayout(
        delegate: _SingleImageLayoutDelegate(offset, scale),
        child: Transform(
          transform: matrix,
          child: Container(
            height: imageDisplayData!.displaySize.height,
            width: imageDisplayData!.displaySize.width,
            child: image,
          ),
        ),
      );
  }
}

class _SingleImageLayoutDelegate extends SingleChildLayoutDelegate {
  final Offset offset;
  final double scale;
  _SingleImageLayoutDelegate(this.offset, this.scale);
  @override
  bool shouldRelayout(_SingleImageLayoutDelegate oldDelegate) {
    return this.offset != oldDelegate.offset || this.scale != oldDelegate.scale;
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // TODO: implement getConstraintsForChild
    return BoxConstraints(
        minWidth: constraints.minWidth,
        maxWidth: constraints.maxWidth,
        minHeight: constraints.minHeight,
        maxHeight: double.infinity);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(
          (size.width - childSize.width * scale) / 2,
          (size.height - childSize.height * scale) / 2,
        ) +
        offset;
  }
}
