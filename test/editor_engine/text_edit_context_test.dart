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
            const TextSelection(
              baseOffset: 11,
              extentOffset: 16,
            ),
            [
              TextEdit("CCCCC", 11, 16, 0, 0),
            ],
          ),
          expected: "AAAAABBBBB\nCCCCCBBBBB"),
    ];

    // TODO Write more TextEditContext Tests
    // Replace text once with selection offset increase
    // Replace text once with selection offset decrease
    // Replace text multiple with selection offset increase
    // Replace text multiple with selection offset decrease
    // Test reverse parameter

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
}
