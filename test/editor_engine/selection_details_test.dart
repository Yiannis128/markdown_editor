import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_editor/src/editor_engine/selection_details.dart';

const String _groupTest1 = """# New Note

12 Tap the22 pencil icon below to edit.51
2. The 60notes have Markdow80n support.93


# 100PLANNING

113AAAAAAA


""";

void main() {
  group('Collapsed selections:', () {
    final controller = TextEditingController(text: _groupTest1);

    final testTitles = <String>[
      "Select start of text",
      "Select end of text",
      "Select empty line",
      "Select line with text",
    ];

    final testParams = <TextSelection>[
      const TextSelection(baseOffset: 0, extentOffset: 0),
      const TextSelection(
          baseOffset: _groupTest1.length, extentOffset: _groupTest1.length),
      const TextSelection(baseOffset: 11, extentOffset: 11),
      const TextSelection(baseOffset: 20, extentOffset: 20),
    ];

    final expectedResults = <SelectionDetails>[
      // Select start of text,
      _selectionDetailsMock(
        controller,
        selectedText: "",
        before: "",
        after: _groupTest1,
        lineStart: 0,
        lineEnd: 10,
        line: "# New Note",
      ),
      // Select end of text,
      _selectionDetailsMock(
        controller,
        selectedText: "",
        before: _groupTest1,
        after: "",
        lineStart: 126,
        lineEnd: 126,
        line: "",
      ),
      // Select empty line,
      _selectionDetailsMock(
        controller,
        selectedText: "",
        before: _groupTest1.substring(0, 11),
        after: _groupTest1.substring(11),
        lineStart: 11,
        lineEnd: 11,
        line: "",
      ),
      // Select line with text,
      _selectionDetailsMock(
        controller,
        selectedText: "",
        before: _groupTest1.substring(0, 20),
        after: _groupTest1.substring(20),
        lineStart: 12,
        lineEnd: 53,
        line: _groupTest1.substring(12, 53),
      ),
    ];

    for (var i = 0; i < testTitles.length; i++) {
      var title = testTitles[i];
      var textSelection = testParams[i];
      var expected = expectedResults[i];

      test(title, () => _runTest(controller, textSelection, expected));
    }
  });

  group("Range selections:", () {
    final controller = TextEditingController(text: _groupTest1);

    final testTitles = <String>[
      "1 line selection",
      "Multiline selection",
      "Selection with non 0 start",
      "Whole document selection",
      "Selection ending on a blank new line",
      "Non 0 start selection that ends on a blank new line",
    ];

    final testParams = <TextSelection>[
      const TextSelection(baseOffset: 0, extentOffset: 4),
      const TextSelection(baseOffset: 0, extentOffset: 20),
      const TextSelection(baseOffset: 20, extentOffset: 50),
      const TextSelection(baseOffset: 0, extentOffset: _groupTest1.length),
      const TextSelection(baseOffset: 0, extentOffset: 96),
      const TextSelection(baseOffset: 12, extentOffset: 96),
    ];

    final expected = <SelectionDetails>[
      // 1 line selection
      _selectionDetailsMock(
        controller,
        selectedText: _groupTest1.substring(0, 4),
        before: "",
        after: _groupTest1.substring(4),
        lineStart: 0,
        lineEnd: 10,
        line: _groupTest1.substring(0, 10),
      ),
      // Multiline selection
      _selectionDetailsMock(
        controller,
        selectedText: _groupTest1.substring(0, 20),
        before: "",
        after: _groupTest1.substring(20),
        lineStart: 0,
        lineEnd: 53,
        line: _groupTest1.substring(0, 53),
      ),
      // Selection with non 0 start
      _selectionDetailsMock(
        controller,
        selectedText: _groupTest1.substring(20, 50),
        before: _groupTest1.substring(0, 20),
        after: _groupTest1.substring(50),
        lineStart: 12,
        lineEnd: 53,
        line: _groupTest1.substring(12, 53),
      ),
      // Whole document selection
      _selectionDetailsMock(
        controller,
        selectedText: _groupTest1,
        before: "",
        after: "",
        lineStart: 0,
        lineEnd: _groupTest1.length,
        line: _groupTest1,
      ),
      // Selection ending on a blank new line
      _selectionDetailsMock(
        controller,
        selectedText: _groupTest1.substring(0, 96),
        before: "",
        after: _groupTest1.substring(96),
        lineStart: 0,
        lineEnd: 96,
        line: _groupTest1.substring(0, 96),
      ),
      // Non 0 start selection that ends on a blank new line
      _selectionDetailsMock(
        controller,
        selectedText: _groupTest1.substring(12, 96),
        before: _groupTest1.substring(0, 12),
        after: _groupTest1.substring(96),
        lineStart: 12,
        lineEnd: 96,
        line: _groupTest1.substring(12, 96),
      ),
    ];

    for (var index = 0; index < testTitles.length; index++) {
      var title = testTitles[index];
      var textSelection = testParams[index];
      test(title, () => _runTest(controller, textSelection, expected[index]));
    }
  });
}

void _runTest(TextEditingController controller, TextSelection textSelection,
    SelectionDetails expected) {
  // Set text editing controller state.
  controller.clear();
  controller.value = TextEditingValue(
    text: _groupTest1,
    selection: textSelection,
  );

  // Create selection and update.
  final selection = SelectionDetails(controller);
  selection.update();

  expect(selection, expected);
}

SelectionDetails _selectionDetailsMock(
  TextEditingController controller, {
  required String selectedText,
  required String before,
  required String after,
  required int lineStart,
  required int lineEnd,
  required String line,
}) {
  var s = SelectionDetails(controller);
  s.selectedText = selectedText;
  s.before = before;
  s.after = after;
  s.lineStart = lineStart;
  s.lineEnd = lineEnd;
  s.line = line;
  return s;
}
