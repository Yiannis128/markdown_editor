import 'package:flutter/material.dart';

class MarkdownEditorToolbarWidget extends StatefulWidget {
  final TextEditingController controller;
  final void Function(int start, int end, String text)? replaceText;
  const MarkdownEditorToolbarWidget(this.controller, this.replaceText, {Key? key})
      : super(key: key);

  @override
  State<MarkdownEditorToolbarWidget> createState() => _MarkdownEditorToolbarWidgetState();
}

class _MarkdownEditorToolbarWidgetState extends State<MarkdownEditorToolbarWidget> {
  late final List<_ToggleItem> _items;
  late final _SelectionDetails _selectionDetails;

  late _ToggleItem h1, h2, h3, h4, b, i, u, s, ul, ol, hl;

  @override
  void initState() {
    super.initState();

    _selectionDetails = _SelectionDetails(widget.controller);
    widget.controller.addListener(textUpdated);

    initToolbarButtons();

    _items = [h1, h2, h3, h4, /*b, i, u, s,*/ ul/*, ol, hl*/];
  }

  void initToolbarButtons() {
    h1 = _HeaderMarkToggleItem(
      const Text("H1"),
      "# ",
      _selectionDetails,
      toggle: true,
    );

    h2 = _HeaderMarkToggleItem(
      const Text("H2"),
      "## ",
      _selectionDetails,
      toggle: true,
    );

    h3 = _HeaderMarkToggleItem(
      const Text("H3"),
      "### ",
      _selectionDetails,
      toggle: true,
    );

    h4 = _HeaderMarkToggleItem(
      const Text("H4"),
      "#### ",
      _selectionDetails,
      toggle: true,
    );

    b = _ToggleItem(const Icon(Icons.format_bold), toggle: true);

    i = _ToggleItem(const Icon(Icons.format_italic), toggle: true);

    u = _ToggleItem(const Icon(Icons.format_underline), toggle: true);

    s = _ToggleItem(const Icon(Icons.format_strikethrough), toggle: true);

    ul = _HeaderMarkToggleItem(
      const Icon(Icons.format_list_bulleted),
      "* ",
      _selectionDetails,
      toggle: true,
    );

    ol = _ToggleItem(const Icon(Icons.format_list_numbered), toggle: true);

    hl = _ToggleItem(const Icon(Icons.horizontal_rule), toggle: true);
  }

  void textUpdated() {
    _selectionDetails.update();
    var start = _selectionDetails.start;
    var end = _selectionDetails.end;
    var line = _selectionDetails.line;

    // Check if nothing is selected.
    if (start == end) {
      // Detect all marks.
      // Start with header marks.
      String? hMark = hasHeaderMark(line);
      if (hMark != null) {
        // Activate all the appropriate h mark.
        switch (hMark) {
          case "# ":
            setState(() {
              setEnabledHeader(h1: true);
            });
            break;
          case "## ":
            setState(() {
              setEnabledHeader(h2: true);
            });
            break;
          case "### ":
            setState(() {
              setEnabledHeader(h3: true);
            });
            break;
          case "#### ":
            setState(() {
              setEnabledHeader(h4: true);
            });
            break;
          case "* ":
            setState(() {
              setEnabledHeader(ul: true);
            });
            break;
          case "1. ":
            setState(() {
              setEnabledHeader(ol: true);
            });
            break;
        }
      } else {
        setState(() {
          setEnabledHeader();
        });
      }
    }
  }

  void setEnabledHeader({
    bool h1 = false,
    h2 = false,
    h3 = false,
    h4 = false,
    ul = false,
    ol = false,
  }) {
    this.h1.isSelected = h1;
    this.h2.isSelected = h2;
    this.h3.isSelected = h3;
    this.h4.isSelected = h4;
    this.ul.isSelected = ul;
    this.ol.isSelected = ol;
  }

