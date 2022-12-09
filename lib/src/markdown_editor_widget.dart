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

  void replaceText(String newText, TextSelection selection) {
    setState(() {
      _controller.value = TextEditingValue(text: newText, selection: selection);
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
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
            child: TextField(
              focusNode: _focusNode,
              // Remove the line at the bottom of the text field.
              decoration: const InputDecoration(
                isCollapsed: true,
                contentPadding: EdgeInsets.all(6),
                hintText: "",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                ),
              ),
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
