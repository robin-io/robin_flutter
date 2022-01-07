import 'package:flutter/material.dart';

/// Shows description of URL
class PreviewDescription extends StatelessWidget {
  final String? _description;
  final TextStyle? _textStyle;
  final int? _descriptionLines;

  const PreviewDescription(
      this._description, this._textStyle, this._descriptionLines,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (_description == null) {
      return Container();
    }

    return Flexible(
      child: Text(
        _description!,
        overflow: TextOverflow.clip,
        textAlign: TextAlign.left,
        maxLines: _descriptionLines,
        softWrap: true,
        style: _textStyle,
      ),
    );
  }
}
