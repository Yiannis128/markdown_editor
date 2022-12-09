import 'package:flutter/material.dart';
import 'package:markdown_editor/src/editor_engine/toggle_items/block_quote_toggle_item.dart';
import 'package:markdown_editor/src/editor_engine/markdown_parser.dart';

import 'editor_engine/toggle_items/header_mark_toggle_item.dart';
import 'editor_engine/toggle_items/range_mark_toggle_item.dart';
import 'editor_engine/selection_details.dart';
import 'editor_engine/text_edit_context.dart';
import 'editor_engine/toggle_items/toggle_item.dart';

class MarkdownEditorToolbarWidget extends StatefulWidget {
  final TextEditingController controller;
  final void Function(String, TextSelection)? replaceText;
  const MarkdownEditorToolbarWidget(this.controller, this.replaceText,
      {Key? key})
      : super(key: key);

  @override
  State<MarkdownEditorToolbarWidget> createState() =>
      _MarkdownEditorToolbarWidgetState();
}

class _MarkdownEditorToolbarWidgetState
    extends State<MarkdownEditorToolbarWidget> {
  late final List<ToggleItem> _items;
  late final SelectionDetails _selectionDetails;

  late ToggleItem h1, h2, h3, h4, b, i, s, ul, ol, hl, img, bq, code;

  @override
  void initState() {
    super.initState();

    _selectionDetails = SelectionDetails(widget.controller);
    widget.controller.addListener(textUpdated);

    initToolbarButtons();

    _items = [h1, h2, h3, h4, b, i, s, ul, /* ol,*/ hl, img, bq, code];
  }

  void initToolbarButtons() {
    h1 = HeaderMarkToggleItem(
      const Text("H1"),
      "# ",
      _selectionDetails,
      toggle: true,
    );

    h2 = HeaderMarkToggleItem(
      const Text("H2"),
      "## ",
      _selectionDetails,
      toggle: true,
    );

    h3 = HeaderMarkToggleItem(
      const Text("H3"),
      "### ",
      _selectionDetails,
      toggle: true,
    );

    h4 = HeaderMarkToggleItem(
      const Text("H4"),
      "#### ",
      _selectionDetails,
      toggle: true,
    );

    b = RangeMarkToggleItem(
      const Icon(Icons.format_bold),
      "**",
      _selectionDetails,
      toggle: true,
    );

    i = RangeMarkToggleItem(
      const Icon(Icons.format_italic),
      "__",
      _selectionDetails,
      toggle: true,
    );

    s = RangeMarkToggleItem(
      const Icon(Icons.format_strikethrough),
      "~~",
      _selectionDetails,
      toggle: true,
    );

    ul = HeaderMarkToggleItem(
      const Icon(Icons.format_list_bulleted),
      "* ",
      _selectionDetails,
      toggle: true,
    );

    ol = ToggleItem(const Icon(Icons.format_list_numbered), toggle: true);

    hl = HeaderMarkToggleItem(
      const Icon(Icons.horizontal_rule),
      "---\n",
      _selectionDetails,
      // This class does not remove this mark properly.
      toggle: true,
    );

    img = ToggleItem(const Icon(Icons.image), toggle: false);

    bq = BlockQuoteToggleItem(
      const Icon(Icons.format_quote),
      "> ",
      _selectionDetails,
      toggle: true,
    );

    code = ToggleItem(const Icon(Icons.code), toggle: false);
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
      String? hMark = MarkdownParser().hasHeaderMark(line);
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
          case "---":
            setState(() {
              setEnabledHeader(hl: true);
            });
            break;
          case "> ":
            setState(() {
              setEnabledHeader(bq: true);
            });
            break;
          case "1. ":
            setState(() {
              setEnabledHeader(ol: true);
            });
            break;
        }
      } else {
        // If no header mark, then disable all header mark items.
        setState(() {
          setEnabledHeader();
        });
      }
    } else {
      // Range selections
      var rangeMarks = MarkdownParser().hasRangeMark(
        _selectionDetails.text,
        _selectionDetails.selection,
      );

      bool b = false, i = false, s = false;
      for (var mark in rangeMarks) {
        switch (mark.symbol) {
          case "**":
            b = true;
            break;
          case "__":
            i = true;
            break;
          case "~~":
            s = true;
            break;
        }
      }

      setState(() {
        setEnabledHeader(b: b, i: i, s: s);
      });
    }
  }

  void setEnabledHeader({
    bool h1 = false,
    h2 = false,
    h3 = false,
    h4 = false,
    b = false,
    i = false,
    s = false,
    ul = false,
    ol = false,
    hl = false,
    img = false,
    bq = false,
    code = false,
  }) {
    this.h1.isSelected = h1;
    this.h2.isSelected = h2;
    this.h3.isSelected = h3;
    this.h4.isSelected = h4;
    this.b.isSelected = b;
    this.i.isSelected = i;
    this.s.isSelected = s;
    this.ul.isSelected = ul;
    this.ol.isSelected = ol;
    this.hl.isSelected = hl;
    this.img.isSelected = img;
    this.bq.isSelected = bq;
    this.code.isSelected = code;
  }

  void toggleButtonPressed(int index, List<ToggleItem> rowItems) {
    // Get the ToggleItem widget that is pressed.
    var itemWidget = rowItems[index];

    // Apply formatting to get the new line after formatting is done.
    List<TextEdit> edits = itemWidget.use();

    // Update toggle item state.
    setState(() {
      rowItems[index] = itemWidget;
    });

    final editContext = TextEditContext(_selectionDetails.selection);
    editContext.addEdits(edits);

    // Call replace text to propagate changes to InputField widget.
    if (editContext.stack.isNotEmpty) {
      var newText = editContext.apply(widget.controller.text);

      var newTextSelection = editContext.getNewTextSelection()!;
      widget.replaceText?.call(newText, newTextSelection);
    }

    // Update the selection details after calling replaceText.
    _selectionDetails.update();
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
            onPressed: (index) {
              toggleButtonPressed(index, rowItems);
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
