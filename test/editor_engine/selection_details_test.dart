import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_editor/src/editor_engine/selection_details.dart';

const String _groupTest = """# New Note

1. Tap the pencil icon below to edit.
2. The notes have [Markdown support](https://www.markdownguide.org/cheat-sheet/).

# PLANNING

AAAAAAA

AAAAAAA
BBBBBBB
VVVVVVV
CCCCCCC
XXXXXXX



""";

void main() {
  group('Collapsed Selections', () {
    test("AAAA", () {});
  });

  group("Range selections", () {
    final _testTitles = <String>[
      "Test 1"
    ];

    for (var title in _testTitles) {
      test(title, () {
        final controller = TextEditingController(text: _groupTest);
        final selection = SelectionDetails(controller);
        
      });
    }
  });
}
