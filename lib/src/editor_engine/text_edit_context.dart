import 'package:flutter/material.dart';

/// # _TextEditContext
/// Represents a text editing stack before it has been applied to the text body.
class TextEditContext {
  final List<TextEdit> stack;
  final TextSelection selection;
  TextSelection? _newSelection;

  TextEditContext(this.selection) : stack = <TextEdit>[];

  TextEditContext.fromArray({required this.selection, required List<TextEdit> edits}) : stack = edits;

  void addEdits(List<TextEdit> edits) {
    stack.addAll(edits);
  }

  /// # apply
  /// Applies the edits to the text. At the same time, adjusts transforms
  /// performed by the next `_TextEdit` added so that they aren't corrupt.
  String apply(String text, {bool reverseOrder = false}) {
    var applyStack = reverseOrder ? stack.reversed.toList() : stack;

    var end = selection.end;
    for (var edit in applyStack) {
      end += edit.selectionEndOffset;
      text = text.replaceRange(edit.startIndex, edit.endIndex, edit.newText);
    }

    var start = selection.start + applyStack.first.selectionStartOffset;

    // Clamp selection to make sure it is never out of bounds.
    start = start.clamp(0, text.length);
    end = end.clamp(start, text.length);

    _newSelection = TextSelection(baseOffset: start, extentOffset: end);

    return text;
  }

  TextSelection? getNewTextSelection() {
    return _newSelection;
  }
}

/// # _TextEdit
/// Represents a change in the text, it contains only details of the change
/// along where the change should occur, along with the new selection.
///
/// * `selectionStartOffset` is the offset of start selection when this text
/// edit is applied.
/// * `selectionEndOffset` is the offset of end selection when this text edit
/// is applied.
///
/// NOTE: Perhaps it is worth moving the selection start offset to another place
/// due to the start index in context using the first one in the stack, unlike
/// end which uses all of them.
class TextEdit {
  final String newText;
  final int startIndex;
  final int endIndex;
  final int selectionStartOffset;
  final int selectionEndOffset;
  TextEdit(this.newText, this.startIndex, this.endIndex,
      this.selectionStartOffset, this.selectionEndOffset);
}
