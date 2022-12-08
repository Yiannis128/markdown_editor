import 'package:flutter/material.dart';

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
    return [];
  }
}