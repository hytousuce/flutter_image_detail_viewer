import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_image_detail_viewer/flutter_image_detail_viewer.dart';
import 'package:flutter_image_detail_viewer/src/router/blur_transition_page_router.dart';
import 'package:flutter_image_detail_viewer/src/router/fade_transition_page_router.dart';

import 'component/single_image_detail_viewer.dart';

/// A outter widget forw mulit detailed(large) image displaying.
/// 用于多个大图展示的外部组件
class ImageDetailViewer extends StatefulWidget {
  /// [ImageDetailViewerOption]s to build children Widgets for
  /// [ImageDetailViewer].
  /// 用以构建子 Widget 的 [ImageDetailViewerOption]。
  final List<ImageDetailViewerOption>? options;

  /// The number of children (images) for method [builder] to get how many times
  /// the builder need to build.
  /// 传递给 [builder] 方法，用以判断子 Widget 的个数（即图片的个数）。
  ///
  /// Only valid in [ImageDetailViewer.builder] constructor.
  /// 仅在 [ImageDetailViewer.builder] 构造方法中使用。
  final int? itemCount;

  /// Build Method.
  /// 构建子 Widget 的方法。
  ///
  /// ⚠️ Return a [ImageDetailViewerOption] rather than [Widget].
  /// ⚠️ 返回的应该是一个 [ImageDetailViewerOption] 而不是 [Widget]。
  final ImageDetailViewerOption Function(BuildContext context, int index)?
      builder;

  /// A page controller for the [PageView] Widget insides this plugin.
  /// 控制插件内 [PageView] 的控制器。
  final PageController? pageController;

  final int initialPage;

  final void Function(int)? onPageChanged;

  /// An animation Controller to controll the animation for router transition.
  /// 一个控制路由过渡动画的控制器。
  ///
  /// To accomplish an effect, for example, background color fading when draging
  /// the image down, the controller is needed to notify the router animation.
  /// It's recommanded to use the [ImageDetailViewerFadePageRouter] and
  /// [ImageDetailViewerBlurPageRouter] given by this plugin.
  /// 例如，当需要完成下拉图片背景颜色逐渐透明的效果时，需要用到用到这个控制器来告诉路由中的动
  /// 画需要变化了。推荐使用本插件提供的 [ImageDetailViewerFadePageRouter] 和
  /// [ImageDetailViewerBlurPageRouter]。
  final AnimationController? routerAnimationController;

  /// The scroll physics for [PageView] in this plugin.
  /// 用于给到 [PageView] 中。
  final ScrollPhysics? scrollPhysics;

  /// The scroll direction for [PageView] in this plugin.
  /// 用于给到 [PageView] 中。
  final Axis? scrollDirection;

  ImageDetailViewer({
    Key? key,
    required this.options,
    this.pageController,
    this.routerAnimationController,
    this.scrollPhysics,
    this.scrollDirection,
    this.initialPage = 0,
    this.onPageChanged,
  })  : itemCount = null,
        builder = null,
        super(key: key);

  ImageDetailViewer.builder({
    Key? key,
    required this.itemCount,
    required this.builder,
    this.pageController,
    this.routerAnimationController,
    this.scrollDirection,
    this.scrollPhysics,
    this.initialPage = 0,
    this.onPageChanged,
  })  : options = null,
        super(key: key);

  @override
  _ImageDetailViewerState createState() => _ImageDetailViewerState();
}

class _ImageDetailViewerState extends State<ImageDetailViewer> {
  late PageController _pageController;
  List<SingleImageDetailViewer> pageChildren = [];
  bool disablePageWarp = false;

