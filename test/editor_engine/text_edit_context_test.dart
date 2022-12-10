import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_editor/src/editor_engine/text_edit_context.dart';

import '../test_case.dart';

const String _testText1 = """AAAAABBBBB
AAAAABBBBB""";

void main() {
  group("Test TextEditContext.apply", () {
    var tests = <TestCase>[
      TestCase(
        title: "Replace text once",
        test: TextEditContext.fromArray(
          selection: const TextSelection(
            baseOffset: 11,
            extentOffset: 16,
          ),
          edits: [
            TextEdit("CCCCC", 11, 16, 0, 0),
          ],
        ),
        expected: "AAAAABBBBB\nCCCCCBBBBB",
      ),
      TestCase(
        title: "Replace text once with selection offset increase",
        test: TextEditContext.fromArray(
          selection: const TextSelection(
            baseOffset: 14,
            extentOffset: 16,
          ),
          edits: [
            TextEdit("CCCCCDD", 11, 16, 16, 18),
          ],
        ),
        expected: "AAAAABBBBB\nCCCCCDDBBBBB",
      ),
      TestCase(
        title: "Replace text once with selection offset decrease",
        test: TextEditContext.fromArray(
          selection: const TextSelection(
            baseOffset: 14,
            extentOffset: 16,
          ),
          edits: [
            TextEdit("CC", 11, 16, 13, 15),
          ],
        ),
        expected: "AAAAABBBBB\nCCBBBBB",
      ),
      TestCase(
        title: "Replace text multiple with selection offset increase",
        test: TextEditContext.fromArray(
          selection: const TextSelection(
            baseOffset: 14,
            extentOffset: 16,
          ),
          edits: [
            TextEdit("FFFFFF", 11, 16, 15, 17),
            TextEdit("EEEEEE", 5, 10, 15, 17),
          ],
        ),
        expected: "AAAAAEEEEEE\nFFFFFFBBBBB",
      ),
      TestCase(
        title: "Replace text multiple with selection offset decrease",
        test: TextEditContext.fromArray(
          selection: const TextSelection(
            baseOffset: 14,
            extentOffset: 16,
          ),
          edits: [
            TextEdit("F", 11, 16, 10, 12),
            TextEdit("E", 5, 10, 10, 12),
          ],
        ),
        expected: "AAAAAE\nFBBBBB",
      ),
    ];

    for (var i = 0; i < tests.length; i++) {
      var t = tests[i];
      var title = t.title;
      TextEditContext ctx = t.test;
      var expected = t.expected;

      test(title, () {
        var result = ctx.apply(_testText1);

        expect(result, expected);
      });
    }
  });

  group("Test TextEditContext.apply reversed:", () {
    var tests = <TestCase>[
      TestCase(
        title: "Test parameter",
        test: TextEditContext.fromArray(
          selection: const TextSelection(
            baseOffset: 14,
            extentOffset: 16,
          ),
          edits: [
            TextEdit("E", 5, 10, 10, 12),
            TextEdit("F", 11, 16, 10, 12),
          ],
        ),
        expected: "AAAAAE\nFBBBBB",
      ),
    ];

    for (var i = 0; i < tests.length; i++) {
      var t = tests[i];
      var title = t.title;
      TextEditContext ctx = t.test;
      var expected = t.expected;

      test(title, () {
        var result = ctx.apply(_testText1, reverseOrder: true);

        expect(result, expected);
      });
    }
  });
}
