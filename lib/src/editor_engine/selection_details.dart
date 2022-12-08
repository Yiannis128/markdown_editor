import 'package:flutter/material.dart';

/// # _SelectionDetails
///
/// Contains useful information regarding the currently selected text in
/// the text field that the EditorBarWidget is interacting with.
class SelectionDetails {
  late TextEditingController controller;
  TextSelection get selection => controller.selection;
  String get text => controller.value.text;
  int get start => selection.start;
  int get end => selection.end;
  
  late String selectedText;

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

  bool get selectionCollapsed {
    return selectedText.isEmpty;
  }

  /// # update
  /// Updates the selection details of this object, this should be called after
  /// `updateSelection`.
  void update() {
    if (selection.isValid) {
      selectedText = text.characters.getRange(start, end).toString();
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
        lineEnd = end + lineEnd;
      }
      line = before.split('\n').last + selectedText + after.split('\n').first;
    }
  }
  
  @override
  String toString() {
    String s = """
Selection:
  - start:     $start
  - end:       $end
  - lineStart: $lineStart
  - lineEnd:   $lineEnd

  - line
  ==============
  $line
  ==============

  - before
  ==============
  $before
  ==============

  - after
  ==============
  $after
  ==============

  - selectedText
  ==============
  $selectedText
  ==============
""";
    return s;
  }

  @override
  bool operator ==(Object other) {
    if (other is! SelectionDetails) {
      return false;
    }
    return controller == other.controller &&
        selectedText == other.selectedText &&
        before == other.before &&
        after == other.after &&
        lineStart == other.lineStart &&
        lineEnd == other.lineEnd &&
        line == other.line;
  }

  @override
  int get hashCode =>
      controller.hashCode *
      selectedText.hashCode *
      before.hashCode *
      after.hashCode *
      lineStart.hashCode *
      lineEnd.hashCode *
      line.hashCode;
}
