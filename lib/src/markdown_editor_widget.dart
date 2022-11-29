import 'package:flutter/material.dart';

import './markdown_editor_toolbar_widget.dart';

class MarkdownEditorWidget extends StatefulWidget {
  final bool constantFocus;
  final TextEditingController? controller;
  final void Function(String text)? onTextEdited;
  const MarkdownEditorWidget(
      {this.controller, this.onTextEdited, this.constantFocus = true, Key? key})
      : super(key: key);

  @override
  State<MarkdownEditorWidget> createState() => _MarkdownEditorWidgetState();
}

class _MarkdownEditorWidgetState extends State<MarkdownEditorWidget> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? TextEditingController();
  }

  void replaceText(int start, int end, String text) {
    var newText = _controller.text.replaceRange(start, end, text);
    setState(() {
      _controller.text = newText;
      _controller.selection = TextSelection.collapsed(offset: start);
    });

    widget.onTextEdited?.call(newText);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.constantFocus) {
      _focusNode.requestFocus();
    }

    return Column(
      children: [
        Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: MarkdownEditorToolbarWidget(_controller, replaceText),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 10, 30, 30),
            child: TextField(
              focusNode: _focusNode,
              // Remove the line at the bottom of the text field.
              decoration: const InputDecoration.collapsed(hintText: ""),
              minLines: 1,
              maxLines: null,
              controller: _controller,
            ),
          ),
        ),
      ],
    );
  }
}
