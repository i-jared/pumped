import 'package:flutter/material.dart';
import 'package:pumped/imports.dart';

extension Styles on Text {
  Widget alone() {
    return bold()
        .italic()
        .fontSize(30)
        .textAlignment(TextAlign.center)
        .center();
  }
}
