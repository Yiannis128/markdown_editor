import 'package:flutter/material.dart';

import '../text_edit_context.dart';

/// # _ToggleItem
/// Class that represents an item on the toolbox at the top of the editor.
class ToggleItem {
  Key? key;

  /// _toggle: If the item can be toggled.
  final bool _toggle;
  final Widget body;
  bool isSelected = false;

  /// # onUse
  /// Method is invoked when the _ToggleItem is either selected or deselected,
  /// the new selection is reflected by the bool parameter.
  List<TextEdit> Function(bool)? onUse;

  ToggleItem(this.body, {bool toggle = false}) : _toggle = toggle {
    key = body.key;
  }

  List<TextEdit> use() {
    List<TextEdit>? result;
    if (_toggle) {
      isSelected = !isSelected;
      result = onUse?.call(isSelected);
    } else {
      result = onUse?.call(true);
    }
    return result ?? [];
  }
}
