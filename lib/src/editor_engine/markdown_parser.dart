import 'package:flutter/material.dart';

class MarkdownParser {
  MarkdownParser._();
  static MarkdownParser? _markdownParser;
  factory MarkdownParser() {
    _markdownParser ??= MarkdownParser._();
    return _markdownParser!;
  }

  /// # hasHeaderMark
  ///
  /// Detects if the text `line` provided has a header mark. A header mark
  /// counts as any of the # marks, along with the list marks.
  String? hasHeaderMark(String line) {
    var trimmedLine = line.trim();
    if (line.startsWith("#### ")) {
      return "#### ";
    } else if (line.startsWith("### ")) {
      return "### ";
    } else if (line.startsWith("## ")) {
      return "## ";
    } else if (line.startsWith("# ")) {
      return "# ";
    } else if (line.length >= 3 &&
        line.startsWith("---") &&
        trimmedLine.replaceAll("-", "") == "") {
      return "---";
    } else if (trimmedLine.startsWith(">")) {
      return "> ";
    } else if (line.startsWith("* ")) {
      return "* ";
    } else {
      /// Ordered list
      /// Check for ordered list. Start by separating the number.
      /// Find the . and see if the string left is a number.
      var pointIndex = line.indexOf(".");
      if (pointIndex != -1) {
        // Check for space after point.
        if (pointIndex + 1 < line.length &&
            line.characters.elementAt(pointIndex + 1) == " ") {
          var numberStr = line.characters.getRange(0, pointIndex).toString();
          // Check if whitespace.
          if (numberStr.trimLeft() == numberStr) {
            var number = int.tryParse(numberStr);
            if (number != null) {
              return "1. ";
            }
          }
        }
      }
    }
    return null;
  }

  /// # getSelectedParagraphs
  /// Returns information about the currently selected paragraphs. Given text
  /// and selection, returns List<String> of the paragraphs selected along with
  /// the start of the pargraph in an array.
  SelectedParagraphs getSelectedParagraphs(
      String text, TextSelection selection) {
    var start = selection.start;
    var end = selection.end;

    // Split text by double lines since that's what cuts of range marks.
    var textParagraphs = text.split("\n\n");

    final paragraphStartOffsets = <int>[];

    // Find out which paragraphs the selection is inside, and remove others.
    // This is the accummulated paragraph length used for calculating if
    // selection is inside specific paragraph. `resultPStart` contains the
    // start of the first paragraph, `paragraphStart` is used in this function
    // for calculations.
    var paragraphStart = 0;
    var trimmedStart = false;
    for (var index = 0; index < textParagraphs.length; index++) {
      var paragraph = textParagraphs[index];

      var paragraphEnd = paragraphStart + paragraph.length;

      // Check if start of paragraph has been trimmed, if not then do so.
      // Edge case: Check if start/end is between paragraphs, if that's the
      // case, then it will cause a bug where then whole text is scanned.
      if (!trimmedStart) {
        // Edge case: Check if start is in the space between current and
        // previous paragraph.
        if (!trimmedStart && start == paragraphStart - 1) {
          // If that's the case, then set start to the correct value.
          start = paragraphStart;
        }

        if (start >= paragraphStart && start <= paragraphEnd) {
          // Trim start
          var oldCount = textParagraphs.length;
          textParagraphs = textParagraphs.sublist(index);

          // Adjust index.
          index -= oldCount - textParagraphs.length;
          trimmedStart = true;
        }
      }

      if (trimmedStart) {
        paragraphStartOffsets.add(paragraphStart);
      }

      // Edge case: Check if end is between the current and next paragraph.
      if (end == paragraphEnd + 1) {
        end = paragraphEnd;
      }

      // Trim end.
      if (end >= paragraphStart && end <= paragraphEnd) {
        textParagraphs = textParagraphs.sublist(0, index + 1);

        // Breaking here will also not update paragraphStart meaning that the
        // value will be still correct.
        break;
      }

      // + 2 to account for the \n\n that got split out.
      paragraphStart = paragraphEnd + 2;
    }

    return SelectedParagraphs(
      paragraphs: textParagraphs,
      paragraphStartOffsets: paragraphStartOffsets,
    );
  }

