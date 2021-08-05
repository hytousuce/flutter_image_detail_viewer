import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_detail_viewer/src/image_detail_viewer.dart';
import 'package:flutter_image_detail_viewer/src/option/image_detail_viewer_option.dart';
import 'package:flutter_image_detail_viewer/src/utils/screen_utils.dart';

class ImageDetailViewerFadePageRouter<T> extends PageRoute<T> {
  final List<ImageDetailViewerOption>? options;
  final int? itemCount;
  final ImageDetailViewerOption Function(BuildContext context, int index)?
      builder;
  final PageController? pageController;
  final AnimationController? routerAnimationController;
  final ScrollPhysics? scrollPhysics;
  final Axis? scrollDirection;
  final Widget Function(BuildContext context)? frontWidgetBuilder;
  final void Function(int)? onPageChanged;
  final int initialPage;
  final Key? key;

  ImageDetailViewerFadePageRouter({
    required this.options,
    this.pageController,
    this.routerAnimationController,
    this.scrollPhysics,
    this.scrollDirection,
    this.key,
    this.frontWidgetBuilder,
    this.onPageChanged,
    this.initialPage = 0,
    RouteSettings? routeSettings,
  })  : itemCount = null,
        builder = null,
        super(settings: routeSettings);

  ImageDetailViewerFadePageRouter.builder({
    required this.itemCount,
    required this.builder,
    this.pageController,
    this.routerAnimationController,
    this.scrollDirection,
    this.scrollPhysics,
    this.frontWidgetBuilder,
    this.key,
    this.onPageChanged,
    this.initialPage = 0,
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
    AnimationController barrierAnimationController =
        routerAnimationController ??
            AnimationController(
              vsync: navigator!.overlay!,
              value: 0.0,
              duration: transitionDuration,
              reverseDuration: reverseTransitionDuration,
            );
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
                  child: Opacity(
                    opacity: 1 - barrierAnimation.value.abs(),
                    child: Container(
                      color: Colors.black,
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
        ),
      ),
    ];
    if (frontWidgetBuilder != null) {
      stackChildrenList.add(Positioned.fill(
        child: FadeTransition(
          opacity: animation,
          child: Builder(
            builder: frontWidgetBuilder!,
          ),
        ),
      ));
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
}
