import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:robin_flutter/src/components/url-preview/url_description.dart';
import 'package:robin_flutter/src/components/url-preview/url_image.dart';
import 'package:robin_flutter/src/components/url-preview/url_title.dart';

import 'package:url_launcher/url_launcher.dart';

/// Provides URL preview
class UrlPreview extends StatefulWidget {
  /// URL for which preview is to be shown
  final String url;

  /// Height of the preview
  final double previewHeight;

  /// Whether or not to show close button for the preview
  final bool? isClosable;

  /// Background color
  final Color? bgColor;

  /// Style of Title.
  final TextStyle? titleStyle;

  /// Number of lines for Title. (Max possible lines = 2)
  final int titleLines;

  /// Style of Description
  final TextStyle? descriptionStyle;

  /// Number of lines for Description. (Max possible lines = 3)
  final int descriptionLines;

  /// Style of site title
  final TextStyle? siteNameStyle;

  /// Color for loader icon shown, till image loads
  final Color? imageLoaderColor;

  /// Container padding
  final EdgeInsetsGeometry? previewContainerPadding;

  /// onTap URL preview, by default opens URL in default browser
  final VoidCallback? onTap;

  const UrlPreview({
    Key? key,
    required this.url,
    this.previewHeight = 130.0,
    this.isClosable,
    this.bgColor,
    this.titleStyle,
    this.titleLines = 2,
    this.descriptionStyle,
    this.descriptionLines = 3,
    this.siteNameStyle,
    this.imageLoaderColor,
    this.previewContainerPadding,
    this.onTap,
  })  : assert(previewHeight >= 130.0,
            'The preview height should be greater than or equal to 130'),
        assert(titleLines <= 2 && titleLines > 0,
            'The title lines should be less than or equal to 2 and not equal to 0'),
        assert(descriptionLines <= 3 && descriptionLines > 0,
            'The description lines should be less than or equal to 3 and not equal to 0'),
        super(key: key);

  @override
  _UrlPreviewState createState() => _UrlPreviewState();
}

class _UrlPreviewState extends State<UrlPreview> {
  Map? _urlPreviewData;
  bool _isVisible = true;
  TextStyle? _titleStyle;
  int? _titleLines;
  TextStyle? _descriptionStyle;
  int? _descriptionLines;
  Color? _imageLoaderColor;
  EdgeInsetsGeometry? _previewContainerPadding;
  VoidCallback? _onTap;

  @override
  void initState() {
    super.initState();
    _getUrlData();
  }

  void _initialize() {
    _descriptionStyle = widget.descriptionStyle;
    _descriptionLines = widget.descriptionLines;
    _titleStyle = widget.titleStyle;
    _titleLines = widget.titleLines;
    _previewContainerPadding = widget.previewContainerPadding;
    _onTap = widget.onTap ?? _launchURL;
  }

  void _getUrlData() async {
    try {
      var response = await get(Uri.parse(widget.url));
      if (response.statusCode != 200) {
        if (!mounted) {
          return;
        }
        setState(() {
          _urlPreviewData = null;
        });
      }

      var document = parse(response.body);
      Map data = {};
      _extractOGData(document, data, 'og:title');
      _extractOGData(document, data, 'og:description');
      _extractOGData(document, data, 'og:site_name');
      _extractOGData(document, data, 'og:image');

      if (!mounted) {
        return;
      }

      if (data.isNotEmpty) {
        setState(() {
          _urlPreviewData = data;
          _isVisible = true;
        });
      }
    } catch (e) {
      //invalid url
    }
  }

  void _extractOGData(Document document, Map data, String parameter) {
    var titleMetaTag = document
        .getElementsByTagName("meta")
        .firstWhereOrNull((meta) => meta.attributes['property'] == parameter);
    if (titleMetaTag != null) {
      data[parameter] = titleMetaTag.attributes['content'];
    }
  }

  void _launchURL() async {
    if (await canLaunch(Uri.encodeFull(widget.url))) {
      await launch(Uri.encodeFull(widget.url));
    } else {
      throw 'Could not launch ${widget.url}';
    }
  }

  @override
  Widget build(BuildContext context) {
    _imageLoaderColor = Colors.black;
    _initialize();

    if (_urlPreviewData == null || !_isVisible) {
      return const SizedBox();
    }

    return Container(
      padding: _previewContainerPadding,
      child: GestureDetector(
        onTap: _onTap,
        child: _buildPreviewCard(context),
      ),
    );
  }

  Container _buildPreviewCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: const Color(0XFFFFFFFF),
      ),
      constraints: const BoxConstraints(
        minHeight: 55,
      ),
      padding: const EdgeInsets.fromLTRB(7, 7, 7, 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          PreviewImage(
            _urlPreviewData!['og:image'],
            _imageLoaderColor,
          ),
          const SizedBox(
            width: 7,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                PreviewTitle(
                  _urlPreviewData!['og:title'],
                  _titleStyle ??
                      const TextStyle(
                        fontSize: 14,
                        color: Color(0XFF000000),
                      ),
                  _titleLines,
                ),
                const SizedBox(
                  height: 3,
                ),
                PreviewDescription(
                  _urlPreviewData!['og:description'],
                  _descriptionStyle ??
                      const TextStyle(
                        fontSize: 11,
                        color: Color(0XFF000000),
                      ),
                  _descriptionLines,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
