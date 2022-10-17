import 'package:html/dom.dart';
import 'package:http/http.dart';
import 'package:html/parser.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:robin_flutter/src/components/message-group/url-preview/url_description.dart';
import 'package:robin_flutter/src/components/message-group/url-preview/url_image.dart';
import 'package:robin_flutter/src/components/message-group/url-preview/url_title.dart';

/// Provides URL preview
class UrlPreview extends StatefulWidget {
  /// URL for which preview is to be shown
  final String url;

  const UrlPreview({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  _UrlPreviewState createState() => _UrlPreviewState();
}

class _UrlPreviewState extends State<UrlPreview> {
  Map? _urlPreviewData;
  bool _isVisible = true;
  EdgeInsetsGeometry? _previewContainerPadding;

  @override
  void initState() {
    super.initState();
    _getUrlData();
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
    if (_urlPreviewData == null || !_isVisible) {
      return const SizedBox();
    }

    return Container(
      padding: _previewContainerPadding,
      child: GestureDetector(
        onTap: _launchURL,
        child: _buildPreviewCard(context),
      ),
    );
  }

  Container _buildPreviewCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
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
                  const TextStyle(
                    fontSize: 14,
                    color: Color(0XFF000000),
                  ),
                  2,
                ),
                const SizedBox(
                  height: 3,
                ),
                PreviewDescription(
                    _urlPreviewData!['og:description'],
                    const TextStyle(
                      fontSize: 11,
                      color: Color(0XFF000000),
                    ),
                    2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
