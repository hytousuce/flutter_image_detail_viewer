/// A value represents which route widget will be used.
/// 代表哪一个 router widget 会被使用的值。
enum ImageDetailViewerRouters {
  /// Indicating a router with fade transition effect.
  /// 表示一个使用背景透明渐变效果的路由将会被使用
  ///
  /// [ImageDetailViewerFadePageRouter]
  fadeTransition,

  /// Indicating a router with blur transition effect.
  /// 表示一个使用背景高斯模糊效果的路由将会被使用
  ///
  /// [ImageDetailViewerBlurPageRouter]
  blurTransition,
}
