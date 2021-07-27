import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'package:flutter_image_detail_viewer/flutter_image_detail_viewer.dart';
import 'package:flutter_image_detail_viewer/src/utils/screen_utils.dart';

/// An image Widget which supports displaying a image type (piiic, gif, etc.)
/// tag at the bottom-left corner in default and custom image display part
/// settings.
///
/// 支持（默认在左下角）显示图片类型标签以及自定义图片显示位置（通过规定显示部分左上角的坐标以
/// 及长或宽一边长）的图片部件。
class TypeTaggedImage extends StatefulWidget {
  final ImageProvider<Object> image;
  final double? width;
  final double? height;
  final ImageDisplayPartSetting? displaySetting;
  final ImageLoadingBuilder? loadingBuilder;
  final ImageErrorWidgetBuilder? errorWidgetBuilder;

  /// The builder for your custom tag.
  /// 用以自定义标签的 builder。
  final Widget Function(BuildContext context, String tagText)? tagBuilder;

  /// The text delegate for tag. Used for DIY or localize your tag texts.
  /// 标签上文字的代理，用以本地化翻译。
  final ImageDetailViewerTextDelegate? textDelegate;

  /// The [Decoration] for [Container] widget of the child of this widget.
  /// 本 Widget 第一层的 Container 的 [Decoration]。
  final Decoration? decoration;

  /// The offset of image-type tag.
  /// 图像类型标签的位置偏移量
  ///
  /// ⚠️ Please notice that the offset takes the bottom-left corner as the
  /// origin of the coordinates.
  /// ⚠️ 注意：本 Offset 以图片的左下角作为坐标原点
  ///
  /// If not specified, there will have an `Offset(5.0, 5.0)` as default.
  /// 若不提供，默认值为 `Offset(5.0, 5.0)`。
  final Offset? tagOffset;

  /// The `clipBehavior` for [Container] widget of the child of this widget.
  /// 本 Widget 第一层的 [Container] 的 `clipBehavior`
  final Clip? clipBehavior;

  /// Function to judge whether the given image is a gif image.
  /// 判断图片是否为 GIF 的方法。
  ///
  /// When the given image's provider is not one of [NetworkImage],
  /// [AssetBundleImageProvider], [MemoryImage] or [FileImage], the plugin has
  /// no idea to judge whether the image is a gif image. This function will be
  /// called when the image has complete loading and start to judge its type.
  /// It will be called before the plugin itself trying to judge which type the
  /// image is.
  /// 当图片的 Provider 并非 [NetworkImage]、[AssetBundleImageProvider]、
  /// [MemoryImage] 或 [FileImage] 中的一种时，本插件将不知如何来判断。这个方法将会在图片
  /// 加载完成开始判断图片类型时，且会优先于本插件本身的判断方法被调用。
  ///
  /// Because of no other idea than judging by whether the image's filename
  /// contains '.gif' sub-string, it's recommand to provide this parameter if
  /// you get a great idea to judge. If you are sure that your idea is correct
  /// and universal, it's welcome to improve this plugin by submitting a PR.
  /// 由于我实在找不出通过判断文件名中是否包含有'.gif'子串以外的方式来判断是否为动图，所以如果
  /// 你有更好的判断方法的话，最好提供这个参数。如果你确信你的方法合理且通用，欢迎提交PR来完善
  /// 本插件。
  final bool Function(ImageProvider image)? judgeGif;

  /// The argument will pass to [Image]. 本参数将传递给[Image]。
  final String? semanticLabel;

  /// The argument will pass to [Image]. 本参数将传递给[Image]。
  ///
  /// The default value is / 默认值为: `false`
  final bool? excludeFromSemantics;

  /// The argument will pass to [Image]. 本参数将传递给[Image]。
  final Color? color;

  /// The argument will pass to [Image]. 本参数将传递给[Image]。
  final BlendMode? colorBlendMode;

  /// The argument will pass to [Image]. 本参数将传递给[Image]。
  final BoxFit? fit;

