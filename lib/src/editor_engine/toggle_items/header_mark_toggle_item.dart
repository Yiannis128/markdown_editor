import 'package:flutter/material.dart';

import '../selection_details.dart';
import '../text_edit_context.dart';
import 'toggle_item.dart';

/// # HeaderMarkToggleitem
/// Class that extends `_ToggleItem` and is used to add and remove markets from
/// the start of the line. Is used to implement markers such as headers and
/// unordered list.
class HeaderMarkToggleItem extends ToggleItem {
  final SelectionDetails selectionDetails;
  final String mark;

  HeaderMarkToggleItem(
    Widget body,
    this.mark,
    this.selectionDetails, {
    bool toggle = false,
  }) : super(
          body,
          toggle: toggle,
        );

  @override
  List<TextEdit> Function(bool select)? get onUse => (select) {
        return handleHeaderMark(select);
      };

  List<TextEdit> handleHeaderMark(bool select) {
    if (selectionDetails.selectionCollapsed) {
      var line = selectionDetails.line;
      if (select) {
        return [
          TextEdit(
            mark + line,
            selectionDetails.lineStart,
            selectionDetails.lineEnd,
            mark.length,
            mark.length,
          ),
        ];
      } else {
        // Account for cursor moving to previous line if header is removed if
        // it's at the start of the line.
        // Check if cursor is in the remove region and set it to start of line.
        var offset =
            selectionDetails.start - mark.length < selectionDetails.lineStart
                ? -selectionDetails.start + selectionDetails.lineStart
                : -mark.length;
        return [
          TextEdit(
            line.replaceFirst(mark, ""),
            selectionDetails.lineStart,
            selectionDetails.lineEnd,
            offset,
            offset,
          ),
        ];
      }
    } else {
      final edits = <TextEdit>[];
      final newLineLocs = <int>[selectionDetails.lineStart];
      for (var i = 0;
          i < selectionDetails.selectedText.characters.length;
          i++) {
        var c = selectionDetails.selectedText[i];
        if (c == "\n") {
          newLineLocs.add(selectionDetails.start + i + 1);
        }
      }

      int selectionOffset;
      if (select) {
        selectionOffset = mark.length;
      } else {
        // Account for cursor moving to previous line if header is removed if
        // it's at the start of the line.
        // Check if cursor is in the remove region and set it to start of line.
        selectionOffset =
            selectionDetails.start - mark.length < selectionDetails.lineStart
                ? -selectionDetails.start + selectionDetails.lineStart
                : -mark.length;
      }

      for (var i = 0; i < newLineLocs.length; i++) {
        var newLineLoc = newLineLocs[i];
        var newLineEnd = i + 1 < newLineLocs.length
            ? newLineLocs[i + 1]
            : selectionDetails.end;
        var line = selectionDetails.text.substring(newLineLoc, newLineEnd);

        edits.add(TextEdit(
          select ? mark + line : line.replaceFirst(mark, ""),
          newLineLoc,
          newLineEnd,
          selectionOffset,
          selectionOffset,
        ));
      }

      return edits.reversed.toList();
    }
  }
}
