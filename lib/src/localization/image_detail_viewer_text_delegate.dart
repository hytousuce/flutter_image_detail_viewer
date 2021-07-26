/// Text Delegate for text in the plugin. Default in Chinese.
/// 默认的中文文本实现类。
///
/// Get more information about specific language text delegates, see:
/// * [ChineseImageDetailViewerTextDelegate]
/// * [EnglishImageDetailViewerTextDelegate]
abstract class ImageDetailViewerTextDelegate {
  const ImageDetailViewerTextDelegate();

  /// Tag text for piiics (long pictures).
  /// 长图的显示标签文本
  String get piiic;

  /// Tag text for animated pictures.
  /// 动图的显示标签文本
  String get animatedPicture;
}

/// Chinese implement for [ImageDetailViewerTextDelegate]
/// 中文文本代理类。
class ChineseImageDetailViewerTextDelegate
    extends ImageDetailViewerTextDelegate {
  @override
  String get piiic => "长图";

  @override
  String get animatedPicture => "动图";
}

/// English implement for [ImageDetailViewerTextDelegate]
/// Text delegate for English.
class EnglishImageDetailViewerTextDelegate
    extends ImageDetailViewerTextDelegate {
  @override
  String get piiic => "PIIIC";

  @override
  String get animatedPicture => "GIF";
}