  /// The argument will pass to [Image]. 本参数将传递给[Image]。
  ///
  /// The default value is / 默认值为: [Alignment.center]
  final Alignment? alignment;

  /// The argument will pass to [Image]. 本参数将传递给[Image]。
  ///
  /// The default value is / 默认值为: [ImageRepeat.noRepeat]
  final ImageRepeat? repeat;

  /// The argument will pass to [Image]. 本参数将传递给[Image]。
  final Rect? centerSlice;

  /// The argument will pass to [Image]. 本参数将传递给[Image]。
  ///
  /// The default value is / 默认值为: `false`
  final bool? matchTextDirection;

  /// The argument will pass to [Image]. 本参数将传递给[Image]。
  ///
  /// The default value is / 默认值为: `false`
  final bool? gaplessPlayback;

  /// The argument will pass to [Image]. 本参数将传递给[Image]。
  ///
  /// The default value is / 默认值为: `false`
  final bool? isAntiAlias;

  /// The argument will pass to [Image]. 本参数将传递给[Image]。
  ///
  /// The default value is / 默认值为: [FilterQuality.low]
  final FilterQuality? filterQuality;

  const TypeTaggedImage({
    Key? key,
    required this.image,
    this.height,
    this.width,
    this.tagOffset,
    this.decoration,
    this.clipBehavior,
    this.displaySetting,
    this.loadingBuilder,
    this.errorWidgetBuilder,
    this.textDelegate,
    this.tagBuilder,
    this.judgeGif,
    this.semanticLabel,
    this.excludeFromSemantics,
    this.color,
    this.colorBlendMode,
    this.fit,
    this.alignment,
    this.repeat,
    this.centerSlice,
    this.matchTextDirection,
    this.gaplessPlayback,
    this.isAntiAlias,
    this.filterQuality,
  }) : super(key: key);

  @override
  _TypeTaggedImageState createState() => _TypeTaggedImageState();
}

class _TypeTaggedImageState extends State<TypeTaggedImage> {
  _ImageType _imageType = _ImageType.normal;
  ImageStream? _imageStream;
  ImageInfo? _imageInfo;
  ImageChunkEvent? _loadingProgress;
  bool _isListeningToStream = false;
  Object? _lastException;
  StackTrace? _lastStack;
  ImageStreamCompleterHandle? _completerHandle;

  late DisposableBuildContext<State<TypeTaggedImage>> _scrollAwareContext;