  void enablePageWarp(bool value) {
    bool newValue = !value;
    if (newValue != disablePageWarp) {
      disablePageWarp = newValue;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.pageController != null) {
      if (widget.pageController!.initialPage != widget.initialPage) {
        _pageController = widget.pageController!
          ..jumpToPage(widget.initialPage);
      } else {
        _pageController = widget.pageController!;
      }
    } else
      _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    List<ImageDetailViewerOption> optionList = [];
    if (widget.options == null) {
      assert(widget.builder != null && widget.itemCount != null);
      // 通过 builder 来获取 optionList
      for (var i = 0; i < widget.itemCount!; i++) {
        optionList.add(widget.builder!(context, i));
      }
    } else
      optionList = widget.options!;

    for (var item in optionList) {
      if (item.image != null) {
        pageChildren.add(SingleImageDetailViewer(
          // isCustom: false,
          image: item.image!,
          showScrollbar: item.showScrollbar,
          tapToPopRouter: item.tapToPopRouter,
          initialScale: item.initialScale,
          maxScale: item.maxScale,
          minScale: item.minScale,
          onLongPress: item.onLongPress,
          enableGestures: item.enableGestures,
          heroTag: item.heroTag,
          routerAnimationController: widget.routerAnimationController,
          enablePageWarp: enablePageWarp,
          pageController: _pageController,
          pagesNum: optionList.length,
          loadingBuilder: item.loadingBuilder,
          errorWidgetBuilder: item.errorWidgetBuilder,
        ));
      } else {
        // assert(item.customBuilder != null);
        // pageChildren.add(SingleImageDetailViewer(
        //   // isCustom: true,
        //   // builder: item.customBuilder,
        //   showScrollbar: item.showScrollbar,
        //   tapToPopRouter: item.tapToPopRouter,
        //   initialScale: item.initialScale,
        //   maxScale: item.maxScale,
        //   minScale: item.minScale,
        //   onLongPress: item.onLongPress,
        //   enableGestures: item.enableGestures,
        //   heroTag: item.heroTag
        // ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      onPageChanged: widget.onPageChanged,
      scrollDirection: widget.scrollDirection ?? Axis.horizontal,
      // physics: disablePageWarp
      //     ? NeverScrollableScrollPhysics()
      //     : widget.scrollPhysics,
      physics: NeverScrollableScrollPhysics(),
      pageSnapping: false,
      controller: _pageController,
      children: pageChildren,
    );
  }
}

Future<T?> showImageDetailViewer<T>(
  BuildContext context, {
  ImageDetailViewerRouters routers = ImageDetailViewerRouters.fadeTransition,
  required List<ImageDetailViewerOption> options,
  PageController? pageController,
  AnimationController? animationController,
  ScrollPhysics? scrollPhysics,
  Axis? scrollDirection,
  Key? key,
  double? blurMaxValue,
  Widget Function(BuildContext)? frontWidgetBuilder,
  void Function(int)? onPageChanged,
  int? initialPage,
  bool hideStatusBarWhenPushIn = false,
  RouteSettings? settings,
}) {
  late PageRoute<T> usingRouter;
  switch (routers) {
    case ImageDetailViewerRouters.fadeTransition:
      usingRouter = ImageDetailViewerFadePageRouter<T>(
        options: options,
        pageController: pageController,
        routerAnimationController: animationController,
        scrollPhysics: scrollPhysics,
        scrollDirection: scrollDirection,
        key: key,
        initialPage: initialPage ?? 0,
        onPageChanged: onPageChanged,
        frontWidgetBuilder: frontWidgetBuilder,
        hideStatusBarWhenPushIn: hideStatusBarWhenPushIn,
        routeSettings: settings,
      );
      break;
    case ImageDetailViewerRouters.blurTransition:
      usingRouter = ImageDetailViewerBlurPageRouter<T>(
        options: options,
        pageController: pageController,
        routerAnimationController: animationController,
        scrollPhysics: scrollPhysics,
        scrollDirection: scrollDirection,
        key: key,
        frontWidgetBuilder: frontWidgetBuilder,
        blurMaxValue: blurMaxValue ?? 40.0,
        initialPage: initialPage ?? 0,
        onPageChanged: onPageChanged,
        hideStatusBarWhenPushIn: hideStatusBarWhenPushIn,
        routeSettings: settings,
      );
      break;
  }
  return Navigator.of(context).push(usingRouter);
}
