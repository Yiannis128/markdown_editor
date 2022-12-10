import 'package:flutter/material.dart';
import 'package:markdown_editor/src/editor_engine/markdown_parser.dart';

import '../selection_details.dart';
import '../text_edit_context.dart';
import 'toggle_item.dart';

class RangeMarkToggleItem extends ToggleItem {
  final SelectionDetails selectionDetails;
  final String mark;

  RangeMarkToggleItem(
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
        return handleRangeMark(select);
      };

  /// # handleRangeMark
  /// The way it behaves:
  /// * Removes range mark only if selection start/end both touch it.
  /// * Otherwise adds a new one.
  List<TextEdit> handleRangeMark(bool select) {
    final result = <TextEdit>[];
    var start = selectionDetails.start;
    var end = selectionDetails.end;

    var rangeSymbols = getRelevantRangeSymbols();

    // If selection collapsed, then remove range mark in surrounding area.
    if (selectionDetails.selectionCollapsed) {
      if (select) {
        // Create range symbol around selection.
        result.add(TextEdit(mark + mark, start, end, mark.length, mark.length));
      } else {
        for (var rangeSymbol in rangeSymbols) {
          var newText = selectionDetails.text.substring(
            rangeSymbol.selection.baseOffset,
            rangeSymbol.selection.extentOffset,
          );

          result.add(
            TextEdit(
              newText,
              rangeSymbol.selection.baseOffset - 2,
              rangeSymbol.selection.extentOffset + 2,
              -mark.length,
              -mark.length,
            ),
          );
        }
      }
    } else {
      /// NOTE The edit in this scope contains semantically incorrect offsets
      /// for all the TextEdits that add range symbol, meaning that the offsets
      /// don't make sense in an individual view. The reason that the TextEdit
      /// offsets are like this however, is due to the way they are processed.
      /// TextEditContext needs to be refactored in the way it processes
      /// offsets in order to make this semantically correct.

      var hasRangeSymbol = rangeSymbols.isNotEmpty;
      RangeSymbol? rangeSymbol = hasRangeSymbol ? rangeSymbols[0] : null;

      // Is selection start touching start symbol
      if (hasRangeSymbol && start == rangeSymbol!.selection.start) {
        // Remove range symbol
        result.add(
          TextEdit("", start - mark.length, start, -mark.length, -mark.length),
        );
      } else {
        // Add range symbol
        result.add(
          TextEdit(mark, start, start, 0, 0),
        );
      }

      // Is selection end touching end symbol
      if (hasRangeSymbol && end == rangeSymbol!.selection.end) {
        // Remove range symbol
        result.add(
          TextEdit("", end, end + mark.length, 0, 0),
        );
      } else {
        // Add range symbol
        result.add(
          TextEdit(mark, end, end, mark.length, mark.length),
        );
      }
    }

    return result.reversed.toList();
  }

  List<RangeSymbol> getRelevantRangeSymbols() {
    // Get the surrounding range mark.
    var rangeSymbols = MarkdownParser().hasRangeMark(
      selectionDetails.text,
      selectionDetails.selection,
    );

    // Check if anything matches.
    return rangeSymbols.where((element) => element.symbol == mark).toList();
  }
}
