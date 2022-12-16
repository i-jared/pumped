import 'package:flutter/material.dart';
import 'package:pumped/imports.dart';

extension Styles on Text {
  Text mood() {
    return bold().italic().fontSize(30);
  }

  Widget alone() {
    return bold()
        .italic()
        .fontSize(30)
        .textAlignment(TextAlign.center)
        .center();
  }
}