  /// # hasHeaderMark
  ///
  /// Detects if the text `line` provided has a header mark. A header mark
  /// counts as any of the # marks, along with the list marks.
  String? hasHeaderMark(String line) {
    var start = line.trimLeft();
    if (start.startsWith("#### ")) {
      return "#### ";
    } else if (start.startsWith("### ")) {
      return "### ";
    } else if (start.startsWith("## ")) {
      return "## ";
    } else if (start.startsWith("# ")) {
      return "# ";
    } else if (start.startsWith("* ")) {
      return "* ";
    } else {
      /// Check for ordered list. Start by separating the number.
      /// Find the . and see if the string left is a number.
      var pointIndex = start.indexOf(".");
      if (pointIndex != -1) {
        var numberStr = start.characters.getRange(0, pointIndex).toString();
        var number = int.tryParse(numberStr);
        if (number != null) {
          return "1. ";
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // The itemWidth is a number that is not the actual item width
        // but more of an area reserved for each item.
        const double itemWidth = 60;
        int itemCountPerRow = (constraints.maxWidth / itemWidth).ceil();
        int maxRows = (_items.length / itemCountPerRow).ceil();

        var results = <Widget>[];

        // Build each row.
        for (var rowIndex = 0; rowIndex < maxRows; rowIndex++) {
          var startIndex = rowIndex * itemCountPerRow;
          var endIndex = startIndex + itemCountPerRow;
          if (endIndex >= _items.length) {
            endIndex = _items.length;
          }

          var rowItems = _items.sublist(startIndex, endIndex);
          // Add to results.
          results.add(ToggleButtons(
            isSelected:
                rowItems.map((e) => e.isSelected).toList(growable: false),
            children: rowItems.map((e) => e.body).toList(growable: false),
            // ToggleButton action.
            onPressed: (index) {
              var item = rowItems[index];

              // Apply formatting to get newLine after formatting is done.
              _TextEdit? edit = item.use();

              // Call replace text to propagate changes to InputField widget.
              if (edit != null) {
                widget.replaceText?.call(
                  edit.startIndex,
                  edit.endIndex,
                  edit.newText,
                );
                _selectionDetails.updateSelection(edit.selection);
              }

              // Update toggle item state.
              setState(() {
                rowItems[index] = item;
              });

              _selectionDetails.update();
            },
          ));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: results,
        );
      },
    );
  }
}

class _TextEdit {
  final String newText;
  final int startIndex;
  final int endIndex;
  final TextSelection selection;
  _TextEdit(this.newText, this.startIndex, this.endIndex, this.selection);
}

/// # _ToggleItem
///
/// Class that represents an item on the toolbox at the top of the editor.
class _ToggleItem {
  Key? key;

  /// _toggle: If the item can be toggled.
  final bool _toggle;
  final Widget body;
  bool isSelected = false;
  _TextEdit? Function(bool)? onUse;

  _ToggleItem(this.body, {bool toggle = false, this.onUse}) : _toggle = toggle {
    key = body.key;
  }

  _TextEdit? use() {
    if (_toggle) {
      isSelected = !isSelected;
    }
    return onUse?.call(isSelected);
  }
}

class _HeaderMarkToggleItem extends _ToggleItem {
  final _SelectionDetails _selectionDetails;
  final String mark;

  _HeaderMarkToggleItem(
    Widget body,
    this.mark,
    this._selectionDetails, {
    bool toggle = false,
  }) : super(
          body,
          toggle: toggle,
        );

  @override
  _TextEdit? Function(bool select)? get onUse => (select) {
        return handleHeaderMark(mark, select);
      };

  _TextEdit handleHeaderMark(String mark, bool select) {
    var line = _selectionDetails.line;
    var selOffset = select ? mark.length : -mark.length;
    var selection = TextSelection.collapsed(
      offset: _selectionDetails.selection.baseOffset + selOffset,
    );
    if (select) {
      return _TextEdit(
        mark + line,
        _selectionDetails.lineStart,
        _selectionDetails.lineEnd,
        selection,
      );
    } else {
      return _TextEdit(
        line.replaceFirst(mark, ""),
        _selectionDetails.lineStart,
        _selectionDetails.lineEnd,
        selection,
      );
    }
  }
}

/// # _SelectionDetails
///
/// Contains useful information regarding the currently selected text in
/// the text field that the EditorBarWidget is interacting with.
class _SelectionDetails {
  late TextEditingController controller;
  late TextSelection selection;
  late String text;
  late int start;
  late int end;

  /// before: The text before the selection point.
  late String before;

  /// after: The text after the selection point.
  late String after;

  /// lineStart: Index describing point at which the selected line starts.
  late int lineStart;

  /// lineEnd: Index describing point at which the selected line ends.
  late int lineEnd;

  /// line: The line at which the cursor is currently on.
  late String line;

  _SelectionDetails(this.controller);

  void updateSelection(TextSelection selection) {
    controller.selection = selection;
  }

  void update() {
    selection = controller.selection;
    text = controller.value.text;
    start = selection.start;
    end = selection.end;
    if (selection.isValid) {
      before = selection.textBefore(text);
      after = selection.textAfter(text);
      lineStart = before.lastIndexOf('\n') + 1;
      if (lineStart == -1) {
        lineStart = 0;
      }
      lineEnd = after.indexOf('\n');
      if (lineEnd == -1) {
        lineEnd = text.length;
      } else {
        lineEnd = before.length + lineEnd;
      }
      line = before.split('\n').last + after.split('\n').first;
    }
  }
}