  // 最外层 [Container] 的key，用以获取高度
  GlobalKey _containerKey = GlobalKey();

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
    if (widget.judgeGif != null && widget.judgeGif!.call(widget.image)) {
      // 通过用户提供的方法实现了
      if (mounted)
        setState(() {
          _imageType = _ImageType.animated;
        });
      return;
    } else if (widget.image is NetworkImage) {
      if ((widget.image as NetworkImage).url.toLowerCase().contains('.gif')) {
        if (mounted)
          setState(() {
            _imageType = _ImageType.animated;
          });
        return;
      }
    } else if (widget.image is AssetImage) {
      if ((widget.image as AssetImage)
          .assetName
          .toLowerCase()
          .contains('.gif')) {
        if (mounted)
          setState(() {
            _imageType = _ImageType.animated;
          });
        return;
      }
    } else if (widget.image is MemoryImage) {
      try {
        ui.Codec codec = await PaintingBinding.instance!
            .instantiateImageCodec((widget.image as MemoryImage).bytes);
        if (codec.frameCount >= 1) {
          if (mounted)
            setState(() {
              _imageType = _ImageType.animated;
            });
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
          if (mounted) {
            setState(() {
              _imageType = _ImageType.animated;
            });
          }
          return;
        }
      } catch (_) {}
    }
    int height = imageInfo.image.height;
    int width = imageInfo.image.width;
    if (height / width > ScreenUtils.ratio) {
      if (mounted)
        setState(() {
          _imageType = _ImageType.piiic;
        });
      return;
    }
    _imageType = _ImageType.normal;
    return;
  }

  void _handleImageFrame(ImageInfo imageInfo, bool synchronousCall) {
    // 判断图片类型
    judgeImageType(imageInfo);
    setState(() {
      _replaceImage(imageInfo: imageInfo);
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

  void _replaceImage({required ImageInfo? imageInfo}) {
    _imageInfo?.dispose();
    _imageInfo = imageInfo;
  }

  void _resolveImage() {
    final ScrollAwareImageProvider provider = ScrollAwareImageProvider<Object>(
        context: _scrollAwareContext, imageProvider: widget.image);
    final ImageStream newStream =
        provider.resolve(createLocalImageConfiguration(
      context,
      size: widget.width != null && widget.height != null
          ? Size(widget.width!, widget.height!)
          : null,
    ));
    _updateSourceStream(newStream);
  }

  void _updateSourceStream(ImageStream newStream) {
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

  @override
  void initState() {
    super.initState();
    _scrollAwareContext = DisposableBuildContext<State<TypeTaggedImage>>(this);
  }

  @override
  void dispose() {
    assert(_imageStream != null);
    _stopListeningToStream();
    _completerHandle?.dispose();
    _scrollAwareContext.dispose();
    _replaceImage(imageInfo: null);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _resolveImage();
    if (TickerMode.of(context))
      _listenToStream();
    else
      _stopListeningToStream(keepStreamAlive: true);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (_lastException != null) {
      assert(widget.errorWidgetBuilder != null);
      return widget.errorWidgetBuilder!(context, _lastException!, _lastStack);
    }
    Widget image = Image(
      image: widget.image,
      semanticLabel: widget.semanticLabel,
      excludeFromSemantics: widget.excludeFromSemantics ?? false,
      color: widget.color,
      colorBlendMode: widget.colorBlendMode,
      fit: widget.fit,
      alignment: widget.alignment ?? Alignment.center,
      repeat: widget.repeat ?? ImageRepeat.noRepeat,
      centerSlice: widget.centerSlice,
      matchTextDirection: widget.matchTextDirection ?? false,
      gaplessPlayback: widget.gaplessPlayback ?? false,
      isAntiAlias: widget.isAntiAlias ?? false,
      filterQuality: widget.filterQuality ?? FilterQuality.low,
    );
    if (widget.loadingBuilder != null)
      image = widget.loadingBuilder!(context, image, _loadingProgress);
    return Container(
      key: _containerKey,
      height: widget.height,
      width: widget.width,
      decoration: widget.decoration,
      clipBehavior: widget.clipBehavior ?? Clip.none,
      child: LayoutBuilder(
        builder: (context, size) {
          double tagToLeft =
              widget.tagOffset == null ? 5.0 : widget.tagOffset!.dx;
          double tagToBottom =
              widget.tagOffset == null ? 5.0 : widget.tagOffset!.dy;
          ImageDetailViewerTextDelegate textDelegate =
              widget.textDelegate ?? ChineseImageDetailViewerTextDelegate();
          late String tagString;
          switch (_imageType) {
            case _ImageType.animated:
              tagString = textDelegate.animatedPicture;
              break;
            case _ImageType.piiic:
              tagString = textDelegate.piiic;
              break;
            case _ImageType.normal:
              tagString = "";
              break;
          }
          return Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                width: size.maxWidth,
                height: size.maxHeight,
                child: image,
              ),
              Positioned(
                left: tagToLeft,
                bottom: tagToBottom,
                child: Offstage(
                  offstage: _imageType == _ImageType.normal,
                  child: widget.tagBuilder == null
                      ? Container(
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          padding: EdgeInsets.all(5),
                          child: Text(tagString),
                        )
                      : widget.tagBuilder!(context, tagString),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

enum _ImageType {
  /// Long Picture 长图
  piiic,

  /// Animated Picture 动图
  animated,

  /// Normal Picture 一般图片
  normal,
}
