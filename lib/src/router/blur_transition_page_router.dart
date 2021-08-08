import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_detail_viewer/flutter_image_detail_viewer.dart';
import 'package:flutter_image_detail_viewer/src/utils/screen_utils.dart';

class ImageDetailViewerBlurPageRouter<T> extends PageRoute<T> {
  final List<ImageDetailViewerOption>? options;
  final int? itemCount;
  final ImageDetailViewerOption Function(BuildContext, int index)? builder;
  final PageController? pageController;
  final AnimationController? routerAnimationController;
  final ScrollPhysics? scrollPhysics;
  final Axis? scrollDirection;
  final Widget Function(BuildContext context)? frontWidgetBuilder;
  final double blurMaxValue;
  final void Function(int)? onPageChanged;
  final int initialPage;
  final bool hideStatusBarWhenPushIn;
  final Key? key;

  ImageDetailViewerBlurPageRouter({
    required this.options,
    this.pageController,
    this.routerAnimationController,
    this.scrollPhysics,
    this.scrollDirection,
    this.key,
    this.frontWidgetBuilder,
    this.blurMaxValue = 40,
    this.onPageChanged,
    this.initialPage = 0,
    this.hideStatusBarWhenPushIn = false,
    RouteSettings? routeSettings,
  })  : itemCount = null,
        builder = null,
        super(settings: routeSettings);

  ImageDetailViewerBlurPageRouter.builder({
    required this.itemCount,
    required this.builder,
    this.pageController,
    this.routerAnimationController,
    this.scrollDirection,
    this.scrollPhysics,
    this.frontWidgetBuilder,
    this.key,
    this.blurMaxValue = 40,
    this.onPageChanged,
    this.initialPage = 0,
    this.hideStatusBarWhenPushIn = false,
    RouteSettings? routeSettings,
  })  : options = null,
        super(settings: routeSettings);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    if (Platform.isIOS && hideStatusBarWhenPushIn) {
      // 安卓平台如此会导致后层应用出现异常，故而暂时不进行此操作
      SystemChrome.setEnabledSystemUIOverlays([]);
    }
    AnimationController barrierAnimationController =
        routerAnimationController ??
            AnimationController(
                vsync: navigator!.overlay!,
                value: 0.0,
                duration: transitionDuration,
                reverseDuration: reverseTransitionDuration);
    Animation<double> barrierAnimation = Tween<double>(begin: 1.0, end: -1.0)
        .animate(CurvedAnimation(
            parent: barrierAnimationController, curve: Curves.linear));
    late Widget imageDetailViewerWidget;
    if (options != null) {
      imageDetailViewerWidget = ImageDetailViewer(
        options: options,
        pageController: pageController,
        routerAnimationController: barrierAnimationController,
        scrollPhysics: scrollPhysics,
        scrollDirection: scrollDirection,
        onPageChanged: onPageChanged,
        initialPage: initialPage,
        key: key,
      );
    } else {
      imageDetailViewerWidget = ImageDetailViewer.builder(
        itemCount: itemCount,
        builder: builder,
        pageController: pageController,
        routerAnimationController: barrierAnimationController,
        scrollDirection: scrollDirection,
        scrollPhysics: scrollPhysics,
        onPageChanged: onPageChanged,
        initialPage: initialPage,
        key: key,
      );
    }
    List<Widget> stackChildrenList = [
      Positioned.fill(
          child: AnimatedBuilder(
        animation: barrierAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX:
                        (1 - math.min(1, barrierAnimation.value.abs() * 2)) *
                            blurMaxValue,
                    sigmaY:
                        (1 - math.min(1, barrierAnimation.value.abs() * 2)) *
                            blurMaxValue,
                  ),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(
                    0.0,
                    ScreenUtils.height * barrierAnimation.value,
                  ),
                  child: child,
                ),
              )
            ],
          );
        },
        child: imageDetailViewerWidget,
      ))
    ];
    if (frontWidgetBuilder != null) {
      stackChildrenList.add(
        Positioned.fill(
          child: FadeTransition(
            opacity: animation,
            child: Builder(
              builder: frontWidgetBuilder!,
            ),
          ),
        ),
      );
    }
    barrierAnimationController.animateTo(0.5);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: Stack(
        children: stackChildrenList,
      ),
    );
  }

  @override
  bool get maintainState => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 500);

  @override
  Duration get reverseTransitionDuration => Duration(milliseconds: 250);

  @override
  void dispose() {
    if (Platform.isIOS && hideStatusBarWhenPushIn) {
      SystemChrome.setEnabledSystemUIOverlays(
          [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    }
    super.dispose();
  }
}
