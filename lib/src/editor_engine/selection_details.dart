import 'package:flutter/material.dart';

/// # _SelectionDetails
///
/// Contains useful information regarding the currently selected text in
/// the text field that the EditorBarWidget is interacting with.
class SelectionDetails {
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

  SelectionDetails(this.controller);

  /// # updateSelection
  /// Updates the current selection object.
  void updateSelection(TextSelection selection) {
    controller.selection = selection;
  }

  /// # update
  /// Updates the selection details of this object, this should be called after
  /// `updateSelection`.
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