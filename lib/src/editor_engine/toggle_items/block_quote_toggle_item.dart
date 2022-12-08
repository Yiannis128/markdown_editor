import 'package:flutter/material.dart';
import 'package:markdown_editor/src/editor_engine/toggle_items/header_mark_toggle_item.dart';
import 'package:markdown_editor/src/editor_engine/markdown_parser.dart';
import 'package:markdown_editor/src/editor_engine/selection_details.dart';

import '../text_edit_context.dart';

class BlockQuoteToggleItem extends HeaderMarkToggleItem {
  BlockQuoteToggleItem(
      Widget body, String mark, SelectionDetails selectionDetails,
      {bool toggle = false})
      : super(
          body,
          mark,
          selectionDetails,
          toggle: toggle,
        );

  @override
  List<TextEdit> handleHeaderMark(bool select) {
    final result = <TextEdit>[];
    var res = MarkdownParser().getSelectedParagraphs(
      selectionDetails.text,
      selectionDetails.selection,
    );

    List<String> paragraphs = res[0];
    int pStart = res[1];

    if (select) {
      for (var p in paragraphs) {
        result.add(TextEdit(
          mark + p,
          pStart,
          pStart + p.length,
          mark.length,
          mark.length,
        ));
        // Account for \n\n.
        pStart += p.length + 2;
      }
    } else {
      // TODO
    }

    return result.reversed.toList();
  }
}
