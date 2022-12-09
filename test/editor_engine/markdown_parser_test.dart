import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_editor/src/editor_engine/markdown_parser.dart';

const String _testText1 = """AAAAA BBBBB CCCCC DDDDD
AAAAA BBBBB CCCCC DDDDD

AAAAA BBBBB CCCCC DDDDD
AAAAA BBBBB CCCCC DDDDD
AAAAA BBBBB CCCCC DDDDD

AAAAA BBBBB CCCCC DDDDD

""";

void main() {
  group("MarkdownParser hasHeaderMark: other", () {
    const List<String> headerMarkTestText = <String>[
      "No header mark",
      "# Header mark",
      "## Double header mark",
      "#Trick no header mark",
      "Mid text # no header mark",
      "### Triple header mark",
      "#### Quad header mark",
      "* Unordered list header mark",
      "a * Unordered list trick header mark",
    ];

    const expectedResults = <String?>[
      null,
      "# ",
      "## ",
      null,
      null,
      "### ",
      "#### ",
      "* ",
      null,
    ];

    for (var i = 0; i < headerMarkTestText.length; i++) {
      var title = headerMarkTestText[i];
      var expected = expectedResults[i];

      test(title, () {
        var result = MarkdownParser().hasHeaderMark(title);
        expect(result, expected);
      });
    }
  });

  group("MarkdownParser hasHeaderMark: block quote", () {
    const List<String> bqTestText = <String>[
      "No block quote",
      "> Block quote with space",
      ">Block quote no space",
    ];

    const expectedResults = <String?>[
      null,
      "> ",
      "> ",
    ];

    for (var i = 0; i < bqTestText.length; i++) {
      var title = bqTestText[i];
      var expected = expectedResults[i];

      test(title, () {
        var result = MarkdownParser().hasHeaderMark(title);
        expect(result, expected);
      });
    }
  });

  group("MarkdownParser hasHeaderMark: horizontal line", () {
    const List<String> titles = <String>[
      "No horizontal line",
      "1 dash",
      "2 dashes",
      "3 dashes",
      "4 dashes",
      "10 dashes",
      "3 dashes with space before",
      "3 dashes and text to right",
      "3 dashes and text to right with space",
    ];

    const List<String> testText = <String>[
      "Some text",
      "-",
      "--",
      "---",
      "----",
      "----------",
      " ---",
      "---some text",
      "--- some text",
    ];

    const expectedResults = <String?>[
      null,
      null,
      null,
      "---",
      "---",
      "---",
      null,
      null,
      null,
    ];

    for (var i = 0; i < titles.length; i++) {
      var title = titles[i];
      var testLine = testText[i];
      var expected = expectedResults[i];

      test(title, () {
        var result = MarkdownParser().hasHeaderMark(testLine);
        expect(result, expected);
      });
    }
  });

  group("MarkdownParser hasHeaderMark: ordered list", () {
    const List<String> titles = <String>[
      "Single digit number",
      "Two digit number",
      "Three digit number",
      "Number with space before",
      "Number with no space after",
    ];

    const List<String> testText = <String>[
      "3. Some text",
      "25. Some text2",
      "300. Some tex 3",
      " 1. Space text",
      "6.No space",
    ];

    const expectedResults = <String?>[
      "1. ",
      "1. ",
      "1. ",
      null,
      null,
    ];

    for (var i = 0; i < titles.length; i++) {
      var title = titles[i];
      var testLine = testText[i];
      var expected = expectedResults[i];

      test(title, () {
        var result = MarkdownParser().hasHeaderMark(testLine);
        expect(result, expected);
      });
    }
  });

  group("MarkdownParser getSelectedParagraphs:", () {
    List<_Test> tests = [
      _Test(
        title: "Cursor at start of text",
        test: const TextSelection(baseOffset: 0, extentOffset: 0),
        expected: [
          0,
          <String>["AAAAA BBBBB CCCCC DDDDD\nAAAAA BBBBB CCCCC DDDDD"],
        ],
      ),
      _Test(
        title: "Cursor at end of text",
        test: const TextSelection(
            baseOffset: _testText1.length, extentOffset: _testText1.length),
        expected: [
          147,
          <String>[""],
        ],
      ),
      _Test(
        title: "Cursor before a paragraph end (before a \\n\\n)",
        test: const TextSelection(baseOffset: 47, extentOffset: 47),
        expected: [
          0,
          <String>["AAAAA BBBBB CCCCC DDDDD\nAAAAA BBBBB CCCCC DDDDD"],
        ],
      ),
      _Test(
        title: "Multi paragraph selection from start",
        test: const TextSelection(baseOffset: 0, extentOffset: 50),
        expected: [
          0,
          <String>[
            "AAAAA BBBBB CCCCC DDDDD\nAAAAA BBBBB CCCCC DDDDD",
            "AAAAA BBBBB CCCCC DDDDD\nAAAAA BBBBB CCCCC DDDDD\nAAAAA BBBBB CCCCC DDDDD",
          ],
        ],
      ),
      _Test(
        title: "Multi paragraph selection from second paragraph",
        test: const TextSelection(
          baseOffset: 50,
          extentOffset: 130,
        ),
        expected: [
          49,
          <String>[
            "AAAAA BBBBB CCCCC DDDDD\nAAAAA BBBBB CCCCC DDDDD\nAAAAA BBBBB CCCCC DDDDD",
            "AAAAA BBBBB CCCCC DDDDD"
          ],
        ],
      ),
      _Test(
        title: "Multi paragraph selection ending at end of text",
        test: const TextSelection(
            baseOffset: 50, extentOffset: _testText1.length),
        expected: [
          49,
          <String>[
            "AAAAA BBBBB CCCCC DDDDD\nAAAAA BBBBB CCCCC DDDDD\nAAAAA BBBBB CCCCC DDDDD",
            "AAAAA BBBBB CCCCC DDDDD",
            "",
          ],
        ],
      ),
      _Test(
        title: "All text selected",
        test:
            const TextSelection(baseOffset: 0, extentOffset: _testText1.length),
        expected: [
          0,
          <String>[
            "AAAAA BBBBB CCCCC DDDDD\nAAAAA BBBBB CCCCC DDDDD",
            "AAAAA BBBBB CCCCC DDDDD\nAAAAA BBBBB CCCCC DDDDD\nAAAAA BBBBB CCCCC DDDDD",
            "AAAAA BBBBB CCCCC DDDDD",
            "",
          ],
        ],
      ),
      _Test(
        title: "End single paragraph selection on an empty line",
        test: const TextSelection(baseOffset: 50, extentOffset: 121),
        expected: [
          49,
          <String>[
            "AAAAA BBBBB CCCCC DDDDD\nAAAAA BBBBB CCCCC DDDDD\nAAAAA BBBBB CCCCC DDDDD",
          ],
        ],
      ),
      _Test(
        title: "End multi paragraph selection on an empty line",
        test: const TextSelection(baseOffset: 10, extentOffset: 121),
        expected: [
          0,
          <String>[
            "AAAAA BBBBB CCCCC DDDDD\nAAAAA BBBBB CCCCC DDDDD",
            "AAAAA BBBBB CCCCC DDDDD\nAAAAA BBBBB CCCCC DDDDD\nAAAAA BBBBB CCCCC DDDDD",
          ],
        ],
      ),
    ];

    for (var i = 0; i < tests.length; i++) {
      var t = tests[i];

      var title = t.title;
      var selection = t.test;
      var expected = t.expected;

      var expectedPStart = expected[0];
      var expectedParagraphs = expected[1];

      test(title, () {
        var selectedParagraphs =
            MarkdownParser().getSelectedParagraphs(_testText1, selection);

        List<String> paragraphs = selectedParagraphs.paragraphs;
        expect(paragraphs, expectedParagraphs);

        // FIXME Need to test for all paragraphs equalling. This whole test needs
        // refactoing.
        int pStart = selectedParagraphs.paragraphStartOffsets[0];
        expect(pStart, expectedPStart);
      });
    }
  });

  group("MarkdownParser hasRangeMark", () {});
}

class _Test {
  final String title;
  final dynamic test;
  final dynamic expected;
  _Test({required this.title, required this.test, required this.expected});
}
