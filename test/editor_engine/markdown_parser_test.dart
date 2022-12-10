import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_editor/src/editor_engine/markdown_parser.dart';

import '../test_case.dart';

const String _testText1 = """AAAAA BBBBB CCCCC DDDDD
AAAAA BBBBB CCCCC DDDDD

AAAAA BBBBB CCCCC DDDDD
AAAAA BBBBB CCCCC DDDDD
AAAAA BBBBB CCCCC DDDDD

AAAAA BBBBB CCCCC DDDDD

""";

const String _testText2 = """AAAAABBBBB
A__AABBB**
AAAAA**BBB

AAA**BBBBB
A__AAB__BB
AAAAABBB**

~~AAA~~BBB
__AAA__BBB
""";

const String _testText3 = """AAA**BBBBB
A__A**BBBB

A**AAB__BB
A**AA__BBB""";

const String _testText4 = """AAA**BBBBB
A__AABBBBB

AAAAA**BBB""";

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

  group("MarkdownParser getSelectedParagraphs basic:", () {
    List<TestCase> tests = [
      TestCase(
        title: "Cursor at start of text",
        test: const TextSelection(baseOffset: 0, extentOffset: 0),
        expected: [
          0,
          <String>["AAAAA BBBBB CCCCC DDDDD\nAAAAA BBBBB CCCCC DDDDD"],
        ],
      ),
      TestCase(
        title: "Cursor at end of text",
        test: const TextSelection(
            baseOffset: _testText1.length, extentOffset: _testText1.length),
        expected: [
          147,
          <String>[""],
        ],
      ),
      TestCase(
        title: "Cursor before a paragraph end (before a \\n\\n)",
        test: const TextSelection(baseOffset: 47, extentOffset: 47),
        expected: [
          0,
          <String>["AAAAA BBBBB CCCCC DDDDD\nAAAAA BBBBB CCCCC DDDDD"],
        ],
      ),
      TestCase(
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
      TestCase(
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
      TestCase(
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
      TestCase(
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
      TestCase(
        title: "End single paragraph selection on an empty line",
        test: const TextSelection(baseOffset: 50, extentOffset: 121),
        expected: [
          49,
          <String>[
            "AAAAA BBBBB CCCCC DDDDD\nAAAAA BBBBB CCCCC DDDDD\nAAAAA BBBBB CCCCC DDDDD",
          ],
        ],
      ),
      TestCase(
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

  group("MarkdownParser getSelectedParagraphs empty result:", () {
    List<TestCase> tests = [
      TestCase(
        title: "Cursor at empty line between paragraphs",
        test: const TextSelection(baseOffset: 146, extentOffset: 146),
        expected: SelectedParagraphs(paragraphs: [], paragraphStartOffsets: []),
      ),
    ];

    for (var i = 0; i < tests.length; i++) {
      var t = tests[i];
      var title = t.title;
      var selection = t.test;
      var expected = t.expected;

      test(title, () {
        var selectedParagraphs =
            MarkdownParser().getSelectedParagraphs(_testText1, selection);

        expect(selectedParagraphs, expected);
      });
    }
  });

  group("MarkdownParser hasRangeMark: 1", () {
    List<TestCase> tests = [
      TestCase(
        title: "Select from start same paragraph",
        test: const TextSelection(baseOffset: 0, extentOffset: 15),
        expected: [],
      ),
      TestCase(
        title: "Select bold range marker",
        test: const TextSelection(baseOffset: 21, extentOffset: 27),
        expected: [
          RangeSymbol(
            "**",
            const TextSelection(baseOffset: 21, extentOffset: 27),
          ),
        ],
      ),
      TestCase(
        title: "Select italics range marker",
        test: const TextSelection(baseOffset: 81, extentOffset: 84),
        expected: [
          RangeSymbol(
            "__",
            const TextSelection(baseOffset: 81, extentOffset: 84),
          ),
        ],
      ),
      TestCase(
        title: "Select strike-through range marker",
        test: const TextSelection(baseOffset: 70, extentOffset: 73),
        expected: [
          RangeSymbol(
            "~~",
            const TextSelection(baseOffset: 70, extentOffset: 73),
          ),
        ],
      ),
      TestCase(
        title: "Select nested italics range marker",
        test: const TextSelection(baseOffset: 48, extentOffset: 51),
        expected: [
          RangeSymbol(
            "**",
            const TextSelection(baseOffset: 39, extentOffset: 64),
          ),
          RangeSymbol(
            "__",
            const TextSelection(baseOffset: 48, extentOffset: 51),
          ),
        ],
      ),
      TestCase(
        title: "Select bold range marker with italics nested inside",
        test: const TextSelection(baseOffset: 39, extentOffset: 64),
        expected: [
          RangeSymbol(
            "**",
            const TextSelection(baseOffset: 39, extentOffset: 64),
          ),
        ],
      ),
      TestCase(
        title: "Not full selection of range symbol",
        test: const TextSelection(baseOffset: 22, extentOffset: 25),
        expected: [
          RangeSymbol(
            "**",
            const TextSelection(baseOffset: 21, extentOffset: 27),
          ),
        ],
      ),
    ];

    for (var i = 0; i < tests.length; i++) {
      var t = tests[i];

      var title = t.title;
      var selection = t.test;
      var expected = t.expected;

      test(title, () {
        var results = MarkdownParser().hasRangeMark(_testText2, selection);

        expect(results, expected);
      });
    }
  });

  group("MarkdownParser hasRangeMark: 2", () {
    List<TestCase> tests = [
      TestCase(
        title:
            "Select bold range marker with single italic range marker inside",
        test: const TextSelection(baseOffset: 5, extentOffset: 15),
        expected: [
          RangeSymbol(
            "**",
            const TextSelection(baseOffset: 5, extentOffset: 15),
          ),
        ],
      ),
      TestCase(
        title:
            "Select bold range marker with single italic range marker inside and other outside",
        test: const TextSelection(baseOffset: 26, extentOffset: 35),
        expected: [
          RangeSymbol(
            "**",
            const TextSelection(baseOffset: 26, extentOffset: 35),
          )
        ],
      ),
    ];

    for (var i = 0; i < tests.length; i++) {
      var t = tests[i];

      var title = t.title;
      var selection = t.test;
      var expected = t.expected;

      test(title, () {
        var results = MarkdownParser().hasRangeMark(_testText3, selection);

        expect(results, expected);
      });
    }
  });

  group("MarkdownParser hasRangeMark: 3", () {
    List<TestCase> tests = [
      TestCase(
        title: "Multi paragraph selection",
        test: const TextSelection(baseOffset: 5, extentOffset: 28),
        expected: [],
      ),
    ];

    for (var i = 0; i < tests.length; i++) {
      var t = tests[i];

      var title = t.title;
      var selection = t.test;
      var expected = t.expected;

      test(title, () {
        var results = MarkdownParser().hasRangeMark(_testText4, selection);

        expect(results, expected);
      });
    }
  });
}