  /// # hasRangeMark
  ///
  /// Range mark propagates only through single newline and also when there's no
  /// space between the pair of markers. This will return true only if:
  /// * The selection is not collapsed and perfectly selects the text inside the
  /// pair of markers.
  /// If a symbol starts inside of an existing symbol range, then that doesn't
  /// count, only the first one does: platea **dictumst. __Donec** egestas__ ...
  /// Returns a Map<RangeMark, TextSelection> that specifies the range of each
  /// range mark.
  /// Return false if:
  /// * The selection is collapsed and inside the pair of markers.
  List<RangeSymbol> hasRangeMark(String text, TextSelection selection) {
    const rangeSymbols = <String>["**", "__", "~~"];

    if (selection.isCollapsed) {
      return [];
    }

    var selectedParagraphs = getSelectedParagraphs(text, selection);
    List<String> textParagraphs = selectedParagraphs.paragraphs;
    // FIXME We cache the result so no need to keep recalculating it.
    int paragraphStart = selectedParagraphs.paragraphStartOffsets[0];

    // Map of range symbol and location.
    final symbolsFound = <_RangeSymbol>[];

    // Start by looping each paragraph.
    for (var paragraphIndex = 0;
        paragraphIndex < textParagraphs.length;
        paragraphIndex++) {
      var paragraph = textParagraphs[paragraphIndex];
      // Loop over each character in the paragraph.
      for (var cIndex = 0; cIndex < paragraph.length - 1; cIndex++) {
        final chars = paragraph[cIndex] + paragraph[cIndex + 1];
        // Check if symbol exists.
        for (var rangeSymbol in rangeSymbols) {
          if (chars == rangeSymbol) {
            symbolsFound.add(_RangeSymbol(
              paragraphStart + cIndex,
              cIndex,
              rangeSymbol,
            ));
          }
        }
      }
    }

    // Use a stack to determine which are valid symbols.
    final result = <RangeSymbol>[];
    for (var symbolIndex = 0;
        symbolIndex < symbolsFound.length;
        symbolIndex++) {
      var symbol = symbolsFound[symbolIndex];
      for (var nextSymbolIndex = symbolIndex + 1;
          nextSymbolIndex < symbolsFound.length;
          nextSymbolIndex++) {
        var nextSymbol = symbolsFound[nextSymbolIndex];

        // Check if selection is within range.
        if (selection.start >= symbol.textOffset + symbol.symbol.length &&
            selection.end <= nextSymbol.textOffset) {
          // Check if there is a next symbol match.
          if (symbol.symbol == nextSymbol.symbol) {
            // Add selection
            result.add(RangeSymbol(
              symbol.symbol,
              TextSelection(
                baseOffset: symbol.textOffset + symbol.symbol.length,
                extentOffset: nextSymbol.textOffset,
              ),
            ));
            // Go to next start symbol iteration.
            break;
          }
        } else {
          // This check is for the scenario where the next symbol in the inner
          // loop might also match, and be within range, so we wanna skip to
          // the next start symbol. Example: **AAA BBB** AA** - This will cause
          // AAA BBB** AA to be selected, this if resolves that.
          if (symbol.symbol == nextSymbol.symbol) {
            symbolIndex++;
            break;
          }
        }
      }
    }

    return result;
  }
}

class RangeSymbol {
  final String symbol;
  final TextSelection selection;

  RangeSymbol(this.symbol, this.selection);

  @override
  bool operator ==(Object other) {
    if (other is! RangeSymbol) {
      return false;
    }
    return symbol == other.symbol && selection == other.selection;
  }

  @override
  int get hashCode => symbol.hashCode * selection.hashCode;

  @override
  String toString() {
    return "RangeSymbol: $symbol [${selection.start}:${selection.end}]";
  }
}

class _RangeSymbol {
  final int textOffset;
  final int paragraphOffset;
  final String symbol;

  _RangeSymbol(this.textOffset, this.paragraphOffset, this.symbol);
}

/// # SelectedParagraphs
/// Describes paragraphs that have been selected by cursor. This is returned by
/// `MarkdownParser().getSelectedParagraphs`.
class SelectedParagraphs {
  final List<String> paragraphs;
  final List<int> paragraphStartOffsets;

  SelectedParagraphs({
    required this.paragraphs,
    required this.paragraphStartOffsets,
  });

  @override
  bool operator ==(Object other) {
    if (other is! SelectedParagraphs) {
      return false;
    }
    return paragraphs == other.paragraphs &&
        paragraphStartOffsets == other.paragraphStartOffsets;
  }

  @override
  int get hashCode => paragraphs.hashCode * paragraphStartOffsets.hashCode;
}
