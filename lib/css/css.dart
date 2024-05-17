import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/values.dart';

class Css {
  static final Css _singleton = Css._internal();

  factory Css() {
    return _singleton;
  }

  Css._internal();

  final cupertinoFieldPlaceHolderStyleDefault =
          const TextStyle(color: CupertinoColors.placeholderText),
      theme = ThemeData(
          useMaterial3: true,
          primaryColor: shades.kBlue,
          colorSchemeSeed: shades.kDeepPurple);
}
