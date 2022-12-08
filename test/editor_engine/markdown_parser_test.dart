import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_editor/src/editor_engine/markdown_parser.dart';

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

  group("MarkdownParser getSelectedParagraphs", () {});

  group("MarkdownParser hasRangeMark", () {});
}
